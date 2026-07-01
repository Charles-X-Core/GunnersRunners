if (!variable_instance_exists(id, "enemy_type"))
{
    enemy_type = 0;
}

var _hp_mult = 1.0;
if (variable_instance_exists(id, "hp_multiplier"))
    _hp_mult = hp_multiplier;

var _wn = global.wave;

hp = max(1, floor(1 * _hp_mult));
speed_val = 1.5 + (_wn * 0.2);
score_value = 10;
max_hp = hp;
shield_hp = 5;
shield_max_hp = 5;
shield_regen_timer = 0;
is_raging = false;
dash_timer = 0;
burst_count = 0;
laser_charge = 0;
laser_firing = 0;
laser_cooldown = 0;
is_grabbing = false;
grab_timer = 0;

switch (enemy_type)
{
    case 0:
        hp = max(1, floor(1 * _hp_mult));
        speed_val = 1.5 + (_wn * 0.2);
        score_value = 10;
        break;
    case 1:
        hp = max(1, floor(1.5 * _hp_mult));
        speed_val = 1.2 + (_wn * 0.15);
        score_value = 25;
        break;
    case 2:
        hp = max(1, floor(2 * _hp_mult));
        speed_val = 1.0 + (_wn * 0.1);
        score_value = 50;
        break;
    case 3:
        hp = max(2, floor(5 * _hp_mult));
        speed_val = 0.6 + (_wn * 0.08);
        score_value = 200;
        break;
    case 4:
        hp = max(3, floor(12 * _hp_mult));
        speed_val = 0.8 + (_wn * 0.06);
        score_value = 300;
        shield_hp = 5;
        shield_max_hp = 5;
        shield_regen_timer = 0;
        break;
    case 5:
        hp = max(3, floor(10 * _hp_mult));
        speed_val = 1.5 + (_wn * 0.12);
        score_value = 250;
        is_raging = false;
        dash_timer = 0;
        burst_count = 0;
        break;
    case 6:
        hp = max(2, floor(8 * _hp_mult));
        speed_val = 0.4 + (_wn * 0.04);
        score_value = 350;
        laser_charge = 0;
        laser_firing = 0;
        laser_cooldown = 0;
        break;
}

max_hp = hp;

if (_wn >= 7)
{
    speed_val *= 1.1;
    score_value = floor(score_value * 1.3);
}

move_timer = 0;
move_dir = 1;
home_x = x;
home_y = y;
angle_offset = random(360);
vspeed = speed_val;
shoot_chance = 1.0;
burst_cooldown = 0;
hit_timer = 0;
prev_positions = [];
trail_counter = 0;
