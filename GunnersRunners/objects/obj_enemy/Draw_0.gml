var _type_col;
var _glow_col;
var _shape_size = 14;
switch (enemy_type)
{
    case 0: _type_col = make_color_rgb(255, 80, 80);  _glow_col = make_color_rgb(255, 50, 50);  _shape_size = 18; break;
    case 1: _type_col = make_color_rgb(255, 180, 0);  _glow_col = make_color_rgb(255, 150, 0);  _shape_size = 17; break;
    case 2: _type_col = make_color_rgb(200, 50, 255); _glow_col = make_color_rgb(180, 0, 255);  _shape_size = 16; break;
    case 3: _type_col = make_color_rgb(255, 30, 30);  _glow_col = make_color_rgb(200, 0, 0);    _shape_size = 26; break;
    case 4: _type_col = make_color_rgb(100, 150, 220); _glow_col = make_color_rgb(60, 120, 200); _shape_size = 22; break;
    case 5: _type_col = make_color_rgb(255, 100, 50);  _glow_col = make_color_rgb(255, 60, 20);  _shape_size = 21; break;
    case 6: _type_col = make_color_rgb(180, 200, 255); _glow_col = make_color_rgb(140, 170, 255); _shape_size = 14; break;
    default: _type_col = c_red; _glow_col = c_red; _shape_size = 18; break;
}

var _energy = global.music_energy;
var _pulse = 1 + _energy * 0.15;
var _section = "MAIN";
if (instance_exists(obj_rhythm))
    _section = obj_rhythm.current_section;

var _col = enemy_apply_section_color(_type_col, _section, global.beat_flash, hit_timer);
var _glow_final = merge_color(_glow_col, get_section_glow_color(_section), 0.3);
var _draw_angle = image_angle;

draw_set_halign(fa_center);
draw_set_valign(fa_center);

if (variable_instance_exists(id, "prev_positions"))
{
    var _trail_len = array_length(prev_positions);
    for (var _t = 0; _t < _trail_len; _t++)
    {
        var _ta = ((_t + 1) / _trail_len) * 0.12;
        var _ts = (0.5 + (_t / _trail_len) * 0.3) * _pulse;
        var _tx = prev_positions[_t].x;
        var _ty = prev_positions[_t].y;
        draw_set_alpha(_ta);
        draw_set_color(_col);
        switch (enemy_type)
        {
            case 0:
                draw_triangle(_tx, _ty - _shape_size * _ts, _tx - _shape_size * _ts * 0.7, _ty + _shape_size * _ts * 0.6, _tx + _shape_size * _ts * 0.7, _ty + _shape_size * _ts * 0.6, false);
                break;
            case 1:
                draw_rectangle(_tx - _shape_size * _ts * 0.6, _ty - _shape_size * _ts, _tx + _shape_size * _ts * 0.6, _ty + _shape_size * _ts, false);
                break;
            default:
                draw_circle(_tx, _ty, _shape_size * _ts * 0.7, false);
                break;
        }
    }
    draw_set_alpha(1);
}

if (enemy_type == 3 || enemy_type == 5)
{
    draw_set_alpha(0.2 + _energy * 0.15);
    draw_set_color(_glow_final);
    draw_circle(x, y, (_shape_size + 8) * _pulse, false);
    draw_set_alpha(0.1);
    draw_circle(x, y, (_shape_size + 16) * _pulse, false);
    draw_set_alpha(1);
}

if (enemy_type == 2 || enemy_type == 4)
{
    draw_set_alpha(0.15);
    draw_set_color(_glow_final);
    draw_circle(x, y, (_shape_size + 6) * _pulse, false);
    draw_set_alpha(1);
}

if (_section == "DROP")
{
    var _aberr = 2;
    draw_set_alpha(0.2);
    draw_set_color(c_red);
    scr_enemy_draw_shape(enemy_type, x - _aberr, y, _shape_size * _pulse, _draw_angle);
    draw_set_color(make_color_rgb(0, 255, 255));
    scr_enemy_draw_shape(enemy_type, x + _aberr, y, _shape_size * _pulse, _draw_angle);
    draw_set_alpha(1);
}

draw_set_color(_col);
draw_set_alpha(1);
scr_enemy_draw_shape(enemy_type, x, y, _shape_size * _pulse, _draw_angle);

if (variable_instance_exists(id, "is_grabbing") && is_grabbing && instance_exists(obj_player))
{
    var _gi = clamp((global.energy_bass - 0.65) / 0.35, 0, 1);
    var _beam_w = 2 + _gi * 4;
    var _beam_a = 0.4 + _gi * 0.4;

    draw_set_alpha(_beam_a);
    draw_set_color(make_color_rgb(255, 100 + _gi * 155, 50));
    draw_line_width(x, y, obj_player.x, obj_player.y, _beam_w);

    gpu_set_blendmode(bm_add);
    draw_set_alpha(_beam_a * 0.3);
    draw_set_color(make_color_rgb(150, 200, 255));
    draw_line_width(x, y, obj_player.x, obj_player.y, _beam_w + 4);
    gpu_set_blendmode(bm_normal);

    var _ring_r = _shape_size + 20 + sin(grab_timer * 0.2) * (5 + _gi * 10);
    draw_set_alpha(0.3 + _gi * 0.3);
    draw_set_color(make_color_rgb(255, 150, 50));
    draw_circle(x, y, _ring_r, true);

    if (_gi > 0.3)
    {
        for (var _ep = 0; _ep < floor(_gi * 4); _ep++)
        {
            var _t = random(1);
            var _epx = lerp(x, obj_player.x, _t);
            var _epy = lerp(y, obj_player.y, _t) + random_range(-8, 8);
            draw_set_alpha(0.6);
            draw_set_color(make_color_rgb(150, 200, 255));
            draw_circle(_epx, _epy, random_range(1, 3), false);
        }
    }
    draw_set_alpha(1);
}

switch (enemy_type)
{
    case 4:
        var _shield_dir = 90;
        var _sx1 = x + lengthdir_x(_shape_size * 1.2, _shield_dir - 50);
        var _sy1 = y + lengthdir_y(_shape_size * 1.2, _shield_dir - 50);
        var _sx2 = x + lengthdir_x(_shape_size * 1.4, _shield_dir);
        var _sy2 = y + lengthdir_y(_shape_size * 1.4, _shield_dir);
        var _sx3 = x + lengthdir_x(_shape_size * 1.2, _shield_dir + 50);
        var _sy3 = y + lengthdir_y(_shape_size * 1.2, _shield_dir + 50);
        var _shield_hp_pct = variable_struct_exists(id, "shield_hp") ? shield_hp / 5 : 1;
        draw_set_alpha(0.4 + _shield_hp_pct * 0.3);
        var _sh_col = merge_color(make_color_rgb(80, 120, 200), make_color_rgb(200, 220, 255), _shield_hp_pct);
        draw_set_color(_sh_col);
        draw_rectangle(_sx2 - 22, _sy2 - 6, _sx2 + 22, _sy2 + 6, false);
        draw_set_alpha(0.2);
        draw_rectangle(_sx2 - 24, _sy2 - 8, _sx2 + 24, _sy2 + 8, true);
        draw_set_alpha(1);
        break;

    case 5:
        if (variable_struct_exists(id, "is_raging") && is_raging)
        {
            draw_set_alpha(0.15 + sin(current_time * 0.01) * 0.1);
            draw_set_color(make_color_rgb(255, 50, 0));
            draw_circle(x, y, _shape_size * 2 * _pulse, false);
            draw_set_alpha(1);
        }
        break;

    case 6:
        if (instance_exists(obj_player))
        {
            var _lp = variable_struct_exists(id, "laser_charge") ? laser_charge : 0;
            if (_lp > 0)
            {
                draw_set_alpha(0.1 + _lp * 0.5);
                draw_set_color(make_color_rgb(180, 200, 255));
                draw_line_width(x, y, obj_player.x, obj_player.y, 1 + _lp * 2);
                draw_set_alpha(_lp * 0.15);
                draw_set_color(make_color_rgb(200, 220, 255));
                draw_line_width(x, y, obj_player.x, obj_player.y, 4 + _lp * 6);
                draw_set_alpha(1);
            }
            else
            {
                draw_set_alpha(0.08);
                draw_set_color(make_color_rgb(180, 200, 255));
                draw_line(x, y, obj_player.x, obj_player.y);
                draw_set_alpha(1);
            }
        }
        break;
}

var _max_hp;
switch (enemy_type)
{
    case 0: _max_hp = 1; break;
    case 1: _max_hp = 2; break;
    case 2: _max_hp = 3; break;
    case 3: _max_hp = 6; break;
    case 4: _max_hp = 12; break;
    case 5: _max_hp = 10; break;
    case 6: _max_hp = 8; break;
    default: _max_hp = 1; break;
}

if (variable_instance_exists(id, "hp_multiplier"))
    _max_hp = max(1, floor(_max_hp * hp_multiplier));

if (_max_hp > 1 && hp < _max_hp)
{
    var _bar_w = 24;
    var _bar_h = 4;
    var _bar_x = x - _bar_w / 2;
    var _bar_y = y - _shape_size - 10;
    var _hp_pct = hp / _max_hp;

    draw_set_color(c_dkgray);
    draw_set_alpha(0.7);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    draw_set_alpha(1);

    var _bar_col;
    if (_hp_pct > 0.6) _bar_col = c_lime;
    else if (_hp_pct > 0.3) _bar_col = c_yellow;
    else _bar_col = c_red;

    draw_set_color(_bar_col);
    draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _hp_pct), _bar_y + _bar_h, false);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
