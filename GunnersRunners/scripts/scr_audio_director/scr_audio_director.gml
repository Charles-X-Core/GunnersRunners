function scr_audio_director_init()
{
    global.director_events = [];
    global.director_event_index = 0;
    global.director_current_time = 0;

    global.director_enemy_score = 0.5;
    global.director_visual_score = 0.5;
    global.director_action_score = 0.5;
    global.director_speed_score = 0.5;
    global.director_tension = 0.0;
    global.director_emotion = "epic";
    global.director_density = 0.5;
    global.director_complexity = "medium";
    global.director_motion = 0.0;

    global.director_drop_active = false;
    global.director_fill_active = false;
    global.director_fill_timer = 0;
    global.director_silence_active = false;
    global.director_silence_timer = 0;
    global.director_crescendo_active = false;
    global.director_crescendo_rate = "slow";
    global.director_phrase_type = "verse";
    global.director_last_phrase_beats = 16;

    global.director_phrase_spawn_budget = 0;
    global.director_phrase_spawn_timer = 0;
}

function scr_audio_director_load(_analysis_struct)
{
    if (!variable_struct_exists(_analysis_struct, "events"))
        return false;

    global.director_events = _analysis_struct.events;
    global.director_event_index = 0;

    if (variable_struct_exists(_analysis_struct, "enemy_score"))
        global.director_enemy_scores = _analysis_struct.enemy_score;
    else
        global.director_enemy_scores = [];

    if (variable_struct_exists(_analysis_struct, "action_score"))
        global.director_action_scores = _analysis_struct.action_score;
    else
        global.director_action_scores = [];

    if (variable_struct_exists(_analysis_struct, "visual_score"))
        global.director_visual_scores = _analysis_struct.visual_score;
    else
        global.director_visual_scores = [];

    if (variable_struct_exists(_analysis_struct, "speed_score"))
        global.director_speed_scores = _analysis_struct.speed_score;
    else
        global.director_speed_scores = [];

    if (variable_struct_exists(_analysis_struct, "tension_curve"))
        global.director_tension_curve = _analysis_struct.tension_curve;
    else
        global.director_tension_curve = [];

    if (variable_struct_exists(_analysis_struct, "emotion_curve"))
        global.director_emotion_curve = _analysis_struct.emotion_curve;
    else
        global.director_emotion_curve = [];

    if (variable_struct_exists(_analysis_struct, "density_curve"))
        global.director_density_curve = _analysis_struct.density_curve;
    else
        global.director_density_curve = [];

    if (variable_struct_exists(_analysis_struct, "complexity_curve"))
        global.director_complexity_curve = _analysis_struct.complexity_curve;
    else
        global.director_complexity_curve = [];

    if (variable_struct_exists(_analysis_struct, "motion_curve"))
        global.director_motion_curve = _analysis_struct.motion_curve;
    else
        global.director_motion_curve = [];

    return true;
}

function scr_audio_director_update(_current_time_sec)
{
    global.director_current_time = _current_time_sec;

    var _chunk = floor(_current_time_sec / 0.5);
    var _chunk_count = array_length(global.director_enemy_scores);
    if (_chunk_count > 0)
    {
        _chunk = clamp(_chunk, 0, _chunk_count - 1);
        global.director_enemy_score = global.director_enemy_scores[_chunk];
        global.director_action_score = global.director_action_scores[_chunk];
        global.director_visual_score = global.director_visual_scores[_chunk];
        global.director_speed_score = global.director_speed_scores[_chunk];
    }

    var _tension_count = array_length(global.director_tension_curve);
    if (_tension_count > 0)
    {
        _chunk = clamp(_chunk, 0, _tension_count - 1);
        global.director_tension = global.director_tension_curve[_chunk];
    }

    var _emotion_count = array_length(global.director_emotion_curve);
    if (_emotion_count > 0)
    {
        _chunk = clamp(_chunk, 0, _emotion_count - 1);
        global.director_emotion = global.director_emotion_curve[_chunk];
    }

    var _density_count = array_length(global.director_density_curve);
    if (_density_count > 0)
    {
        _chunk = clamp(_chunk, 0, _density_count - 1);
        global.director_density = global.director_density_curve[_chunk];
    }

    var _complex_count = array_length(global.director_complexity_curve);
    if (_complex_count > 0)
    {
        _chunk = clamp(_chunk, 0, _complex_count - 1);
        global.director_complexity = global.director_complexity_curve[_chunk];
    }

    var _motion_count = array_length(global.director_motion_curve);
    if (_motion_count > 0)
    {
        _chunk = clamp(_chunk, 0, _motion_count - 1);
        global.director_motion = global.director_motion_curve[_chunk];
    }

    scr_audio_director_process_events(_current_time_sec);

    if (global.director_fill_timer > 0)
        global.director_fill_timer--;
    else
        global.director_fill_active = false;

    if (global.director_silence_timer > 0)
        global.director_silence_timer--;
    else
        global.director_silence_active = false;

    if (global.director_phrase_spawn_budget > 0)
        global.director_phrase_spawn_timer++;
}

function scr_audio_director_process_events(_current_time_sec)
{
    var _events = global.director_events;
    var _count = array_length(_events);
    var _idx = global.director_event_index;

    while (_idx < _count)
    {
        var _evt = _events[_idx];
        if (_evt.time > _current_time_sec)
            break;

        scr_audio_director_handle_event(_evt);
        _idx++;
    }

    global.director_event_index = _idx;
}

function scr_audio_director_handle_event(_evt)
{
    var _type = _evt.type;

    switch (_type)
    {
        case "DROP":
            global.director_drop_active = true;
            scr_screen_shake(8, 20);
            global.section_flash = 1.0;
            global.section_flash_r = 220;
            global.section_flash_g = 40;
            global.section_flash_b = 80;

            if (instance_exists(obj_player))
            {
                for (var _p = 0; _p < 12; _p++)
                {
                    var _pt = instance_create_layer(
                        room_width / 2 + random_range(-120, 120),
                        -16,
                        "Instances",
                        obj_particle
                    );
                    _pt.vx = random_range(-4, 4);
                    _pt.vy = random_range(2, 6);
                    _pt.size = random_range(4, 8);
                    _pt.color = make_color_rgb(255, 60, 80);
                    _pt.life = irandom_range(20, 40);
                    _pt.max_life = _pt.life;
                }
            }
            break;

        case "FILL":
            global.director_fill_active = true;
            global.director_fill_timer = 30;
            scr_screen_shake(3, 8);
            break;

        case "SILENCE":
            global.director_silence_active = true;
            global.director_silence_timer = round(_evt.duration * 60);
            break;

        case "CRESCENDO":
            global.director_crescendo_active = true;
            global.director_crescendo_rate = _evt.rate;
            break;

        case "PHRASE_START":
            global.director_phrase_type = _evt.phrase_type;
            global.director_last_phrase_beats = _evt.phrase_length;
            global.director_phrase_spawn_budget = 0;
            global.director_phrase_spawn_timer = 0;
            break;

        case "PHRASE_END":
            global.director_crescendo_active = false;
            break;

        case "REPETITION":
            break;
    }
}

function scr_audio_director_get_spawn_decision()
{
    var _enemy = global.director_enemy_score;
    var _action = global.director_action_score;
    var _speed = global.director_speed_score;
    var _tension = global.director_tension;
    var _density = global.director_density;

    var _count = 1;
    if (_action > 0.7)
        _count = 3;
    else if (_action > 0.5)
        _count = 2;
    else if (_action > 0.3)
        _count = 1;
    else
        _count = irandom(1);

    if (global.director_drop_active)
        _count = max(_count, 3);

    if (global.director_fill_active)
        _count = max(_count, 2);

    if (global.director_silence_active)
        _count = 0;

    _count = round(_count * global.ai_adaptive_spawn_mult);
    _count = clamp(_count, 0, 4);

    var _type = 0;
    if (_enemy > 0.7)
        _type = irandom_range(2, 3);
    else if (_enemy > 0.5)
        _type = irandom_range(1, 2);
    else if (_enemy > 0.3)
        _type = irandom(1);
    else
        _type = 0;

    if (global.director_drop_active && random(1) < 0.3)
        _type = max(_type, 2);

    if (_tension > 0.7 && random(1) < 0.2)
        _type = 3;

    var _formation = "spread";
    if (global.director_drop_active)
        _formation = "wall";
    else if (global.director_fill_active)
        _formation = "V";
    else if (_density > 0.7)
        _formation = "arc";
    else if (_density < 0.3)
        _formation = "cluster";

    return {
        count: _count,
        enemy_type: _type,
        formation: _formation,
        shoot_chance: 0.5 + _action * 0.5,
        enemy_score: _enemy,
        action_score: _action,
    };
}

function scr_audio_director_get_formation_positions(_count, _formation)
{
    var _positions = [];
    var _cx = room_width / 2;

    switch (_formation)
    {
        case "wall":
            var _wall_w = room_width * 0.75;
            var _start_x = (room_width - _wall_w) / 2;
            for (var _i = 0; _i < _count; _i++)
            {
                var _wx = _start_x + (_wall_w / max(1, _count - 1)) * _i;
                array_push(_positions, { x: _wx, y: irandom_range(-48, -16) });
            }
            break;

        case "V":
            for (var _i = 0; _i < _count; _i++)
            {
                var _spread = 70 + _i * 45;
                var _offx = (_i mod 2 == 0) ? -_spread : _spread;
                array_push(_positions, { x: _cx + _offx, y: irandom_range(-48, -20) - _i * 12 });
            }
            break;

        case "arc":
            var _arc_r = 110;
            for (var _i = 0; _i < _count; _i++)
            {
                var _ang = 180 + (_i / max(1, _count - 1)) * 180;
                var _ax = _cx + lengthdir_x(_arc_r, _ang);
                var _ay = irandom_range(-32, -8) + lengthdir_y(_arc_r * 0.35, _ang);
                array_push(_positions, { x: _ax, y: _ay });
            }
            break;

        case "cluster":
            for (var _i = 0; _i < _count; _i++)
            {
                array_push(_positions, {
                    x: _cx + random_range(-70, 70),
                    y: irandom_range(-48, -8)
                });
            }
            break;

        case "line":
            var _line_w = room_width * 0.6;
            var _lx_start = (room_width - _line_w) / 2;
            for (var _i = 0; _i < _count; _i++)
            {
                var _lx = (_count == 1) ? _cx : _lx_start + (_line_w / max(1, _count - 1)) * _i;
                array_push(_positions, { x: _lx, y: irandom_range(-32, 0) });
            }
            break;

        default:
            for (var _i = 0; _i < _count; _i++)
            {
                var _zx = irandom_range(64, room_width - 64);
                array_push(_positions, { x: _zx, y: irandom_range(-48, -8) });
            }
            break;
    }

    return _positions;
}

function scr_audio_director_should_slowmo()
{
    return global.director_silence_active;
}

function scr_audio_director_get_zoom_target()
{
    if (global.director_drop_active)
        return 1.04;
    if (global.director_fill_active)
        return 1.02;
    if (global.director_silence_active)
        return 0.96;
    if (global.director_tension > 0.7)
        return 1.02;
    return 1.0;
}

function scr_audio_director_get_shake_intensity()
{
    var _base = 0;
    if (global.director_drop_active)
        _base = 6;
    else if (global.director_tension > 0.7)
        _base = 3;
    else if (global.director_fill_active)
        _base = 2;

    return _base * (1 + global.director_motion * 0.5);
}

function scr_audio_director_get_enemy_behavior(_enemy)
{
    var _shoot = 0.5;

    if (global.director_drop_active)
        _shoot = 1.0;
    else if (global.director_tension > 0.7)
        _shoot = 0.9;
    else if (global.director_fill_active)
        _shoot = 0.7;
    else if (global.director_silence_active)
        _shoot = 0.2;

    _shoot += global.director_action_score * 0.3;
    _shoot = clamp(_shoot, 0, 1);

    _enemy.shoot_chance = _shoot;

    if (global.director_tension > 0.8 && _enemy.enemy_type >= 1)
        _enemy.shoot_chance = min(1.0, _shoot + 0.15);
}

function scr_audio_director_should_spawn_powerup()
{
    if (global.director_silence_active)
        return random(1) < 0.4;

    if (global.director_phrase_spawn_timer > 0 && (global.director_phrase_spawn_timer mod 60 == 0))
        return random(1) < 0.2;

    return false;
}
