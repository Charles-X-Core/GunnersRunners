if (homing)
{
    if (!instance_exists(homing_target) || homing_target.hp <= 0)
    {
        homing_target = instance_nearest(x, y, obj_enemy);
    }

    if (instance_exists(homing_target))
    {
        var _dir = point_direction(x, y, homing_target.x, homing_target.y);
        var _turn = 8;
        var _cur_dir = point_direction(0, 0, hspeed, vspeed);
        var _diff = angle_difference(_dir, _cur_dir);
        _cur_dir += clamp(_diff, -_turn, _turn);
        hspeed = lengthdir_x(point_distance(0, 0, hspeed, vspeed), _cur_dir);
        vspeed = lengthdir_y(point_distance(0, 0, hspeed, vspeed), _cur_dir);
        image_angle = _cur_dir - 90;
    }
}

bullet_life++;
if (bullet_life >= bullet_max_life)
{
    instance_destroy();
    exit;
}

if (x < -16 || x > room_width + 16 || y < -16 || y > room_height + 16)
{
    instance_destroy();
}
