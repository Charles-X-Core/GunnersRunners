function scr_enemy_create()
{
    hp = 1;
    speed_val = 2 + (global.wave * 0.3);
    score_value = 10;

    if (!variable_instance_exists(id, "enemy_type"))
    {
        enemy_type = 0;
    }

    switch (enemy_type)
    {
        case 0:
            hp = 1;
            score_value = 10;
            break;
        case 1:
            hp = 2;
            speed_val *= 0.8;
            score_value = 25;
            break;
        case 2:
            hp = 3;
            speed_val *= 0.6;
            score_value = 50;
            break;
        case 3:
            hp = 8;
            speed_val *= 0.4;
            score_value = 200;
            break;
    }

    move_timer = 0;
    move_dir = 1;
    home_x = x;
    home_y = y;
    angle_offset = random(360);
    vspeed = speed_val;
}
