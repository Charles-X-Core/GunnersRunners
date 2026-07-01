move_timer++;
lifetime--;

if (lifetime <= 0)
{
    instance_destroy();
    return;
}

y += vspeed;
x += sin(move_timer * bob_speed) * bob_amount * 0.3;

if (instance_exists(obj_player) && !obj_player.dead)
{
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _collect_dist = 28;
    var _magnet_dist = 80;
    if (obj_player.powerup_magnet)
    {
        _magnet_dist = 160;
        _collect_dist = 40;
    }

    if (_dist < _magnet_dist)
    {
        var _dir = point_direction(x, y, obj_player.x, obj_player.y);
        var _pull = (_magnet_dist - _dist) * 0.04;
        x += lengthdir_x(_pull, _dir);
        y += lengthdir_y(_pull, _dir);
    }

    if (_dist < _collect_dist)
    {
        global.ai_last_powerup_time = current_time;
        global.powerups_collected++;
        switch (powerup_type)
        {
            case 0:
                weapon_level_up();
                break;
            case 1:
                obj_player.powerup_shield = true;
                obj_player.powerup_shield_timer = 480;
                obj_player.invincible = true;
                obj_player.invincible_timer = 480;
                break;
            case 2:
                obj_player.powerup_speed = true;
                obj_player.powerup_speed_timer = 600;
                break;
            case 3:
                obj_player.powerup_rapid = true;
                obj_player.powerup_rapid_timer = 600;
                break;
            case 4:
                var _temp_level = irandom_range(3, 7);
                weapon_apply_temp(_temp_level);
                break;
            case 5:
                obj_player.powerup_rage = true;
                obj_player.powerup_rage_timer = 600;
                break;
            case 6:
                obj_player.powerup_regen = true;
                obj_player.powerup_regen_timer = 900;
                obj_player.regen_counter = 0;
                break;
            case 7:
                obj_player.powerup_mini = true;
                obj_player.powerup_mini_timer = 600;
                break;
            case 8:
                obj_player.powerup_ghost = true;
                obj_player.powerup_ghost_timer = 300;
                obj_player.invincible = true;
                obj_player.invincible_timer = 300;
                break;
            case 9:
                obj_player.hp = min(obj_player.hp + 3, obj_player.max_hp);
                scr_screen_shake(2, 5);
                instance_destroy();
                return;
            case 10:
                obj_player.powerup_mini = true;
                obj_player.powerup_mini_timer = 600;
                break;
            case 11:
                obj_player.powerup_ghost = true;
                obj_player.powerup_ghost_timer = 300;
                obj_player.invincible = true;
                obj_player.invincible_timer = 300;
                break;
            case 12:
                obj_player.powerup_magnet = true;
                obj_player.powerup_magnet_timer = 900;
                break;
            case 13:
                obj_player.hp = min(obj_player.hp + 2, obj_player.max_hp);
                scr_screen_shake(2, 5);
                instance_destroy();
                return;
            case 14:
                obj_player.powerup_score_x2 = true;
                obj_player.powerup_score_x2_timer = 900;
                break;
            case 15:
                obj_player.powerup_score_x3 = true;
                obj_player.powerup_score_x3_timer = 600;
                break;
            case 16:
                with (obj_enemy)
                {
                    hp -= 3;
                    image_blend = c_red;
                    alarm[0] = 4;
                    if (hp <= 0)
                    {
                        var _score_mult = 1;
                        if (obj_player.powerup_score_x2) _score_mult = 2;
                        if (obj_player.powerup_score_x3) _score_mult = 3;
                        global.score += floor(score_value * (1 + obj_player.combo * 0.1) * _score_mult);
                        global.enemies_alive--;
                        obj_player.combo++;
                        obj_player.combo_timer = obj_player.combo_max;
                    }
                }
                scr_screen_shake(10, 20);
                global.nuke_flash = 1.0;
                instance_destroy();
                return;
            case 17:
                obj_player.powerup_time_slow = true;
                obj_player.powerup_time_slow_timer = 480;
                global.time_slow = true;
                break;
            case 18:
                obj_player.powerup_rage = true;
                obj_player.powerup_rage_timer = 600;
                break;
            case 19:
                obj_player.powerup_regen = true;
                obj_player.powerup_regen_timer = 900;
                obj_player.regen_counter = 0;
                break;
            case 20:
                obj_player.powerup_trippy = true;
                obj_player.powerup_trippy_timer = 480;
                global.trippy_mode = true;
                global.trippy_timer = 480;
                break;
            case 21:
                obj_player.powerup_disco = true;
                obj_player.powerup_disco_timer = 720;
                global.disco_mode = true;
                global.disco_timer = 720;
                break;
            case 22:
                obj_player.powerup_rainbow = true;
                obj_player.powerup_rainbow_timer = 600;
                global.rainbow_mode = true;
                global.rainbow_timer = 600;
                break;
        }
        scr_screen_shake(2, 5);
        instance_destroy();
        return;
    }
}

if (y > room_height + 32 || y < -64)
{
    instance_destroy();
    return;
}
