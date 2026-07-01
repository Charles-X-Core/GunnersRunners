var _alpha = 1 - (radius / max_radius);

draw_set_alpha(_alpha * 0.3);
draw_set_color(make_color_rgb(255, 150, 0));
draw_circle(x, y, radius, false);

draw_set_alpha(_alpha * 0.5);
draw_set_color(make_color_rgb(255, 80, 0));
draw_circle(x, y, radius * 0.6, false);

draw_set_alpha(_alpha * 0.8);
draw_set_color(make_color_rgb(255, 255, 100));
draw_circle(x, y, radius * 0.3, false);

draw_set_alpha(1);
