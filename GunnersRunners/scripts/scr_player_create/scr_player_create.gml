function scr_player_create()
{
    angle = 270;
    hspeed = 0;
    vspeed = 0;
    rot_speed = 5;
    thrust_val = 0.2;
    max_speed = 3.5;
    drag = 0.06;

    bullet_speed = 10;
    shoot_delay = 12;
    shoot_timer = 0;

    hp = 6;
    max_hp = 6;
    invincible = false;
    invincible_timer = 0;
    invincible_duration = 120;

    dead = false;

    combo = 0;
    combo_timer = 0;
    combo_max = 120;

    powerup_shield = false;
    powerup_shield_timer = 0;
    powerup_speed = false;
    powerup_speed_timer = 0;
    powerup_rapid = false;
    powerup_rapid_timer = 0;
    powerup_mini = false;
    powerup_mini_timer = 0;
    powerup_ghost = false;
    powerup_ghost_timer = 0;
    powerup_magnet = false;
    powerup_magnet_timer = 0;
    powerup_score_x2 = false;
    powerup_score_x2_timer = 0;
    powerup_score_x3 = false;
    powerup_score_x3_timer = 0;
    powerup_time_slow = false;
    powerup_time_slow_timer = 0;
    powerup_rage = false;
    powerup_rage_timer = 0;
    powerup_regen = false;
    powerup_regen_timer = 0;
    powerup_trippy = false;
    powerup_trippy_timer = 0;
    powerup_disco = false;
    powerup_disco_timer = 0;
    powerup_rainbow = false;
    powerup_rainbow_timer = 0;

    regen_counter = 0;

    is_grabbed = false;
    grabbed_by = noone;
    grab_shake_input = 0;
    grab_last_dir = -1;

    orbital_active = false;
    orbital_timer = 0;
    orbital_damage = 1;

    default_xscale = 1;
    default_yscale = 1;
}
