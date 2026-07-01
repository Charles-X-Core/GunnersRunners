if (!dead)
{
    var _draw_angle = angle - 90;

    var _wl = weapon_get_effective_level();
    if (_wl >= 2 || global.weapon_temp >= 0)
    {
        var _glow_col = weapon_get_level_color(_wl);
        var _glow_r = 16 + _wl * 4;
        var _glow_a = 0.15 + sin(current_time * 0.005) * 0.1;
        if (global.weapon_temp >= 0)
        {
            _glow_a += 0.1;
            _glow_r += 5;
        }
        draw_set_alpha(_glow_a);
        draw_set_color(_glow_col);
        draw_circle(x, y, _glow_r, false);
        draw_set_alpha(1);
    }

    if (invincible)
    {
        if (current_time mod 200 < 100)
        {
            draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, _draw_angle, image_blend, 0.3);
        }
        else
        {
            draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, _draw_angle, image_blend, 1);
        }
    }
    else
    {
        draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, _draw_angle, image_blend, 1);
    }

    if (powerup_shield)
    {
        draw_set_alpha(0.2 + sin(current_time / 150) * 0.1);
        draw_set_color(make_color_rgb(0, 150, 255));
        draw_circle(x, y, 22, false);
        draw_set_alpha(0.5 + sin(current_time / 150) * 0.3);
        draw_circle(x, y, 22, true);
        draw_set_alpha(1);
    }

    if (orbital_active && orbital_timer > 0)
    {
        var _orb_col = weapon_get_level_color(8);
        for (var _oi = 0; _oi < 3; _oi++)
        {
            var _oa = (current_time * 0.004) + (_oi * 120);
            var _ox = x + lengthdir_x(55, _oa);
            var _oy = y + lengthdir_y(55, _oa);
            draw_set_alpha(0.7 + sin(current_time * 0.01 + _oi) * 0.3);
            draw_set_color(_orb_col);
            draw_circle(_ox, _oy, 6, false);
            draw_set_alpha(0.3);
            draw_circle(_ox, _oy, 10, false);
            draw_set_alpha(1);
        }
    }
}
