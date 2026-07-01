move_timer++;

if (defeated)
{
    defeat_timer++;
    defeat_score_timer++;
    hspeed = sin(defeat_timer * 0.05) * 2;
    vspeed = 0;

    if (defeat_score_timer >= 90)
    {
        defeat_score_timer = 0;
        global.score += 50;
        scr_score_popup(x + random_range(-40, 40), y + random_range(-40, 40), 50, c_yellow);

        if (irandom(2) == 0)
        {
            var _exp = instance_create_layer(x + random_range(-50, 50), y + random_range(-50, 50), "Instances", obj_explosion);
        }
        for (var _dpi = 0; _dpi < 4; _dpi++)
        {
            var _dpt = instance_create_layer(x + random_range(-30, 30), y + random_range(-30, 30), "Instances", obj_particle);
            _dpt.vx = random_range(-4, 4);
            _dpt.vy = random_range(-4, 4);
            _dpt.size = random_range(2, 5);
            _dpt.color = make_color_hsv(random(255), 200, 255);
            _dpt.life = irandom_range(15, 30);
            _dpt.max_life = _dpt.life;
        }
    }

    image_blend = (defeat_timer mod 10 < 5) ? c_red : c_white;
    exit;
}

if (phase_transition_timer > 0)
{
    phase_transition_timer--;
    hspeed = 0;
    vspeed = 0;
    return;
}

var _hp_pct = hp / max_hp;
var _new_phase = 1;
if (_hp_pct <= 0.3) _new_phase = 3;
else if (_hp_pct <= 0.6) _new_phase = 2;

if (_new_phase != current_phase)
{
    current_phase = _new_phase;
    phase_transition_timer = 90;
    scr_screen_shake(12, 25);
    global.nuke_flash = 0.5;

    if (current_phase == 2)
    {
        var _wp_count = 3;
        weak_points = [];
        for (var _wi = 0; _wi < _wp_count; _wi++)
            array_push(weak_points, { hp: 4, max_hp: 4, angle: _wi * 120, alive: true, hit_flash: 0 });
        speed_val = 1.5;
    }
    else if (current_phase == 3)
    {
        var _wp_count = 4;
        weak_points = [];
        for (var _wi = 0; _wi < _wp_count; _wi++)
            array_push(weak_points, { hp: 3, max_hp: 3, angle: _wi * 90, alive: true, hit_flash: 0 });
        speed_val = 2.2;
    }

    for (var _ti = 0; _ti < 16; _ti++)
    {
        var _tp = instance_create_layer(x, y, "Instances", obj_particle);
        _tp.vx = random_range(-6, 6);
        _tp.vy = random_range(-6, 6);
        _tp.size = random_range(3, 8);
        _tp.color = (current_phase == 2) ? make_color_rgb(180, 50, 255) : make_color_rgb(255, 60, 30);
        _tp.life = irandom_range(30, 50);
        _tp.max_life = _tp.life;
    }
    return;
}

if (instance_exists(obj_rhythm) && global.level_data != -1)
{
    var _total_beats = 0;
    for (var _wvi = 0; _wvi < array_length(global.level_data.waves); _wvi++)
        _total_beats += global.level_data.waves[_wvi].total_beats;
    if (_total_beats > 0)
        song_progress = global.wave_beat_count / max(1, _total_beats);
    for (var _wvi2 = 0; _wvi2 < global.current_wave_index; _wvi2++)
        song_progress += global.level_data.waves[_wvi2].total_beats / max(1, _total_beats);
}

if (song_progress >= 0.85 && !desperation_mode)
    desperation_mode = true;

if (desperation_mode && !beam_active)
{
    beam_charge += 0.003;
    if (beam_charge >= 1.0 && !beam_active)
    {
        beam_active = true;
        beam_timer = 150;
    }
}

if (beam_active)
{
    beam_timer--;
    if (beam_timer <= 0)
    {
        if (instance_exists(obj_player) && !obj_player.invincible && !obj_player.dead)
        {
            scr_damage_player();
            scr_damage_player();
            scr_damage_player();
        }
        beam_active = false;
        beam_charge = 0;
    }
    hspeed = 0;
    vspeed = 0;
    for (var _wli = 0; _wli < array_length(weak_points); _wli++)
    {
        var _wp = weak_points[_wli];
        if (_wp.alive)
        {
            _wp.hp = 0;
            _wp.alive = false;
        }
    }
    global.enemies_alive = 0;
    hp = 0;
    global.score += score_value * (1 + obj_player.combo);
    scr_screen_shake(20, 40);
    global.nuke_flash = 1.0;
    for (var _ei = 0; _ei < 8; _ei++)
    {
        var _exp = instance_create_layer(x + random_range(-60, 60), y + random_range(-60, 60), "Instances", obj_explosion);
    }
    for (var _pi = 0; _pi < 32; _pi++)
    {
        var _pt = instance_create_layer(x, y, "Instances", obj_particle);
        _pt.vx = random_range(-8, 8);
        _pt.vy = random_range(-8, 8);
        _pt.size = random_range(3, 10);
        _pt.color = make_color_hsv(random(255), 200, 255);
        _pt.life = irandom_range(40, 80);
        _pt.max_life = _pt.life;
    }
    if (instance_exists(obj_rhythm) && !obj_rhythm.music_failed)
        rhythm_stop_music(obj_rhythm);
    if (global.level_data != -1 && global.current_wave_index >= array_length(global.level_data.waves) - 1)
        global.game_state = "VICTORY";
    instance_destroy();
    return;
}

var _slow_mult = 1;
if (instance_exists(obj_player) && obj_player.powerup_time_slow)
    _slow_mult = 0.5;

if (y < 100)
{
    vspeed = 1.5 * _slow_mult;
}
else
{
    vspeed = 0;
    switch (current_phase)
    {
        case 1:
            hspeed = sin(move_timer * 0.02) * 3 * _slow_mult;
            break;
        case 2:
            hspeed = sin(move_timer * 0.03) * 4 * _slow_mult;
            vspeed = sin(move_timer * 0.015) * 1.5 * _slow_mult;
            break;
        case 3:
            hspeed = sin(move_timer * 0.04) * 5 * _slow_mult;
            if (rush_cooldown > 0) rush_cooldown--;
            if (rush_cooldown <= 0 && instance_exists(obj_player) && move_timer mod 180 < 20)
            {
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                hspeed = lengthdir_x(8, _dir) * _slow_mult;
                vspeed = lengthdir_y(6, _dir) * _slow_mult;
                rush_cooldown = 180;
            }
            break;
    }
}

for (var _wpi = 0; _wpi < array_length(weak_points); _wpi++)
{
    var _wp = weak_points[_wpi];
    if (!_wp.alive) continue;
    var _wp_angle_speed;
    if (current_phase == 3) _wp_angle_speed = 4;
    else if (current_phase == 2) _wp_angle_speed = 2.5;
    else _wp_angle_speed = 1.5;
    _wp.angle += _wp_angle_speed;
    if (_wp.hit_flash > 0) _wp.hit_flash--;
}

minion_timer++;
if (current_phase >= 2 && minion_timer >= 480 && y >= 80)
{
    minion_timer = 0;
    var _minion_count = (current_phase == 3) ? 3 : 2;
    for (var _mi = 0; _mi < _minion_count; _mi++)
    {
        var _mx = x + random_range(-120, 120);
        var _my = y - 80 + random_range(-20, 20);
        var _mn = instance_create_layer(_mx, _my, "Instances", obj_enemy);
        _mn.enemy_type = irandom_range(0, 2);
        _mn.hp_multiplier = 0.6;
        _mn.shoot_chance = 0.5;
        global.enemies_alive++;
    }
}

if (place_meeting(x, y, obj_bullet))
{
    var _bullet = instance_place(x, y, obj_bullet);
    if (_bullet != noone)
    {
        hp--;
        with (_bullet) instance_destroy();
        scr_screen_shake(3, 6);
        image_blend = c_red;
        alarm[0] = 4;

        for (var _hi = 0; _hi < 2; _hi++)
        {
            var _hp2 = instance_create_layer(x + random_range(-30, 30), y + random_range(-30, 30), "Instances", obj_particle);
            _hp2.vx = random_range(-3, 3);
            _hp2.vy = random_range(-3, 3);
            _hp2.size = random_range(3, 6);
            _hp2.color = make_color_rgb(255, 100 + irandom(100), 50);
            _hp2.life = irandom_range(10, 18);
            _hp2.max_life = _hp2.life;
        }

        if (hp <= 0)
        {
            global.score += score_value * (1 + obj_player.combo * 0.1);
            global.enemies_alive--;
            obj_player.combo++;
            obj_player.combo_timer = obj_player.combo_max;
            scr_score_popup(x, y, score_value, c_yellow);

            scr_screen_shake(15, 30);
            global.nuke_flash = 0.8;

            for (var _ei2 = 0; _ei2 < 5; _ei2++)
            {
                var _ex2 = x + random_range(-50, 50);
                var _ey2 = y + random_range(-50, 50);
                var _exp2 = instance_create_layer(_ex2, _ey2, "Instances", obj_explosion);
            }

            for (var _pi2 = 0; _pi2 < 24; _pi2++)
            {
                var _pt2 = instance_create_layer(x, y, "Instances", obj_particle);
                _pt2.vx = random_range(-7, 7);
                _pt2.vy = random_range(-7, 7);
                _pt2.size = random_range(3, 8);
                _pt2.color = make_color_hsv(random(255), 200, 255);
                _pt2.life = irandom_range(30, 60);
                _pt2.max_life = _pt2.life;
            }

            defeated = true;
            defeat_timer = 0;
            defeat_score_timer = 0;
            global.boss_defeated = true;
        }
    }
}

shoot_timer++;
var _shoot_cd;
if (current_phase == 3) _shoot_cd = 18;
else if (current_phase == 2) _shoot_cd = 28;
else _shoot_cd = 35;
_shoot_cd += irandom(10);
if (shoot_timer >= _shoot_cd && y >= 80 && !beam_active)
{
    shoot_timer = 0;
    shoot_pattern = (shoot_pattern + 1) mod 4;

    switch (shoot_pattern)
    {
        case 0:
            var _count8 = (current_phase >= 2) ? 12 : 8;
            for (var i = 0; i < _count8; i++)
            {
                var _angle = i * (360 / _count8);
                var _b = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                _b.hspeed = lengthdir_x(3, _angle);
                _b.vspeed = lengthdir_y(3, _angle);
                _b.image_angle = _angle;
            }
            break;

        case 1:
            if (instance_exists(obj_player))
            {
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                var _fan = (current_phase >= 2) ? 4 : 3;
                var _spread = (current_phase >= 2) ? 8 : 10;
                for (var _s = -_fan; _s <= _fan; _s++)
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    _b.hspeed = lengthdir_x(3.5, _dir + _s * _spread);
                    _b.vspeed = lengthdir_y(3.5, _dir + _s * _spread);
                    _b.image_angle = _dir + _s * _spread;
                }
            }
            break;

        case 2:
            var _count12 = (current_phase >= 2) ? 16 : 12;
            for (var i = 0; i < _count12; i++)
            {
                var _angle = i * (360 / _count12) + move_timer;
                var _b = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                _b.hspeed = lengthdir_x(2.5, _angle);
                _b.vspeed = lengthdir_y(2.5, _angle);
                _b.image_angle = _angle;
            }
            break;

        case 3:
            if (instance_exists(obj_player))
            {
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                var _fan3 = (current_phase >= 2) ? 5 : 3;
                var _spread3 = (current_phase >= 2) ? 12 : 15;
                for (var _s = -_fan3; _s <= _fan3; _s++)
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    _b.hspeed = lengthdir_x(2, _dir + _s * _spread3);
                    _b.vspeed = lengthdir_y(2, _dir + _s * _spread3);
                    _b.image_angle = _dir + _s * _spread3;
                }
            }
            break;
    }
}
