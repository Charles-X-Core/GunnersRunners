function scr_intro_draw()
{
    draw_clear(c_black);

    draw_set_color(c_white);
    for (var i = 0; i < array_length(bg_stars); i++)
    {
        var _s = bg_stars[i];
        draw_set_alpha(_s.alpha);
        draw_circle(_s.x, _s.y, _s.size, false);
    }
    draw_set_alpha(1);

    switch (state)
    {
        case "TITLE":
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            draw_set_alpha(title_alpha);
            draw_set_color(make_color_rgb(255, 50, 50));
            draw_text_transformed(room_width / 2, room_height / 2 - 60, "GUNNERS", title_scale * 1.2, title_scale * 1.2, 0);
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_text_transformed(room_width / 2, room_height / 2 + 10, "RUNNERS", title_scale * 1.2, title_scale * 1.2, 0);

            draw_set_alpha(subtitle_alpha);
            draw_set_color(c_white);
            draw_text(room_width / 2, room_height / 2 + 100, "PRESS SPACE TO START");

            draw_set_alpha(1);
            break;

        case "COUNTDOWN":
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);

            if (countdown_value > 0)
            {
                draw_set_alpha(1);
                draw_text_transformed(room_width / 2, room_height / 2, string(countdown_value), countdown_scale, countdown_scale, 0);
            }

            draw_set_alpha(flash_alpha);
            draw_set_color(c_white);
            draw_rectangle(0, 0, room_width, room_height, false);

            draw_set_alpha(1);
            break;

        case "GO":
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_alpha(go_alpha);
            draw_set_color(make_color_rgb(50, 255, 50));
            draw_text_transformed(room_width / 2, room_height / 2, "GO!", go_scale, go_scale, 0);
            draw_set_alpha(1);
            break;
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
