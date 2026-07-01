// ============================================================
// GUNNERS RUNNERS — UI Glow System
// ============================================================
// Controlled glow rendering with budget management.
// Glow is the MOST important visual element of this interface.
// ============================================================

// ---- Glow Budget (max simultaneous glows) ----
global.ui_glow_budget_gameplay = 2;
global.ui_glow_budget_menu     = 5;
global.ui_glow_count           = 0;

// ---- Glow Presets ----
global.ui_glow_sudden   = { radius: 4,  alpha: 0.15 };  // Subtle
global.ui_glow_medium   = { radius: 8,  alpha: 0.25 };  // Medium
global.ui_glow_strong   = { radius: 16, alpha: 0.40 };  // Strong
global.ui_glow_explosive= { radius: 24, alpha: 0.60 };  // Explosive

// ---- Reset glow counter (call at frame start) ----
function ui_glow_reset()
{
    global.ui_glow_count = 0;
}

// ---- Check if glow budget allows more ----
function ui_glow_can_add(_is_gameplay)
{
    var _budget = _is_gameplay ? global.ui_glow_budget_gameplay : global.ui_glow_budget_menu;
    return (global.ui_glow_count < _budget);
}

// ---- Core Glow Drawing ----
// Draws a soft glow around a point
function ui_glow_draw(_x, _y, _color, _radius, _alpha)
{
    if (!ui_glow_can_add(true)) return;
    
    global.ui_glow_count++;
    
    var _steps = 5;
    for (var i = _steps; i >= 0; i--)
    {
        var _t = i / _steps;
        var _r = _radius * (1 + _t * 0.5);
        var _a = _alpha * (1 - _t) * 0.5;
        draw_set_color(_color);
        draw_set_alpha(_a);
        draw_circle(_x, _y, _r, false);
    }
    draw_set_alpha(1);
}

// ---- Glow Rectangle ----
// Draws a glow around a rectangle
function ui_glow_rect(_x1, _y1, _x2, _y2, _color, _radius, _alpha)
{
    if (!ui_glow_can_add(true)) return;
    
    global.ui_glow_count++;
    
    var _steps = 4;
    for (var i = _steps; i >= 0; i--)
    {
        var _t = i / _steps;
        var _r = _radius * _t;
        var _a = _alpha * (1 - _t) * 0.4;
        draw_set_color(_color);
        draw_set_alpha(_a);
        draw_rectangle(_x1 - _r, _y1 - _r, _x2 + _r, _y2 + _r, false);
    }
    draw_set_alpha(1);
}

// ---- Glow Line ----
// Draws a glow along a line
function ui_glow_line(_x1, _y1, _x2, _y2, _color, _width, _alpha)
{
    if (!ui_glow_can_add(true)) return;
    
    global.ui_glow_count++;
    
    var _steps = 3;
    for (var i = _steps; i >= 0; i--)
    {
        var _t = i / _steps;
        var _w = _width + _t * 6;
        var _a = _alpha * (1 - _t) * 0.5;
        draw_set_color(_color);
        draw_set_alpha(_a);
        draw_line_width(_x1, _y1, _x2, _y2, _w);
    }
    draw_set_alpha(1);
}

// ---- Glow Text ----
// Draws text with glow effect
function ui_glow_text(_x, _y, _text, _color, _alpha, _glow_radius, _glow_alpha)
{
    // Glow layer
    if (_glow_radius > 0 && ui_glow_can_add(true))
    {
        global.ui_glow_count++;
        draw_set_color(_color);
        draw_set_alpha(_glow_alpha);
        draw_text(_x, _y, _text);
        draw_set_alpha(_glow_alpha * 0.5);
        draw_text(_x - 1, _y, _text);
        draw_text(_x + 1, _y, _text);
        draw_text(_x, _y - 1, _text);
        draw_text(_x, _y + 1, _text);
    }
    
    // Main text
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_text(_x, _y, _text);
    draw_set_alpha(1);
}

// ---- Pulsing Glow (BPM-synced) ----
function ui_glow_pulsing(_x, _y, _color, _radius_min, _radius_max, _alpha_min, _alpha_max, _speed)
{
    var _phase = sin(current_time * 0.001 * _speed);
    var _r = lerp(_radius_min, _radius_max, 0.5 + 0.5 * _phase);
    var _a = lerp(_alpha_min, _alpha_max, 0.5 + 0.5 * _phase);
    ui_glow_draw(_x, _y, _color, _r, _a);
}

// ---- Glow Border (for panels/buttons) ----
function ui_glow_border(_x1, _y1, _x2, _y2, _color, _radius, _alpha)
{
    if (!ui_glow_can_add(true)) return;
    
    global.ui_glow_count++;
    
    var _steps = 3;
    for (var i = _steps; i >= 0; i--)
    {
        var _t = i / _steps;
        var _r = _radius * _t;
        var _a = _alpha * (1 - _t) * 0.3;
        draw_set_color(_color);
        draw_set_alpha(_a);
        draw_rectangle(_x1 - _r, _y1 - _r, _x2 + _r, _y2 + _r, true);
    }
    draw_set_alpha(1);
}

// ---- Explosive Glow (for achievements, rank S) ----
function ui_glow_explosive(_x, _y, _color, _progress)
{
    // _progress: 0 = start, 1 = full expansion
    var _radius = 8 + _progress * 32;
    var _alpha = (1 - _progress) * 0.6;
    ui_glow_draw(_x, _y, _color, _radius, _alpha);
}
