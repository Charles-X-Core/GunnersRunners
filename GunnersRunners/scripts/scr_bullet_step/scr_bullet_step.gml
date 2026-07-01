function scr_bullet_step()
{
    if (x < -16 || x > room_width + 16 || y < -16 || y > room_height + 16)
    {
        instance_destroy();
    }
}
