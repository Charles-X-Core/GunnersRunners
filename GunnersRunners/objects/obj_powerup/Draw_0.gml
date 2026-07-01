var _col;
var _label;
switch (powerup_type)
{
    case 0:  _col = make_color_rgb(255, 150, 0);  _label = "TRI"; break;
    case 1:  _col = make_color_rgb(0, 150, 255);   _label = "SHI"; break;
    case 2:  _col = make_color_rgb(0, 255, 100);   _label = "SPD"; break;
    case 3:  _col = make_color_rgb(255, 50, 255);  _label = "RAP"; break;
    case 4:  _col = make_color_rgb(0, 255, 255);   _label = "BEM"; break;
    case 5:  _col = make_color_rgb(255, 255, 0);   _label = "HOM"; break;
    case 6:  _col = make_color_rgb(0, 180, 0);     _label = "WID"; break;
    case 7:  _col = make_color_rgb(220, 220, 255);  _label = "PRC"; break;
    case 8:  _col = make_color_rgb(255, 100, 0);   _label = "EXP"; break;
    case 9:  _col = make_color_rgb(100, 180, 255); _label = "BAK"; break;
    case 10: _col = make_color_rgb(255, 150, 200); _label = "MIN"; break;
    case 11: _col = make_color_rgb(180, 180, 200); _label = "GOS"; break;
    case 12: _col = make_color_rgb(255, 215, 0);   _label = "MAG"; break;
    case 13: _col = make_color_rgb(255, 50, 50);   _label = "HP+"; break;
    case 14: _col = make_color_rgb(255, 215, 0);   _label = "x2";  break;
    case 15: _col = make_color_rgb(255, 215, 0);   _label = "x3";  break;
    case 16: _col = make_color_rgb(255, 255, 80);  _label = "NUK"; break;
    case 17: _col = make_color_rgb(50, 80, 255);   _label = "SLO"; break;
    case 18: _col = make_color_rgb(200, 0, 0);     _label = "RGE"; break;
    case 19: _col = make_color_rgb(100, 255, 100); _label = "REG"; break;
    case 20: _col = make_color_rgb(255, 0, 255);   _label = "TRP"; break;
    case 21: _col = make_color_rgb(255, 200, 0);   _label = "DSB"; break;
}

var _pulse = 1 + sin(move_timer * 0.12) * 0.2;

var _alpha = 1;
if (lifetime < blink_start)
{
    _alpha = 0.5 + sin(move_timer * 0.4) * 0.5;
    if (lifetime < 120)
        _col = merge_color(_col, c_red, 0.5);
}

draw_set_alpha(0.08 * _alpha);
draw_set_color(_col);
draw_circle(x, y, 20 * _pulse, false);

draw_set_alpha(_alpha);
draw_set_color(_col);
draw_rectangle(x - 12, y - 12, x + 12, y + 12, false);

draw_set_color(c_black);
draw_rectangle(x - 10, y - 10, x + 10, y + 10, false);

draw_set_color(_col);
draw_rectangle(x - 9, y - 9, x + 9, y + 9, false);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y, _label);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
