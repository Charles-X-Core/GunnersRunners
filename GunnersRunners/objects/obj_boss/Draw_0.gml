var _energy = 0;
if (instance_exists(obj_rhythm))
    _energy = global.music_energy;

if (defeated)
{
    var _def_alpha = 0.5 + sin(defeat_timer * 0.08) * 0.3;
    draw_set_alpha(_def_alpha * 0.2);
    draw_set_color(c_red);
    draw_circle(x, y, sprite_width * 3, false);
    draw_set_alpha(1);

    draw_set_alpha(_def_alpha);
    draw_sprite_ext(sprite_index, image_index, x, y, 2, 2, image_angle, image_blend, _def_alpha);
    draw_set_alpha(1);
    exit;
}

var _pulse = 1 + _energy * 0.2;

var _aura_col;
var _aura_inner;
switch (current_phase)
{
    case 1:
        _aura_col = make_color_rgb(255, 50, 50);
        _aura_inner = make_color_rgb(255, 100, 80);
        break;
    case 2:
        _aura_col = make_color_rgb(160, 40, 220);
        _aura_inner = make_color_rgb(200, 80, 255);
        break;
    case 3:
        _aura_col = make_color_rgb(255, 30, 0);
        _aura_inner = make_color_rgb(255, 80, 20);
        break;
}

if (desperation_mode && !beam_active)
{
    var _desp_alpha = 0.3 + sin(current_time * 0.01) * 0.15;
    draw_set_alpha(_desp_alpha);
    draw_set_color(make_color_rgb(255, 0, 0));
    draw_circle(x, y, sprite_width * 2.5 * _pulse, false);
    draw_set_alpha(1);
}

draw_set_alpha(0.2 + _energy * 0.15);
draw_set_color(_aura_col);
draw_circle(x, y, (sprite_width + 12) * _pulse, false);
draw_set_alpha(0.1);
draw_circle(x, y, (sprite_width + 24) * _pulse, false);
draw_set_alpha(1);

if (phase_transition_timer > 0)
{
    var _flash = (phase_transition_timer mod 10 < 5) ? 1 : 0.4;
    draw_set_alpha(_flash);
    draw_set_color(c_white);
    draw_circle(x, y, sprite_width * 1.5 * (1 + (90 - phase_transition_timer) * 0.02), false);
    draw_set_alpha(1);
}

draw_sprite_ext(sprite_index, image_index, x, y, 2 * _pulse, 2 * _pulse, image_angle, image_blend, 1);

for (var _wpi = 0; _wpi < array_length(weak_points); _wpi++)
{
    var _wp = weak_points[_wpi];
    if (!_wp.alive) continue;

    var _wp_dist = sprite_width * 1.3;
    var _wpx = x + lengthdir_x(_wp_dist, _wp.angle);
    var _wpy = y + lengthdir_y(_wp_dist, _wp.angle);

    var _wp_glow = 0.3 + _energy * 0.3;
    if (global.on_beat) _wp_glow += 0.2;
    draw_set_alpha(_wp_glow);
    var _wp_col = (_wp.hit_flash > 0) ? c_white : make_color_rgb(255, 220, 50);
    draw_set_color(_wp_col);
    draw_circle(_wpx, _wpy, 10 * _pulse, false);
    draw_set_alpha(0.15);
    draw_circle(_wpx, _wpy, 16 * _pulse, false);
    draw_set_alpha(1);

    var _wp_hp_pct = _wp.hp / _wp.max_hp;
    if (_wp_hp_pct < 1)
    {
        draw_set_alpha(0.6);
        draw_healthbar(_wpx - 8, _wpy - 14, _wpx + 8, _wpy - 10, _wp_hp_pct * 100, c_dkgray, c_red, c_lime, 0, false, true);
        draw_set_alpha(1);
    }

    draw_set_color(make_color_rgb(255, 200, 50));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(0.6);
    draw_text(_wpx, _wpy, "x");
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

if (beam_active)
{
    var _beam_w = 40 + (150 - beam_timer) * 0.8;
    var _beam_alpha = min(1, (150 - beam_timer) / 30);

    draw_set_alpha(_beam_alpha * 0.15);
    draw_set_color(make_color_rgb(255, 50, 50));
    draw_rectangle(0, 0, room_width, room_height, false);

    gpu_set_blendmode(bm_add);
    draw_set_alpha(_beam_alpha * 0.6);
    draw_set_color(make_color_rgb(255, 200, 100));
    draw_rectangle(x - _beam_w / 2, y, x + _beam_w / 2, room_height, false);

    draw_set_alpha(_beam_alpha * 0.3);
    draw_set_color(make_color_rgb(255, 255, 200));
    draw_rectangle(x - _beam_w / 4, y, x + _beam_w / 4, room_height, false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(_beam_alpha * 0.4);
    draw_set_color(c_white);
    draw_rectangle(x - 2, y, x + 2, room_height, false);
    draw_set_alpha(1);

    for (var _bpi = 0; _bpi < 6; _bpi++)
    {
        var _bpx = x + random_range(-_beam_w / 2, _beam_w / 2);
        var _bpy = random_range(y, room_height);
        draw_set_alpha(0.4);
        draw_set_color(make_color_rgb(255, 180 + irandom(75), 50 + irandom(100)));
        draw_circle(_bpx, _bpy, random_range(3, 10), false);
    }
    draw_set_alpha(1);
}

if (desperation_mode && !beam_active)
{
    var _warn_a = 0.4 + sin(current_time * 0.008) * 0.3;
    draw_set_alpha(_warn_a);
    draw_set_color(make_color_rgb(255, 50, 50));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(room_width / 2, 40, "!! DESPERACION !!", 1.5, 1.5, 0);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_alpha(0.3);
    draw_set_color(make_color_rgb(255, 0, 0));
    draw_rectangle(0, 0, room_width * beam_charge, 4, false);
    draw_set_alpha(1);
}

var _bar_w = 120;
var _bar_h = 10;
var _bar_x = x - _bar_w / 2;
var _bar_y = y - 44;
var _hp_pct = (hp / max_hp) * 100;

draw_set_alpha(0.5);
draw_rectangle(_bar_x - 2, _bar_y - 2, _bar_x + _bar_w + 2, _bar_y + _bar_h + 2, false);
draw_set_alpha(1);

draw_healthbar(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, _hp_pct, c_dkgray, c_red, c_lime, 0, false, true);

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var _label_col;
if (current_phase == 3) _label_col = make_color_rgb(255, 50, 0);
else if (current_phase == 2) _label_col = make_color_rgb(180, 50, 255);
else _label_col = make_color_rgb(255, 80, 80);
draw_set_color(_label_col);
var _label = "BOSS";
if (current_phase == 2) _label = "BOSS - FASE 2";
if (current_phase == 3) _label = "BOSS - ENRAGE";
draw_text_transformed(x, _bar_y - 4, _label, 1.2, 1.2, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
