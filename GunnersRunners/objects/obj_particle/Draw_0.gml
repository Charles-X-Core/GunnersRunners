var _a = life / max_life;
var _s = size * (0.3 + _a * 0.7);
draw_set_alpha(_a);
draw_set_color(color);
draw_circle(x, y, _s, false);
draw_set_alpha(1);
