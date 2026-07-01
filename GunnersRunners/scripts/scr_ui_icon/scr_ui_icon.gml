// ============================================================
// GUNNERS RUNNERS — UI Icon System
// ============================================================
// Geometric, stroke-based icons for consistent visual language.
// All icons are drawn procedurally — no sprites needed.
// ============================================================

// ---- Icon Sizes ----
enum UI_ICON {
    HUD  = 8,    // 16x16
    MENU = 12,   // 24x24
    TITLE = 16,  // 32x32
    BADGE = 24,  // 48x48
}

// ---- Core Icon Drawing: Triangle (Player Ship) ----
function ui_icon_player(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_triangle(_x, _y - _s, _x - _s * 0.7, _y + _s * 0.6, _x + _s * 0.7, _y + _s * 0.6, false);
    // Center line
    draw_line_width(_x, _y - _s * 0.3, _x, _y + _s * 0.4, max(1, _s div 6));
    draw_set_alpha(1);
}

// ---- Core Icon Drawing: Diamond (Power-up) ----
function ui_icon_diamond(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_triangle(_x, _y - _s, _x - _s * 0.7, _y, _x + _s * 0.7, _y, false);
    draw_triangle(_x, _y + _s, _x - _s * 0.7, _y, _x + _s * 0.7, _y, false);
    draw_set_alpha(1);
}

// ---- Core Icon Drawing: Hexagon (Shield/Boss) ----
function ui_icon_hexagon(_x, _y, _size, _color, _alpha, _filled)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    var _points_x = array_create(6, 0);
    var _points_y = array_create(6, 0);
    for (var i = 0; i < 6; i++)
    {
        var _angle = degtorad(60 * i - 90);
        _points_x[i] = _x + _s * cos(_angle);
        _points_y[i] = _y + _s * sin(_angle);
    }
    
    if (_filled)
    {
        // Draw filled hexagon using triangles
        for (var i = 0; i < 6; i++)
        {
            var _next = (i + 1) mod 6;
            draw_triangle(_x, _y, _points_x[i], _points_y[i], _points_x[_next], _points_y[_next], false);
        }
    }
    else
    {
        // Draw outline
        for (var i = 0; i < 6; i++)
        {
            var _next = (i + 1) mod 6;
            draw_line_width(_points_x[i], _points_y[i], _points_x[_next], _points_y[_next], max(1, _s div 8));
        }
    }
    draw_set_alpha(1);
}

// ---- Icon: Heart (HP) ----
function ui_icon_heart(_x, _y, _size, _color, _alpha, _filled)
{
    var _s = _size * 0.5;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // Simplified geometric heart using two circles + triangle
    var _cx1 = _x - _s * 0.4;
    var _cx2 = _x + _s * 0.4;
    var _cy = _y - _s * 0.2;
    
    if (_filled)
    {
        draw_circle(_cx1, _cy, _s * 0.45, false);
        draw_circle(_cx2, _cy, _s * 0.45, false);
        draw_triangle(_x - _s * 0.85, _cy, _x + _s * 0.85, _cy, _x, _y + _s * 0.9, false);
    }
    else
    {
        draw_circle(_cx1, _cy, _s * 0.45, true);
        draw_circle(_cx2, _cy, _s * 0.45, true);
        draw_line(_x - _s * 0.85, _cy, _x, _y + _s * 0.9);
        draw_line(_x + _s * 0.85, _cy, _x, _y + _s * 0.9);
    }
    draw_set_alpha(1);
}

// ---- Icon: Star (Achievement) ----
function ui_icon_star(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    var _points = 5;
    var _outer = _s;
    var _inner = _s * 0.4;
    
    var _px = array_create(10, 0);
    var _py = array_create(10, 0);
    for (var i = 0; i < _points * 2; i++)
    {
        var _angle = degtorad(90 + (360 / (_points * 2)) * i);
        var _r = (i mod 2 == 0) ? _outer : _inner;
        _px[i] = _x + _r * cos(_angle);
        _py[i] = _y + _r * sin(_angle);
    }
    
    for (var i = 0; i < _points * 2; i++)
    {
        var _next = (i + 1) mod (_points * 2);
        draw_triangle(_x, _y, _px[i], _py[i], _px[_next], _py[_next], false);
    }
    draw_set_alpha(1);
}

// ---- Icon: Lightning (Combo) ----
function ui_icon_lightning(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // Zigzag lightning bolt
    var _points_x = [_x + _s * 0.2, _x - _s * 0.3, _x + _s * 0.05, _x - _s * 0.15];
    var _points_y = [_y - _s, _y - _s * 0.15, _y - _s * 0.15, _y + _s];
    
    draw_line_width(_points_x[0], _points_y[0], _points_x[1], _points_y[1], max(1, _s div 6));
    draw_line_width(_points_x[1], _points_y[1], _points_x[2], _points_y[2], max(1, _s div 6));
    draw_line_width(_points_x[2], _points_y[2], _points_x[3], _points_y[3], max(1, _s div 6));
    draw_set_alpha(1);
}

// ---- Icon: Circle with X (Game Over) ----
function ui_icon_x_circle(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_circle(_x, _y, _s, true);
    draw_line_width(_x - _s * 0.5, _y - _s * 0.5, _x + _s * 0.5, _y + _s * 0.5, max(1, _s div 6));
    draw_line_width(_x + _s * 0.5, _y - _s * 0.5, _x - _s * 0.5, _y + _s * 0.5, max(1, _s div 6));
    draw_set_alpha(1);
}

// ---- Icon: Wave (Sound) ----
function ui_icon_wave(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // Three vertical bars
    var _bar_w = max(1, _s div 5);
    var _bars = 3;
    var _gap = _s * 0.6;
    var _start_x = _x - (_bars - 1) * _gap / 2;
    
    var _heights = array_create(3, 0);
    _heights[0] = _s * 0.5;
    _heights[1] = _s;
    _heights[2] = _s * 0.7;
    
    for (var i = 0; i < _bars; i++)
    {
        var _bx = _start_x + i * _gap;
        var _bh = _heights[i];
        draw_rectangle(_bx - _bar_w / 2, _y - _bh / 2, _bx + _bar_w / 2, _y + _bh / 2, false);
    }
    draw_set_alpha(1);
}

// ---- Icon: Settings (Gear) ----
function ui_icon_gear(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // Outer circle
    draw_circle(_x, _y, _s, true);
    // Inner circle
    draw_circle(_x, _y, _s * 0.5, true);
    
    // Teeth (6 lines)
    for (var i = 0; i < 6; i++)
    {
        var _angle = degtorad(60 * i);
        var _x1 = _x + _s * 0.5 * cos(_angle);
        var _y1 = _y + _s * 0.5 * sin(_angle);
        var _x2 = _x + _s * 1.1 * cos(_angle);
        var _y2 = _y + _s * 1.1 * sin(_angle);
        draw_line_width(_x1, _y1, _x2, _y2, max(1, _s div 6));
    }
    draw_set_alpha(1);
}

// ---- Icon: Pause (Two bars) ----
function ui_icon_pause(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    var _bar_w = max(2, _s div 4);
    var _gap = _s * 0.4;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_rectangle(_x - _gap - _bar_w / 2, _y - _s, _x - _gap + _bar_w / 2, _y + _s, false);
    draw_rectangle(_x + _gap - _bar_w / 2, _y - _s, _x + _gap + _bar_w / 2, _y + _s, false);
    draw_set_alpha(1);
}

// ---- Icon: Crown (Victory) ----
function ui_icon_crown(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // Three points
    var _base_y = _y + _s * 0.4;
    var _top_y = _y - _s * 0.6;
    var _mid_y = _y - _s * 0.1;
    
    draw_triangle(_x - _s * 0.8, _base_y, _x - _s * 0.4, _top_y, _x, _mid_y, false);
    draw_triangle(_x, _mid_y, _x, _top_y - _s * 0.15, _x + _s * 0.4, _mid_y, false);
    draw_triangle(_x, _mid_y, _x + _s * 0.4, _top_y, _x + _s * 0.8, _base_y, false);
    
    // Base bar
    draw_rectangle(_x - _s * 0.8, _base_y, _x + _s * 0.8, _base_y + _s * 0.25, false);
    draw_set_alpha(1);
}

// ---- Icon: Arrow (Navigation) ----
function ui_icon_arrow(_x, _y, _size, _direction, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    
    // direction: 0=up, 1=right, 2=down, 3=left
    var _angle = degtorad(90 * _direction);
    var _dx = cos(_angle);
    var _dy = -sin(_angle);
    var _nx = -_dy;
    var _ny = _dx;
    
    draw_line_width(_x - _dx * _s, _y + _dy * _s, _x + _dx * _s, _y - _dy * _s, max(1, _s div 5));
    draw_triangle(_x + _dx * _s, _y - _dy * _s,
                  _x + _nx * _s * 0.5 - _dx * _s * 0.3, _y - _ny * _s * 0.5 + _dy * _s * 0.3,
                  _x - _nx * _s * 0.5 - _dx * _s * 0.3, _y + _ny * _s * 0.5 + _dy * _s * 0.3, false);
    draw_set_alpha(1);
}

// ---- Icon: Time (Clock) ----
function ui_icon_clock(_x, _y, _size, _color, _alpha)
{
    var _s = _size;
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_circle(_x, _y, _s, true);
    draw_line_width(_x, _y, _x, _y - _s * 0.7, max(1, _s div 6));
    draw_line_width(_x, _y, _x + _s * 0.5, _y, max(1, _s div 6));
    draw_set_alpha(1);
}

// ---- Icon: Rank Letter ----
function ui_icon_rank(_x, _y, _size, _rank, _alpha)
{
    var _color = ui_color_rank(_rank);
    ui_text_glow(_x, _y, _rank, _size / 12, _color, _alpha, 0.5);
}
