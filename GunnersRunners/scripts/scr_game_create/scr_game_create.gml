function scr_game_create()
{
    global.score = 0;
    global.wave = 1;
    global.enemies_per_wave = 5;
    global.enemies_alive = 0;
    global.enemies_spawned = 0;
    global.spawn_delay = 60;
    global.spawn_timer = 0;
    global.game_over = false;
    global.wave_delay = 120;
}
