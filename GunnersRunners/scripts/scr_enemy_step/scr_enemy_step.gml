function scr_enemy_step()
{
    if (hp <= 0)
    {
        if (variable_instance_exists(id, "is_grabbing") && is_grabbing)
        {
            if (instance_exists(obj_player))
            {
                obj_player.is_grabbed = false;
                obj_player.grabbed_by = noone;
                obj_player.grab_shake_input = 0;
                obj_player.invincible = true;
                obj_player.invincible_timer = 60;
            }
        }

        var _score_mult = 1;
        if (instance_exists(obj_player))
        {
            if (obj_player.powerup_score_x2) _score_mult = 2;
            if (obj_player.powerup_score_x3) _score_mult = 3;
        }
        var _final_score = floor(score_value * (1 + obj_player.combo * 0.1) * _score_mult);
        global.score += _final_score;
        global.enemies_alive--;
        global.enemies_killed++;
        if (variable_instance_exists(id, "enemy_type") && enemy_type >= 4)
            global.stats_elites_killed++;
        obj_player.combo++;
        obj_player.combo_timer = obj_player.combo_max;
        scr_score_popup(x, y, _final_score, c_yellow);
        scr_screen_shake(3, 8);

        var _pu_chance = 0.12 + min(obj_player.combo * 0.01, 0.12);
        if (random(1) < _pu_chance)
        {
            var _count = 1;
            if (obj_player.combo >= 8 && random(1) < 0.3)
                _count = 2;
            if (obj_player.combo >= 16 && random(1) < 0.15)
                _count = 3;

            for (var _p = 0; _p < _count; _p++)
            {
                var _pu = instance_create_layer(x + random_range(-20, 20), y, "Instances", obj_powerup);
                _pu.vspeed = random_range(0.8, 2.0);
                _pu.hspeed = random_range(-1.5, 1.5);
                _pu.powerup_type = scr_powerup_select_drop();
                _pu.lifetime = irandom_range(360, 540);
            }
        }

        var _death_colors = [
            make_color_rgb(255, 60, 60),
            make_color_rgb(255, 160, 40),
            make_color_rgb(180, 60, 255),
            make_color_rgb(200, 30, 30),
            make_color_rgb(100, 150, 220),
            make_color_rgb(255, 100, 50),
            make_color_rgb(180, 200, 255)
        ];
        var _death_counts = [6, 8, 8, 14, 12, 16, 10];
        var _dc = _death_colors[clamp(enemy_type, 0, 6)];
        var _dn = _death_counts[clamp(enemy_type, 0, 6)];
        for (var _pi = 0; _pi < _dn; _pi++)
        {
            var _pt = instance_create_layer(x, y, "Instances", obj_particle);
            _pt.vx = random_range(-5, 5);
            _pt.vy = random_range(-5, 5);
            _pt.size = random_range(2, 6);
            _pt.color = _dc;
            _pt.life = irandom_range(20, 40);
            _pt.max_life = _pt.life;
        }

        instance_destroy();
        return;
    }

    if (y > room_height + 32 || x < -80 || x > room_width + 80)
    {
        global.enemies_alive--;
        instance_destroy();
        return;
    }

    if (variable_instance_exists(id, "is_grabbing") && is_grabbing)
    {
        grab_timer++;
        var _intensity = clamp((global.energy_bass - 0.65) / 0.35, 0, 1);

        if (instance_exists(obj_player) && instance_exists(grabbed_by))
        {
            var _pull = 0.03 + _intensity * 0.07;
            obj_player.x = lerp(obj_player.x, x, _pull);
            obj_player.y = lerp(obj_player.y, y, _pull);
            obj_player.hspeed *= 0.7;
            obj_player.vspeed *= 0.7;

            var _dmg_interval = 60 - floor(_intensity * 35);
            var _dmg_amount = 1;
            if (_intensity > 0.85) _dmg_amount = 2;

            if (grab_timer mod max(10, _dmg_interval) == 0)
            {
                for (var _da = 0; _da < _dmg_amount; _da++)
                    with (obj_player) scr_player_hurt();
                scr_screen_shake(3 + _intensity * 4, 6 + _intensity * 6);
            }

            var _max_duration = 90 + floor(_intensity * 60);
            var _threshold = 12 + floor(_intensity * 13);

            if (instance_exists(obj_player) && obj_player.grab_shake_input >= _threshold)
            {
                is_grabbing = false;
                if (instance_exists(obj_player))
                {
                    obj_player.is_grabbed = false;
                    obj_player.grabbed_by = noone;
                    obj_player.grab_shake_input = 0;
                    obj_player.invincible = true;
                    obj_player.invincible_timer = 60;
                }
                hit_timer = 30 + floor(_intensity * 30);
                scr_screen_shake(5, 12);
            }

            if (grab_timer >= _max_duration)
            {
                with (obj_player)
                {
                    scr_player_hurt();
                    scr_player_hurt();
                    is_grabbed = false;
                    grabbed_by = noone;
                    grab_shake_input = 0;
                }
                global.enemies_alive--;
                instance_destroy();
                return;
            }
        }
        else
        {
            is_grabbing = false;
            if (instance_exists(obj_player))
            {
                obj_player.is_grabbed = false;
                obj_player.grabbed_by = noone;
            }
        }
        return;
    }

    if (place_meeting(x, y, obj_player))
    {
        if (!obj_player.invincible && !obj_player.dead)
        {
            var _can_grab = false;
            if (enemy_type >= 4 && enemy_type <= 6
                && global.energy_bass > 0.65
                && !obj_player.is_grabbed)
            {
                var _grab_intensity = clamp((global.energy_bass - 0.65) / 0.35, 0, 1);
                var _grab_chance = 0.15 + _grab_intensity * 0.25;
                if (global.on_beat) _grab_chance += 0.10;
                if (global.beat_strength > 0.8) _grab_chance += 0.10;

                if (random(1) < _grab_chance)
                    _can_grab = true;
            }

            if (_can_grab)
            {
                is_grabbing = true;
                grab_timer = 0;
                grabbed_by = id;
                obj_player.is_grabbed = true;
                obj_player.grabbed_by = id;
                obj_player.grab_shake_input = 0;
                obj_player.grab_last_dir = -1;
                obj_player.hspeed = 0;
                obj_player.vspeed = 0;
                scr_screen_shake(6, 15);
                return;
            }
            else
            {
                scr_damage_player();
                scr_screen_shake(4, 10);
            }
        }
        instance_destroy();
        return;
    }

    move_timer++;

    if (variable_instance_exists(id, "hit_timer") && hit_timer > 0)
        hit_timer--;

    if (variable_instance_exists(id, "prev_positions"))
    {
        trail_counter++;
        if (trail_counter >= 3)
        {
            trail_counter = 0;
            array_push(prev_positions, { x: x, y: y });
            if (array_length(prev_positions) > 5)
                array_delete(prev_positions, 0, 1);
        }
    }

    var _wn = global.wave;
    var _energy = global.music_energy;
    var _slow_mult = 1;
    if (instance_exists(obj_player) && obj_player.powerup_time_slow)
        _slow_mult = 0.5;

    switch (enemy_type)
    {
        case 0:
            if (_wn <= 2)
            {
                vspeed = speed_val * _slow_mult;
                hspeed = 0;
            }
            else if (_wn <= 4)
            {
                vspeed = speed_val * _slow_mult;
                hspeed = sin(move_timer * 0.04) * (1 + _energy * 2) * _slow_mult;
            }
            else if (_wn <= 6)
            {
                vspeed = speed_val * (1 + _energy * 0.3) * _slow_mult;
                hspeed = sin(move_timer * 0.06) * (2 + _energy * 2) * _slow_mult;
            }
            else
            {
                vspeed = speed_val * (1.2 + _energy * 0.4) * _slow_mult;
                hspeed = sin(move_timer * 0.08) * (3 + _energy * 3) * _slow_mult;
            }
            break;

        case 1:
            if (_wn <= 2)
            {
                vspeed = speed_val * _slow_mult;
                hspeed = sin(move_timer * 0.06) * 3 * _slow_mult;
            }
            else if (_wn <= 4)
            {
                vspeed = speed_val * (1 + _energy * 0.2) * _slow_mult;
                hspeed = sin(move_timer * 0.08) * 4 * _slow_mult;
            }
            else if (_wn <= 6)
            {
                vspeed = speed_val * 1.1 * _slow_mult;
                hspeed = cos(move_timer * 0.07 + 1.5) * 5 * _slow_mult;
                if (move_timer mod 150 < 30)
                    vspeed = speed_val * 0.4 * _slow_mult;
            }
            else
            {
                vspeed = speed_val * (1 + _energy * 0.3) * _slow_mult;
                hspeed = cos(move_timer * 0.09 + 1.5) * 6 * _slow_mult;
                if (move_timer mod 100 < 20)
                    vspeed = speed_val * 0.3 * _slow_mult;
                else if (move_timer mod 100 > 80)
                    vspeed = speed_val * 1.6 * _slow_mult;
            }
            break;

        case 2:
            if (instance_exists(obj_player))
            {
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                if (_wn <= 2)
                {
                    hspeed = lengthdir_x(speed_val * 0.6, _dir) * _slow_mult;
                    vspeed = lengthdir_y(speed_val * 0.6, _dir) * _slow_mult;
                }
                else if (_wn <= 4)
                {
                    hspeed = lengthdir_x(speed_val * 0.8, _dir) * _slow_mult;
                    vspeed = lengthdir_y(speed_val * 0.8, _dir) * _slow_mult;
                }
                else if (_wn <= 6)
                {
                    var _strafe = sin(move_timer * 0.12) * 2.5 * _slow_mult;
                    hspeed = lengthdir_x(speed_val * 0.9, _dir) * _slow_mult + lengthdir_x(_strafe, _dir + 90);
                    vspeed = lengthdir_y(speed_val * 0.9, _dir) * _slow_mult + lengthdir_y(_strafe, _dir + 90);
                }
                else
                {
                    var _strafe = sin(move_timer * 0.15) * (3 + _energy * 2) * _slow_mult;
                    hspeed = lengthdir_x(speed_val, _dir) * _slow_mult + lengthdir_x(_strafe, _dir + 90);
                    vspeed = lengthdir_y(speed_val, _dir) * _slow_mult + lengthdir_y(_strafe, _dir + 90);
                }
            }
            break;

        case 3:
            if (_wn <= 3)
            {
                vspeed = speed_val * 0.4 * _slow_mult;
                hspeed = sin(move_timer * 0.03) * 4 * _slow_mult;
            }
            else if (_wn <= 5)
            {
                vspeed = speed_val * 0.5 * _slow_mult;
                hspeed = sin(move_timer * 0.04) * 5 * _slow_mult;
                if (move_timer mod 200 < 35)
                    vspeed = speed_val * 1.3 * _slow_mult;
            }
            else if (_wn <= 7)
            {
                vspeed = speed_val * (0.5 + _energy * 0.3) * _slow_mult;
                hspeed = cos(move_timer * 0.05) * 6 * _slow_mult;
                if (move_timer mod 150 < 25)
                {
                    vspeed = speed_val * 1.5 * _slow_mult;
                    hspeed *= 1.5;
                }
            }
            else
            {
                vspeed = speed_val * (0.6 + _energy * 0.4) * _slow_mult;
                hspeed = cos(move_timer * 0.06 + 2) * 7 * _slow_mult;
                if (move_timer mod 100 < 20)
                {
                    vspeed = speed_val * 2 * _slow_mult;
                    hspeed = lengthdir_x(4, point_direction(x, y, room_width / 2, room_height)) * _slow_mult;
                }
            }
            break;

        case 4:
            if (!variable_instance_exists(id, "shield_hp")) shield_hp = 5;
            if (!variable_instance_exists(id, "shield_max_hp")) shield_max_hp = 5;
            if (!variable_instance_exists(id, "shield_regen_timer")) shield_regen_timer = 0;
            vspeed = speed_val * 0.5 * _slow_mult;
            hspeed = sin(move_timer * 0.025) * (3 + _energy * 2) * _slow_mult;
            if (variable_struct_exists(id, "shield_regen_timer"))
            {
                shield_regen_timer++;
                if (shield_regen_timer >= 300 && shield_hp < shield_max_hp)
                {
                    shield_hp = min(shield_hp + 1, shield_max_hp);
                    shield_regen_timer = 0;
                }
            }
            break;

        case 5:
            if (!variable_instance_exists(id, "max_hp")) max_hp = hp;
            if (!variable_instance_exists(id, "is_raging")) is_raging = false;
            if (!variable_instance_exists(id, "dash_timer")) dash_timer = 0;
            if (hp < max_hp * 0.5 && !is_raging)
            {
                is_raging = true;
                speed_val *= 1.4;
            }
            dash_timer++;
            if (is_raging && dash_timer > 90 && instance_exists(obj_player))
            {
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                hspeed = lengthdir_x(speed_val * 3, _dir) * _slow_mult;
                vspeed = lengthdir_y(speed_val * 3, _dir) * _slow_mult;
                if (dash_timer > 105)
                    dash_timer = 0;
            }
            else
            {
                hspeed = sin(move_timer * 0.07) * (4 + _energy * 3) * _slow_mult;
                vspeed = speed_val * (0.6 + _energy * 0.3) * _slow_mult;
            }
            break;

        case 6:
            if (!variable_instance_exists(id, "laser_charge")) laser_charge = 0;
            if (!variable_instance_exists(id, "laser_firing")) laser_firing = 0;
            if (!variable_instance_exists(id, "laser_cooldown")) laser_cooldown = 0;
            if (y < room_height * 0.15)
                vspeed = speed_val * 2 * _slow_mult;
            else
            {
                vspeed = 0;
                hspeed = sin(move_timer * 0.02) * (2 + _energy) * _slow_mult;
            }
            if (y > room_height * 0.25)
                y = lerp(y, room_height * 0.2, 0.02);
            break;
    }

    if (x < 48) { x = 48; hspeed = abs(hspeed); }
    if (x > room_width - 48) { x = room_width - 48; hspeed = -abs(hspeed); }

    if (enemy_type >= 1 && instance_exists(obj_player) && !obj_player.dead)
    {
        if (burst_cooldown > 0) burst_cooldown--;

        var _can_shoot = false;

        if (enemy_type == 4)
        {
            if (variable_struct_exists(id, "shield_hp") && shield_hp > 0)
            {
                _can_shoot = false;
            }
            else
            {
                if (instance_exists(obj_rhythm) && obj_rhythm.music_started && !obj_rhythm.music_failed)
                    _can_shoot = global.on_beat && (move_timer > 60) && (random(1) < shoot_chance * 0.6);
                else
                    _can_shoot = (move_timer mod 150 == 0) && (random(1) < shoot_chance);
            }
        }
        else if (enemy_type == 5)
        {
            if (instance_exists(obj_rhythm) && obj_rhythm.music_started && !obj_rhythm.music_failed)
            {
                if (is_raging)
                    _can_shoot = global.on_beat && (move_timer > 30) && (random(1) < shoot_chance);
                else
                    _can_shoot = global.on_beat && (move_timer > 40) && (random(1) < shoot_chance);
            }
            else
            {
                var _shoot_cd = is_raging ? 50 : 80;
                _can_shoot = (move_timer mod _shoot_cd == 0) && (random(1) < shoot_chance);
            }
        }
        else if (enemy_type == 6)
        {
            if (laser_firing > 0)
            {
                laser_firing--;
                if (laser_firing == 0)
                {
                    if (instance_exists(obj_player))
                    {
                        var _dx = abs(x - obj_player.x);
                        if (_dx < 30 && obj_player.y > y)
                            scr_damage_player();
                    }
                    laser_cooldown = 180;
                }
            }
            else if (laser_cooldown > 0)
            {
                laser_cooldown--;
            }
            else
            {
                laser_charge += 0.012;
                if (laser_charge >= 1.0)
                {
                    laser_firing = 30;
                    laser_charge = 0;
                }
            }
            _can_shoot = false;
        }
        else
        {
            if (instance_exists(obj_rhythm) && obj_rhythm.music_started && !obj_rhythm.music_failed)
            {
                _can_shoot = global.on_beat && (move_timer > 40) && (random(1) < shoot_chance);
            }
            else
            {
                var _shoot_cd = 100 + (_wn * 10);
                _can_shoot = (move_timer mod _shoot_cd == 0) && (random(1) < shoot_chance);
            }
        }

        if (_can_shoot && y > 0 && y < room_height * 0.6)
        {
            var _b_spd = 2.5 + (_wn * 0.1);

            if (enemy_type == 5 && is_raging && burst_cooldown <= 0)
            {
                burst_count = 0;
                for (var _bi = 0; _bi < 3; _bi++)
                {
                    var _eb = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    var _dir = point_direction(x, y, obj_player.x, obj_player.y) + ((_bi - 1) * 15);
                    _eb.hspeed = lengthdir_x(_b_spd * 1.3, _dir);
                    _eb.vspeed = lengthdir_y(_b_spd * 1.3, _dir);
                    _eb.image_angle = _dir;
                }
                burst_cooldown = 25;
            }
            else if (_wn >= 7 && enemy_type == 1)
            {
                for (var _s = -1; _s <= 1; _s += 2)
                {
                    var _eb = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    var _dir = point_direction(x, y, obj_player.x, obj_player.y) + (_s * 12);
                    _eb.hspeed = lengthdir_x(_b_spd, _dir);
                    _eb.vspeed = lengthdir_y(_b_spd, _dir);
                    _eb.image_angle = _dir;
                }
            }
            else if (_wn >= 8 && enemy_type == 3)
            {
                for (var _s = -1; _s <= 1; _s++)
                {
                    var _eb = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    var _dir = point_direction(x, y, obj_player.x, obj_player.y) + (_s * 15);
                    _eb.hspeed = lengthdir_x(_b_spd, _dir);
                    _eb.vspeed = lengthdir_y(_b_spd, _dir);
                    _eb.image_angle = _dir;
                }
            }
            else if (enemy_type == 4)
            {
                for (var _s = -2; _s <= 2; _s++)
                {
                    var _eb = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                    var _dir = point_direction(x, y, obj_player.x, obj_player.y) + (_s * 20);
                    _eb.hspeed = lengthdir_x(_b_spd * 0.8, _dir);
                    _eb.vspeed = lengthdir_y(_b_spd * 0.8, _dir);
                    _eb.image_angle = _dir;
                }
            }
            else
            {
                var _eb = instance_create_layer(x, y, "Instances", obj_enemy_bullet);
                var _dir = point_direction(x, y, obj_player.x, obj_player.y);
                _eb.hspeed = lengthdir_x(_b_spd, _dir);
                _eb.vspeed = lengthdir_y(_b_spd, _dir);
                _eb.image_angle = _dir;
            }
        }
    }

    image_angle += 2;
}

function scr_enemy_draw_shape(_type, _x, _y, _size, _angle)
{
    switch (_type)
    {
        case 0:
            draw_triangle(
                _x, _y - _size,
                _x - _size * 0.7, _y + _size * 0.6,
                _x + _size * 0.7, _y + _size * 0.6,
                false);
            break;

        case 1:
            var _w = _size * 0.6;
            var _h = _size;
            draw_triangle(_x, _y - _h, _x + _w, _y, _x, _y + _h, false);
            draw_triangle(_x, _y - _h, _x - _w, _y, _x, _y + _h, false);
            break;

        case 2:
            var _r = _size * 0.85;
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x, _y);
            for (var _i = 0; _i <= 6; _i++)
            {
                var _a = _i * 60 - 30;
                draw_vertex(_x + lengthdir_x(_r, _a), _y + lengthdir_y(_r, _a));
            }
            draw_primitive_end();
            break;

        case 3:
            var _hs = _size * 0.85;
            draw_rectangle(_x - _hs, _y - _hs, _x + _hs, _y + _hs, false);
            var _hs2 = _hs * 0.6;
            draw_set_color(merge_color(draw_get_color(), c_black, 0.3));
            draw_rectangle(_x - _hs2, _y - _hs2, _x + _hs2, _y + _hs2, false);
            break;

        case 4:
            var _r = _size * 0.9;
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(_x, _y);
            for (var _i = 0; _i <= 5; _i++)
            {
                var _a = _i * 72 - 90;
                draw_vertex(_x + lengthdir_x(_r, _a), _y + lengthdir_y(_r, _a));
            }
            draw_primitive_end();
            break;

        case 5:
            draw_triangle(
                _x, _y - _size * 1.1,
                _x - _size * 0.8, _y + _size * 0.7,
                _x + _size * 0.8, _y + _size * 0.7,
                false);
            draw_set_color(merge_color(draw_get_color(), c_black, 0.35));
            var _inner = _size * 0.5;
            draw_triangle(
                _x, _y - _inner,
                _x - _inner * 0.6, _y + _inner * 0.5,
                _x + _inner * 0.6, _y + _inner * 0.5,
                false);
            break;

        case 6:
            draw_circle(_x, _y, _size * 0.7, false);
            draw_set_color(merge_color(draw_get_color(), c_white, 0.4));
            draw_circle(_x, _y, _size * 0.35, false);
            break;
    }
}

function scr_powerup_select_drop()
{
    var _wn = global.wave;
    var _combo = instance_exists(obj_player) ? obj_player.combo : 0;
    var _hp = instance_exists(obj_player) ? obj_player.hp : 6;
    var _energy = global.music_energy;

    var _pool = [];

    array_push(_pool, { id: 0,  weight: 6 });
    array_push(_pool, { id: 1,  weight: (_wn >= 3) ? 8 : 0 });
    array_push(_pool, { id: 2,  weight: 10 });
    array_push(_pool, { id: 3,  weight: 10 });
    array_push(_pool, { id: 4,  weight: (_wn >= 3) ? 4 : 0 });
    array_push(_pool, { id: 5,  weight: (_wn >= 2) ? 8 : 0 });
    array_push(_pool, { id: 6,  weight: (_wn >= 4) ? 6 : 0 });
    array_push(_pool, { id: 7,  weight: (_wn >= 5 && _combo >= 5) ? 5 : 0 });
    array_push(_pool, { id: 8,  weight: (_wn >= 7 && _combo >= 8) ? 4 : 0 });
    array_push(_pool, { id: 9,  weight: (_wn >= 4) ? 6 : 0 });
    array_push(_pool, { id: 10, weight: (_combo >= 3) ? 6 : 0 });
    array_push(_pool, { id: 11, weight: (_combo >= 10) ? 4 : 0 });
    array_push(_pool, { id: 12, weight: 8 });
    array_push(_pool, { id: 13, weight: (_hp < 4) ? 12 : 0 });
    array_push(_pool, { id: 14, weight: (_wn >= 3 && _combo >= 5) ? 5 : 0 });
    array_push(_pool, { id: 15, weight: (_wn >= 6 && _combo >= 10) ? 3 : 0 });
    array_push(_pool, { id: 16, weight: (_wn >= 5 && _combo >= 15) ? 2 : 0 });
    array_push(_pool, { id: 17, weight: (_energy > 0.6) ? 4 : 0 });
    array_push(_pool, { id: 18, weight: (_wn >= 4 && _combo >= 8) ? 5 : 0 });
    array_push(_pool, { id: 19, weight: (_hp < 3) ? 10 : 0 });
    array_push(_pool, { id: 20, weight: (_wn >= 6 && _energy > 0.7) ? 2 : 0 });
    array_push(_pool, { id: 21, weight: (_wn >= 8 && _energy > 0.8) ? 1 : 0 });
    array_push(_pool, { id: 22, weight: (_wn >= 6 && _combo >= 15 && _energy > 0.7) ? 2 : 0 });

    var _total = 0;
    for (var i = 0; i < array_length(_pool); i++)
        _total += _pool[i].weight;

    if (_total <= 0) return 0;

    var _roll = random(_total);
    var _cum = 0;
    for (var i = 0; i < array_length(_pool); i++)
    {
        _cum += _pool[i].weight;
        if (_roll < _cum) return _pool[i].id;
    }

    return 0;
}
