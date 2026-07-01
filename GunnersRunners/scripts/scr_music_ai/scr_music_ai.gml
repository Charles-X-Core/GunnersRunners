function scr_music_ai_init()
{
    global.ai_bass_history = array_create(8, 0);
    global.ai_mids_history = array_create(8, 0);
    global.ai_highs_history = array_create(8, 0);
    global.ai_onset_history = array_create(8, 0);
    global.ai_history_index = 0;
    global.ai_energy_trend = 0;
    global.ai_intensity_score = 0;
    global.ai_drop_imminent = false;
    global.ai_break_incoming = false;
    global.ai_section_changed = false;
    global.ai_prev_section = "INTRO";
    global.ai_adaptive_spawn_mult = 1.0;
    global.ai_adaptive_powerup_mult = 1.0;
    global.ai_last_powerup_time = 0;
    global.ai_beat_push_timer = 0;
    global.ai_onset_burst_timer = 0;
    global.ai_camera_zoom = 1.0;
    global.ai_camera_zoom_target = 1.0;
    global.section_flash = 0;
    global.section_flash_r = 0;
    global.section_flash_g = 0;
    global.section_flash_b = 0;
    global.combo_border_alpha = 0;
    global.tutorial_mode = false;
    global.tutorial_text = "";
    global.tutorial_text_timer = 0;
    global.tutorial_wave_index = 0;
    global.ai_last_formation = "spread";
    global.ai_last_spawn_count = 1;
    global.ai_last_weights = { basic: 0.3, zigzag: 0.3, homing: 0.2, heavy: 0.2 };
}

function scr_music_ai_analyze()
{
    var _idx = global.ai_history_index;
    global.ai_bass_history[_idx] = global.energy_bass;
    global.ai_mids_history[_idx] = global.energy_mids;
    global.ai_highs_history[_idx] = global.energy_highs;
    global.ai_onset_history[_idx] = global.onset_intensity;
    global.ai_history_index = (_idx + 1) mod 8;

    var _sum_new = 0;
    var _sum_old = 0;
    for (var _i = 0; _i < 4; _i++)
    {
        _sum_new += global.ai_bass_history[(_idx + _i) mod 8];
        _sum_old += global.ai_bass_history[(_idx + 4 + _i) mod 8];
    }
    global.ai_energy_trend = (_sum_new / 4) - (_sum_old / 4);

    var _total = 0;
    _total += global.energy_bass * 0.4;
    _total += global.energy_mids * 0.3;
    _total += global.energy_highs * 0.2;
    _total += global.onset_intensity * 0.1;
    global.ai_intensity_score = clamp(_total, 0, 1);

    global.ai_drop_imminent = (global.ai_energy_trend > 0.05) && (global.ai_intensity_score > 0.4);
    global.ai_break_incoming = (global.ai_energy_trend < -0.08) && (global.ai_intensity_score < 0.3);

    if (instance_exists(obj_rhythm))
    {
        var _sec = obj_rhythm.current_section;
        if (_sec != global.ai_prev_section)
        {
            global.ai_section_changed = true;
            global.ai_prev_section = _sec;

            var _c = _sec;
            switch (_c)
            {
                case "INTRO":   global.section_flash_r = 60;  global.section_flash_g = 80;  global.section_flash_b = 180; break;
                case "BUILDUP": global.section_flash_r = 120; global.section_flash_g = 40;  global.section_flash_b = 200; break;
                case "MAIN":    global.section_flash_r = 40;  global.section_flash_g = 120; global.section_flash_b = 220; break;
                case "DROP":    global.section_flash_r = 220; global.section_flash_g = 40;  global.section_flash_b = 80;  break;
                case "BREAK":   global.section_flash_r = 80;  global.section_flash_g = 40;  global.section_flash_b = 160; break;
                case "OUTRO":   global.section_flash_r = 40;  global.section_flash_g = 80;  global.section_flash_b = 120; break;
                default:        global.section_flash_r = 100; global.section_flash_g = 100; global.section_flash_b = 100; break;
            }
            global.section_flash = 1.0;
        }
        else
        {
            global.ai_section_changed = false;
        }
    }

    if (instance_exists(obj_player))
    {
        var _hp = obj_player.hp;
        var _max = obj_player.max_hp;
        var _combo = obj_player.combo;

        global.ai_adaptive_spawn_mult = 1.0;
        if (_hp <= 1) global.ai_adaptive_spawn_mult = 0.6;
        else if (_hp <= 2) global.ai_adaptive_spawn_mult = 0.8;
        else if (_hp >= _max) global.ai_adaptive_spawn_mult = 1.05;

        if (_combo >= 30) global.ai_adaptive_spawn_mult *= 1.15;
        else if (_combo >= 20) global.ai_adaptive_spawn_mult *= 1.1;

        var _has_active_pu = obj_player.powerup_shield
            || obj_player.powerup_speed || obj_player.powerup_rapid
            || obj_player.powerup_ghost
            || obj_player.powerup_magnet || obj_player.powerup_score_x2 || obj_player.powerup_score_x3
            || obj_player.powerup_time_slow || obj_player.powerup_rage || obj_player.powerup_regen
            || obj_player.powerup_trippy || obj_player.powerup_disco
            || (weapon_get_effective_level() >= 3);

        if (!_has_active_pu && (current_time - global.ai_last_powerup_time) > 30000)
            global.ai_adaptive_powerup_mult = 2.0;
        else if (_has_active_pu)
            global.ai_adaptive_powerup_mult = 0.7;
        else
            global.ai_adaptive_powerup_mult = 1.0;
    }
}

function scr_music_ai_spawn_decision()
{
    var _section = "MAIN";
    if (instance_exists(obj_rhythm))
        _section = obj_rhythm.current_section;

    var _bass = global.energy_bass;
    var _mids = global.energy_mids;
    var _highs = global.energy_highs;
    var _onset = global.onset_intensity;
    var _strength = global.beat_strength;
    var _intensity = global.ai_intensity_score;

    var _base_count = 1;
    switch (_section)
    {
        case "INTRO":   _base_count = 1; break;
        case "BUILDUP": _base_count = 1; break;
        case "MAIN":    _base_count = 2; break;
        case "DROP":    _base_count = 2; break;
        case "BREAK":   _base_count = 1; break;
        case "OUTRO":   _base_count = 1; break;
    }

    if (_onset > 0.8 && random(1) < 0.25) _base_count += 1;
    if (_strength > 0.8 && random(1) < 0.2) _base_count += 1;

    _base_count = round(_base_count * global.ai_adaptive_spawn_mult);
    _base_count = clamp(_base_count, 0, 4);

    var _weights = { basic: 0.3, zigzag: 0.3, homing: 0.2, heavy: 0.2 };
    switch (_section)
    {
        case "INTRO":   _weights = { basic: 0.85, zigzag: 0.15, homing: 0.0, heavy: 0.0 }; break;
        case "BUILDUP": _weights = { basic: 0.35, zigzag: 0.40, homing: 0.20, heavy: 0.05 }; break;
        case "MAIN":    _weights = { basic: 0.20, zigzag: 0.30, homing: 0.35, heavy: 0.15 }; break;
        case "DROP":    _weights = { basic: 0.05, zigzag: 0.20, homing: 0.40, heavy: 0.35 }; break;
        case "BREAK":   _weights = { basic: 0.50, zigzag: 0.30, homing: 0.15, heavy: 0.05 }; break;
        case "OUTRO":   _weights = { basic: 0.40, zigzag: 0.35, homing: 0.20, heavy: 0.05 }; break;
    }

    if (_bass > 0.7) { _weights.heavy += 0.2; _weights.basic -= 0.1; }
    if (_highs > 0.6) { _weights.homing += 0.15; _weights.zigzag += 0.1; }
    if (_mids > 0.6) { _weights.zigzag += 0.15; _weights.homing += 0.1; }

    _weights.basic = max(0, _weights.basic);
    _weights.zigzag = max(0, _weights.zigzag);
    _weights.homing = max(0, _weights.homing);
    _weights.heavy = max(0, _weights.heavy);

    var _formation = "spread";
    if (_section == "DROP" && _intensity > 0.6)
        _formation = "line";
    else if (_section == "BUILDUP" && global.ai_drop_imminent)
        _formation = "V";
    else if (_section == "BREAK")
        _formation = "cluster";
    else if (_intensity > 0.8)
        _formation = "arc";

    global.ai_last_formation = _formation;
    global.ai_last_spawn_count = _base_count;
    global.ai_last_weights = _weights;

    return {
        count: _base_count,
        weights: _weights,
        formation: _formation,
        section: _section
    };
}

function scr_music_ai_control_enemies()
{
    if (global.on_beat && global.beat_strength > 0.6)
    {
        global.ai_beat_push_timer = 8;
    }

    if (global.ai_beat_push_timer > 0)
    {
        global.ai_beat_push_timer--;
        var _push_mult = 1 + (global.ai_beat_push_timer / 8) * 0.5;
        with (obj_enemy)
        {
            if (enemy_type == 3)
                vspeed += 0.15 * _push_mult;
            else if (enemy_type == 2)
            {
                if (instance_exists(obj_player))
                {
                    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                    hspeed += lengthdir_x(0.08 * _push_mult, _dir);
                }
            }
        }
    }

    if (global.onset_intensity > 0.7 && global.ai_onset_burst_timer <= 0)
    {
        global.ai_onset_burst_timer = 20;

        if (instance_exists(obj_player))
        {
            var _enemies = ds_list_create();
            with (obj_enemy)
            {
                if (enemy_type >= 1 && move_timer > 40 && burst_cooldown <= 0)
                    ds_list_add(_enemies, id);
            }

            var _pick = min(2, ds_list_size(_enemies));
            for (var _pi = 0; _pi < _pick; _pi++)
            {
                var _e = ds_list_find_value(_enemies, irandom(ds_list_size(_enemies) - 1));
                if (instance_exists(_e))
                {
                    var _b = instance_create_layer(_e.x, _e.y, "Instances", obj_enemy_bullet);
                    var _d = point_direction(_e.x, _e.y, obj_player.x, obj_player.y);
                    _b.hspeed = lengthdir_x(3.5, _d);
                    _b.vspeed = lengthdir_y(3.5, _d);
                    _b.image_angle = _d;
                    _e.image_blend = c_white;
                    _e.alarm[0] = 4;
                    _e.burst_cooldown = 30;
                }
                ds_list_delete(_enemies, irandom(ds_list_size(_enemies) - 1));
            }
            ds_list_destroy(_enemies);
        }
    }

    if (global.ai_onset_burst_timer > 0)
        global.ai_onset_burst_timer--;

    if (global.energy_bass > 0.8)
    {
        with (obj_enemy)
        {
            if (enemy_type == 3)
                vspeed += 0.08;
        }
    }
}

function scr_music_ai_control_environment()
{
    if (instance_exists(obj_rhythm) && obj_rhythm.music_started)
    {
        var _sec = obj_rhythm.current_section;
        switch (_sec)
        {
            case "DROP":  global.ai_camera_zoom_target = 1.03; break;
            case "BREAK": global.ai_camera_zoom_target = 0.97; break;
            default:      global.ai_camera_zoom_target = 1.0; break;
        }

        if (global.on_beat && global.beat_strength > 0.75)
            global.ai_camera_zoom_target += 0.008;

        global.ai_camera_zoom = lerp(global.ai_camera_zoom, global.ai_camera_zoom_target, 0.05);
    }

    if (global.section_flash > 0)
        global.section_flash = max(0, global.section_flash - 0.03);

    if (instance_exists(obj_player))
    {
        var _combo = obj_player.combo;
        if (_combo >= 20)
            global.combo_border_alpha = lerp(global.combo_border_alpha, 0.35, 0.08);
        else if (_combo >= 15)
            global.combo_border_alpha = lerp(global.combo_border_alpha, 0.25, 0.08);
        else if (_combo >= 10)
            global.combo_border_alpha = lerp(global.combo_border_alpha, 0.15, 0.08);
        else if (_combo >= 5)
            global.combo_border_alpha = lerp(global.combo_border_alpha, 0.08, 0.08);
        else
            global.combo_border_alpha = lerp(global.combo_border_alpha, 0, 0.1);
    }

    if (global.tutorial_text_timer > 0)
        global.tutorial_text_timer--;
}

function scr_music_ai_enemy_behavior(_enemy)
{
    var _section = "MAIN";
    if (instance_exists(obj_rhythm))
        _section = obj_rhythm.current_section;

    switch (_section)
    {
        case "INTRO":
            if (_enemy.enemy_type >= 1)
                _enemy.shoot_chance = 0.4;
            break;
        case "BUILDUP":
            if (_enemy.enemy_type >= 1)
                _enemy.shoot_chance = 0.65;
            break;
        case "MAIN":
            if (_enemy.enemy_type >= 1)
                _enemy.shoot_chance = 0.85;
            break;
        case "DROP":
            if (_enemy.enemy_type >= 1)
                _enemy.shoot_chance = 1.0;
            break;
        case "BREAK":
            _enemy.shoot_chance = 0.5;
            break;
        case "OUTRO":
            if (_enemy.enemy_type >= 1)
                _enemy.shoot_chance = 0.6;
            break;
    }
}

function scr_music_ai_spawn_formation(_decision, _wave)
{
    var _count = _decision.count;
    var _formation = _decision.formation;
    var _weights = _decision.weights;
    var _zones = _wave.spawn_zones;

    var _positions = [];
    var _total_w = _weights.basic + _weights.zigzag + _weights.homing + _weights.heavy;

    switch (_formation)
    {
        case "V":
            for (var _i = 0; _i < _count; _i++)
            {
                var _cx = room_width / 2;
                var _spread = 80 + _i * 40;
                var _offx = (_i mod 2 == 0) ? -_spread : _spread;
                var _offy = -abs(_i * 20);
                array_push(_positions, { x: _cx + _offx, y: 60 + _offy });
            }
            break;
        case "line":
            var _line_w = room_width * 0.7;
            var _start_x = (room_width - _line_w) / 2;
            for (var _i = 0; _i < _count; _i++)
            {
                var _lx = _start_x + (_line_w / max(1, _count - 1)) * _i;
                array_push(_positions, { x: _lx, y: irandom_range(40, 120) });
            }
            break;
        case "arc":
            for (var _i = 0; _i < _count; _i++)
            {
                var _ang = 180 + (_i / max(1, _count - 1)) * 180;
                var _arc_r = 120;
                var _ax = room_width / 2 + lengthdir_x(_arc_r, _ang);
                var _ay = 100 + lengthdir_y(_arc_r * 0.4, _ang);
                array_push(_positions, { x: _ax, y: _ay });
            }
            break;
        case "cluster":
            for (var _i = 0; _i < _count; _i++)
            {
                array_push(_positions, {
                    x: room_width / 2 + random_range(-60, 60),
                    y: irandom_range(40, 140)
                });
            }
            break;
        default:
            for (var _i = 0; _i < _count; _i++)
            {
                var _zone = _i mod 3;
                if (!_zones[_zone]) _zone = 1;
                var _zx;
                switch (_zone)
                {
                    case 0: _zx = irandom_range(48, room_width * 0.33); break;
                    case 1: _zx = irandom_range(room_width * 0.33, room_width * 0.66); break;
                    case 2: _zx = irandom_range(room_width * 0.66, room_width - 48); break;
                }
                array_push(_positions, { x: _zx, y: irandom_range(-48, room_height * 0.2) });
            }
            break;
    }

    var _spawned = 0;
    for (var _i = 0; _i < array_length(_positions); _i++)
    {
        var _pos = _positions[_i];
        var _roll = random(_total_w);
        var _cum = 0;
        var _type = 0;
        _cum += _weights.basic;
        if (_roll < _cum) { _type = 0; }
        else { _cum += _weights.zigzag; if (_roll < _cum) { _type = 1; } else { _cum += _weights.homing; if (_roll < _cum) { _type = 2; } else { _type = 3; } } }

        var _enemy = instance_create_layer(_pos.x, _pos.y, "Instances", obj_enemy);
        _enemy.enemy_type = _type;
        _enemy.hp_multiplier = _wave.enemy_hp_mult * (1 + global.energy_bass * 0.2);
        _enemy.move_timer = irandom(100);
        scr_music_ai_enemy_behavior(_enemy);
        global.enemies_alive++;
        _spawned++;
    }

    return _spawned;
}
