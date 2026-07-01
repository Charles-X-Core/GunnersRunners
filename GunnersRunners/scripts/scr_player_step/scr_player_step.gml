function scr_player_step()
{
    if (dead) return;

    if (is_grabbed)
    {
        if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))
        {
            if (grab_last_dir == 1) grab_shake_input++;
            grab_last_dir = 0;
        }
        if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
        {
            if (grab_last_dir == 0) grab_shake_input++;
            grab_last_dir = 1;
        }

        image_alpha = 0.5 + sin(current_time * 0.01) * 0.3;
        exit;
    }

    if (global.weapon_choosing)
    {
        if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))
        {
            global.weapon_branch = "A";
            global.weapon_choosing = false;
            weapon_level_up_fx();
        }
        if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
        {
            global.weapon_branch = "B";
            global.weapon_choosing = false;
            weapon_level_up_fx();
        }
        exit;
    }

    if (global.weapon_temp >= 0)
    {
        global.weapon_temp_timer--;
        if (global.weapon_temp_timer <= 0)
        {
            global.weapon_temp = -1;
            global.weapon_temp_timer = 0;
        }
    }

    var _current_max = max_speed;
    var _current_rot = rot_speed;
    if (powerup_speed)
    {
        _current_max = max_speed * 1.6;
        _current_rot = rot_speed * 1.3;
    }

    if (keyboard_check(ord("A")) || keyboard_check(vk_left))
    {
        angle += _current_rot;
    }
    if (keyboard_check(ord("D")) || keyboard_check(vk_right))
    {
        angle -= _current_rot;
    }

    if (keyboard_check(ord("W")) || keyboard_check(vk_up))
    {
        hspeed += lengthdir_x(thrust_val, angle);
        vspeed += lengthdir_y(thrust_val, angle);
    }
    if (keyboard_check(ord("S")) || keyboard_check(vk_down))
    {
        hspeed -= lengthdir_x(thrust_val * 0.5, angle);
        vspeed -= lengthdir_y(thrust_val * 0.5, angle);
    }

    var _spd = point_distance(0, 0, hspeed, vspeed);
    if (_spd > _current_max)
    {
        hspeed = (hspeed / _spd) * _current_max;
        vspeed = (vspeed / _spd) * _current_max;
    }

    hspeed *= (1 - drag);
    vspeed *= (1 - drag);

    if (abs(hspeed) < 0.01) hspeed = 0;
    if (abs(vspeed) < 0.01) vspeed = 0;

    x += hspeed;
    y += vspeed;

    var _margin = sprite_width / 2;
    if (powerup_mini) _margin = sprite_width * 0.25;
    if (x < _margin) { x = _margin; hspeed = abs(hspeed) * 0.5; }
    if (x > room_width - _margin) { x = room_width - _margin; hspeed = -abs(hspeed) * 0.5; }
    if (y < _margin) { y = _margin; vspeed = abs(vspeed) * 0.5; }
    if (y > room_height - _margin) { y = room_height - _margin; vspeed = -abs(vspeed) * 0.5; }

    if (powerup_mini)
    {
        image_xscale = 0.5;
        image_yscale = 0.5;
    }
    else
    {
        image_xscale = default_xscale;
        image_yscale = default_yscale;
    }

    if (powerup_ghost)
    {
        invincible = true;
        image_alpha = 0.5;
    }
    else if (!powerup_shield && invincible_timer <= 0)
    {
        image_alpha = 1;
    }

    var _current_delay = shoot_delay;
    if (powerup_rapid) _current_delay = floor(shoot_delay * 0.4);
    if (instance_exists(obj_rhythm) && obj_rhythm.music_started && global.level_data != -1)
    {
        if (global.current_wave_index < array_length(global.level_data.waves))
            _current_delay = global.level_data.waves[global.current_wave_index].shoot_delay;
        if (powerup_rapid) _current_delay = floor(_current_delay * 0.4);
    }
    if (shoot_timer > 0) shoot_timer--;

    if (invincible)
    {
        invincible_timer--;
        if (invincible_timer <= 0)
        {
            if (!powerup_ghost) invincible = false;
        }
    }

    if (combo_timer > 0)
    {
        combo_timer--;
        if (combo_timer <= 0) combo = 0;
    }

    if (powerup_shield) { powerup_shield_timer--; if (powerup_shield_timer <= 0) { powerup_shield = false; invincible = false; } }
    if (powerup_speed) { powerup_speed_timer--; if (powerup_speed_timer <= 0) powerup_speed = false; }
    if (powerup_rapid) { powerup_rapid_timer--; if (powerup_rapid_timer <= 0) powerup_rapid = false; }
    if (powerup_mini) { powerup_mini_timer--; if (powerup_mini_timer <= 0) { powerup_mini = false; image_xscale = default_xscale; image_yscale = default_yscale; } }
    if (powerup_ghost) { powerup_ghost_timer--; if (powerup_ghost_timer <= 0) { powerup_ghost = false; invincible = false; image_alpha = 1; } }
    if (powerup_magnet) { powerup_magnet_timer--; if (powerup_magnet_timer <= 0) powerup_magnet = false; }
    if (powerup_score_x2) { powerup_score_x2_timer--; if (powerup_score_x2_timer <= 0) powerup_score_x2 = false; }
    if (powerup_score_x3) { powerup_score_x3_timer--; if (powerup_score_x3_timer <= 0) powerup_score_x3 = false; }
    if (powerup_time_slow) { powerup_time_slow_timer--; if (powerup_time_slow_timer <= 0) { powerup_time_slow = false; global.time_slow = false; } }
    if (powerup_rage) { powerup_rage_timer--; if (powerup_rage_timer <= 0) powerup_rage = false; }
    if (powerup_regen) { powerup_regen_timer--; if (powerup_regen_timer <= 0) powerup_regen = false; }
    if (powerup_trippy) { powerup_trippy_timer--; if (powerup_trippy_timer <= 0) { powerup_trippy = false; global.trippy_mode = false; } }
    if (powerup_disco) { powerup_disco_timer--; if (powerup_disco_timer <= 0) { powerup_disco = false; global.disco_mode = false; } }
    if (powerup_rainbow) { powerup_rainbow_timer--; if (powerup_rainbow_timer <= 0) { powerup_rainbow = false; global.rainbow_mode = false; } }

    if (orbital_active)
    {
        orbital_timer--;
        if (orbital_timer <= 0)
        {
            orbital_active = false;
        }
        else
        {
            var _orb_dmg = orbital_damage;
            for (var _oi = 0; _oi < 3; _oi++)
            {
                var _oa = (current_time * 0.004) + (_oi * 120);
                var _ox = x + lengthdir_x(55, _oa);
                var _oy = y + lengthdir_y(55, _oa);
                var _orb_hit = collision_circle(_ox, _oy, 18, obj_enemy, false, true);
                if (_orb_hit != noone)
                {
                    _orb_hit.hp -= _orb_dmg;
                    _orb_hit.image_blend = c_red;
                    if (variable_instance_exists(_orb_hit, "hit_timer"))
                        _orb_hit.hit_timer = 4;
                    _orb_hit.alarm[0] = 4;
                }
            }
        }
    }

    if (powerup_regen)
    {
        regen_counter++;
        if (regen_counter >= 180)
        {
            regen_counter = 0;
            hp = min(hp + 1, max_hp);
        }
    }

    if (powerup_trippy)
    {
        global.trippy_mode = true;
        global.trippy_timer = powerup_trippy_timer;
    }

    if (powerup_disco)
    {
        global.disco_mode = true;
        global.disco_timer = powerup_disco_timer;
    }

    if (powerup_rainbow)
    {
        global.rainbow_mode = true;
        global.rainbow_timer = powerup_rainbow_timer;
        global.rainbow_intensity = lerp(global.rainbow_intensity, 1, 0.03);
    }
    else
    {
        global.rainbow_intensity = lerp(global.rainbow_intensity, 0, 0.05);
    }
}
