function scr_intro_step()
{
    for (var i = 0; i < array_length(bg_stars); i++)
    {
        bg_stars[i].y += bg_stars[i].speed_val;
        if (bg_stars[i].y > room_height)
        {
            bg_stars[i].y = 0;
            bg_stars[i].x = irandom(room_width);
        }
    }

    switch (state)
    {
        case "TITLE":
            state_timer++;
            title_alpha = min(1, title_alpha + 0.02);
            if (state_timer > 40) title_scale = min(1, title_scale + 0.02);
            if (state_timer > 80) subtitle_alpha = min(1, subtitle_alpha + 0.03);
            if (state_timer > 100 && keyboard_check(vk_space))
            {
                state = "COUNTDOWN";
                state_timer = 0;
                countdown_value = 3;
                countdown_timer = countdown_interval;
            }
            break;

        case "COUNTDOWN":
            state_timer++;
            countdown_timer--;
            countdown_scale = lerp(countdown_scale, 1, 0.1);
            if (countdown_timer <= 0)
            {
                flash_alpha = 1;
                countdown_value--;
                if (countdown_value > 0)
                {
                    countdown_timer = countdown_interval;
                    countdown_scale = 2;
                }
                else
                {
                    state = "GO";
                    state_timer = 0;
                }
            }
            flash_alpha = max(0, flash_alpha - 0.05);
            break;

        case "GO":
            state_timer++;
            go_alpha = min(1, go_alpha + 0.1);
            go_scale = lerp(go_scale, 1, 0.15);
            if (state_timer > 60)
            {
                global.game_state = "SELECT_MUSIC";
                instance_destroy();
            }
            break;
    }
}
