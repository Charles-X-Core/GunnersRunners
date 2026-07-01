function scr_intro_create()
{
    state = "TITLE";
    title_alpha = 0;
    title_scale = 0.5;
    subtitle_alpha = 0;
    countdown_value = 3;
    countdown_timer = 0;
    countdown_interval = 60;
    countdown_scale = 2;
    flash_alpha = 0;
    go_alpha = 0;
    go_scale = 3;
    state_timer = 0;
    bg_stars = [];
    for (var i = 0; i < 50; i++)
    {
        array_push(bg_stars, {
            x: irandom(room_width),
            y: irandom(room_height),
            speed_val: random_range(0.5, 2),
            size: random_range(1, 3),
            alpha: random_range(0.3, 0.8)
        });
    }
}
