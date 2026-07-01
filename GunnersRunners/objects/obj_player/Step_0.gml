if (!dead)
{
    scr_player_step();
    scr_player_shoot();
}
else
{
    if (keyboard_check(ord("R")))
    {
        room_restart();
    }
}
