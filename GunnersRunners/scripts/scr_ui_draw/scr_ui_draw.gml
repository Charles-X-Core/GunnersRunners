function scr_draw_text_outlined(_x, _y, _text, _color, _outline_color, _alpha, _xscale, _yscale)
{
    draw_set_alpha(_alpha * 0.8);
    draw_set_color(_outline_color);
    draw_text_transformed(_x - 1, _y, _text, _xscale, _yscale, 0);
    draw_text_transformed(_x + 1, _y, _text, _xscale, _yscale, 0);
    draw_text_transformed(_x, _y - 1, _text, _xscale, _yscale, 0);
    draw_text_transformed(_x, _y + 1, _text, _xscale, _yscale, 0);
    draw_set_alpha(_alpha);
    draw_set_color(_color);
    draw_text_transformed(_x, _y, _text, _xscale, _yscale, 0);
}

function scr_draw_panel(_x1, _y1, _x2, _y2, _bg_alpha)
{
    draw_set_alpha(_bg_alpha);
    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
}

function scr_draw_powerup_badge(_x, _y, _label, _bg_color, _text_color, _timer_text, _alpha)
{
    var _w = 48;
    var _h = 18;

    draw_set_alpha(_alpha * 0.85);
    draw_set_color(_bg_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    draw_set_alpha(_alpha * 0.3);
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _w, _y + 1, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_alpha);
    draw_set_color(_text_color);
    draw_text(_x + _w / 2, _y + _h / 2, _label);

    if (_timer_text != "")
    {
        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        draw_set_alpha(_alpha * 0.7);
        draw_text(_x + _w - 2, _y + 2, _timer_text);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
