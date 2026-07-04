function scr_player_shoot()
{
    if (dead) return;

    var _current_delay = shoot_delay;
    if (powerup_rapid) _current_delay = floor(shoot_delay * 0.4);
    if (instance_exists(obj_rhythm) && obj_rhythm.music_started && global.level_data != -1)
    {
        if (global.current_wave_index < array_length(global.level_data.waves))
            _current_delay = global.level_data.waves[global.current_wave_index].shoot_delay;
        if (powerup_rapid)
        {
            var _wl_check = weapon_get_effective_level();
            if (_wl_check >= 3)
                _current_delay = floor(_current_delay * 0.7);
            else
                _current_delay = floor(_current_delay * 0.4);
        }
    }

    if (keyboard_check(vk_space) && shoot_timer <= 0)
    {
        var _dmg = 1;
        if (powerup_rage) _dmg = 2;
        var _wl = weapon_get_effective_level();
        var _br = global.weapon_branch;

        switch (_wl)
        {
            case 1:
                var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                _b.hspeed = lengthdir_x(bullet_speed, angle);
                _b.vspeed = lengthdir_y(bullet_speed, angle);
                _b.image_angle = angle - 90;
                _b.damage = _dmg;
                break;

            case 2:
                for (var i = -1; i <= 1; i += 2)
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                    _b.hspeed = lengthdir_x(bullet_speed, angle + (i * 10));
                    _b.vspeed = lengthdir_y(bullet_speed, angle + (i * 10));
                    _b.image_angle = angle + (i * 10) - 90;
                    _b.damage = _dmg;
                }
                break;

            case 3:
                if (_br == "A")
                {
                    var _angles = [-30, -15, 0, 15, 30];
                    for (var i = 0; i < 5; i++)
                    {
                        var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                        _b.hspeed = lengthdir_x(bullet_speed, angle + _angles[i]);
                        _b.vspeed = lengthdir_y(bullet_speed, angle + _angles[i]);
                        _b.image_angle = angle + _angles[i] - 90;
                        _b.damage = _dmg;
                    }
                }
                else
                {
                    for (var i = -1; i <= 1; i++)
                    {
                        var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                        _b.hspeed = lengthdir_x(bullet_speed * 0.6, angle + (i * 20));
                        _b.vspeed = lengthdir_y(bullet_speed * 0.6, angle + (i * 20));
                        _b.image_angle = angle + (i * 20) - 90;
                        _b.homing = true;
                        _b.damage = max(1, floor(_dmg * 0.8));
                    }
                }
                break;

            case 4:
                if (_br == "A")
                {
                    var _angles = [-40, -28, -16, -4, 4, 16, 28, 40];
                    for (var i = 0; i < 8; i++)
                    {
                        var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                        _b.hspeed = lengthdir_x(bullet_speed * 0.7, angle + _angles[i]);
                        _b.vspeed = lengthdir_y(bullet_speed * 0.7, angle + _angles[i]);
                        _b.image_angle = angle + _angles[i] - 90;
                        _b.damage = _dmg;
                    }
                }
                else
                {
                    for (var i = -1; i <= 1; i++)
                    {
                        var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                        _b.hspeed = lengthdir_x(bullet_speed * 0.5, angle + (i * 18));
                        _b.vspeed = lengthdir_y(bullet_speed * 0.5, angle + (i * 18));
                        _b.image_angle = angle + (i * 18) - 90;
                        _b.homing = true;
                        _b.damage = max(1, floor(_dmg * 0.8));
                    }
                }
                break;

            case 5:
                if (_br == "B")
                {
                    for (var i = -1; i <= 1; i++)
                    {
                        var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                        _b.hspeed = lengthdir_x(bullet_speed * 0.5, angle + (i * 15));
                        _b.vspeed = lengthdir_y(bullet_speed * 0.5, angle + (i * 15));
                        _b.image_angle = angle + (i * 15) - 90;
                        _b.homing = true;
                        _b.damage = max(1, floor(_dmg * 0.8));
                    }
                }
                else
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                    _b.hspeed = lengthdir_x(bullet_speed * 2, angle);
                    _b.vspeed = lengthdir_y(bullet_speed * 2, angle);
                    _b.image_angle = angle - 90;
                    _b.beam = true;
                    _b.damage = _dmg;
                    _b.alarm[0] = 18;
                }
                break;

            case 6:
                if (_br == "B")
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                    _b.hspeed = lengthdir_x(bullet_speed, angle);
                    _b.vspeed = lengthdir_y(bullet_speed, angle);
                    _b.image_angle = angle - 90;
                    _b.damage = _dmg;
                    _b.chain = true;
                    _b.chain_count = 3;
                    _b.chain_range = 120;
                }
                else
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                    _b.hspeed = lengthdir_x(bullet_speed * 2, angle);
                    _b.vspeed = lengthdir_y(bullet_speed * 2, angle);
                    _b.image_angle = angle - 90;
                    _b.beam = true;
                    _b.damage = _dmg;
                    _b.alarm[0] = 18;
                }
                break;

            case 7:
                var _angles7 = [-25, -12, 0, 12, 25];
                for (var i = 0; i < 5; i++)
                {
                    var _b = instance_create_layer(x, y, "Instances", obj_bullet);
                    _b.hspeed = lengthdir_x(bullet_speed, angle + _angles7[i]);
                    _b.vspeed = lengthdir_y(bullet_speed, angle + _angles7[i]);
                    _b.image_angle = angle + _angles7[i] - 90;
                    _b.damage = _dmg;
                    _b.chain = true;
                    _b.chain_count = 1;
                    _b.chain_range = 100;
                }
                break;

            case 8:
                if (instance_exists(obj_player))
                {
                    obj_player.orbital_active = true;
                    obj_player.orbital_timer = 120;
                    obj_player.orbital_damage = _dmg;
                }
                break;
        }

        shoot_timer = _current_delay;
    }
}
