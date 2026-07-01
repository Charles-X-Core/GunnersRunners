draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(popup_color);
draw_set_alpha(popup_alpha);
var _scale = 1 + (popup_timer * 0.02);
draw_text_transformed(x, y, "+" + string(popup_score), _scale, _scale, 0);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
