scr_bullet_step();

if (place_meeting(x, y, obj_player))
{
    if (!obj_player.invincible && !obj_player.dead)
    {
        scr_damage_player();
        scr_screen_shake(5, 12);
    }
    instance_destroy();
}
