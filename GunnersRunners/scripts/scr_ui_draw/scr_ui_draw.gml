// ============================================================
// GUNNERS RUNNERS — UI Draw (Legacy + New Integration)
// ============================================================
// Backward-compatible functions that now use the new UI system.
// New code should use scr_ui_panel, scr_ui_text, etc. directly.
// ============================================================

// ---- Legacy: Text with Outline (now uses ui_text_outlined) ----
function scr_draw_text_outlined(_x, _y, _text, _color, _outline_color, _alpha, _xscale, _yscale)
{
    ui_text_outlined(_x, _y, _text, _xscale, _color, _outline_color, _alpha);
}

// ---- Legacy: Simple Panel (now uses ui_panel_hud) ----
function scr_draw_panel(_x1, _y1, _x2, _y2, _bg_alpha)
{
    ui_panel_hud(_x1, _y1, _x2, _y2, _bg_alpha);
}

// ---- Legacy: Power-up Badge (now uses new UI system) ----
function scr_draw_powerup_badge(_x, _y, _label, _bg_color, _text_color, _timer_text, _alpha)
{
    var _w = global.ui_badge_w;
    var _h = global.ui_badge_h;

    // Background
    draw_set_alpha(_alpha * 0.85);
    draw_set_color(_bg_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    // Top highlight
    draw_set_alpha(_alpha * 0.3);
    draw_set_color(global.ui_c_pure_white);
    draw_rectangle(_x, _y, _x + _w, _y + 1, false);

    // Label
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_alpha);
    draw_set_color(_text_color);
    draw_text(_x + _w / 2, _y + _h / 2, _label);

    // Timer
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

// ============================================================
// NEW UI SYSTEM FUNCTIONS
// ============================================================

// ---- Draw Selection Indicator ----
function ui_selection_indicator(_x, _y, _w, _h, _color, _alpha, _pulse)
{
    var _pulse_a = _alpha * (0.4 + 0.3 * _pulse);
    ui_glow_border(_x, _y, _x + _w, _y + _h, _color, 6, _pulse_a);
    
    // Left accent bar
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_rectangle(_x, _y + 4, _x + 3, _y + _h - 4, false);
    draw_set_alpha(1);
}

// ---- Draw Notification Banner ----
function ui_notification_banner(_x, _y, _w, _text, _color, _alpha, _progress)
{
    var _slide_x = _x + (1 - _progress) * 200;
    
    // Background
    ui_panel_solid(_slide_x, _y, _slide_x + _w, _y + 40, _alpha * 0.9);
    
    // Accent left
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_rectangle(_slide_x, _y, _slide_x + 4, _y + 40, false);
    
    // Text
    ui_text_outlined(_slide_x + 16, _y + 20, _text, global.ui_text_body, 
                     global.ui_c_white, global.ui_c_void_black, _alpha);
    
    draw_set_alpha(1);
}

// ---- Draw Rank Display ----
function ui_rank_display(_x, _y, _rank, _alpha, _scale)
{
    var _color = ui_color_rank(_rank);
    
    // Glow background
    ui_glow_draw(_x, _y, _color, 40, _alpha * 0.3);
    
    // Rank letter
    ui_text_glow(_x, _y, _rank, _scale, _color, _alpha, 0.6);
}

// ---- Draw Weapon Display ----
function ui_weapon_display(_x, _y, _level, _name, _color, _alpha)
{
    // Level indicator
    draw_set_color(_color);
    draw_set_alpha(_alpha * 0.8);
    draw_rectangle(_x, _y, _x + 4, _y + 20, false);
    
    // Level number
    ui_text_draw(_x + 12, _y, "LV." + string(_level), global.ui_text_small, _color, _alpha);
    
    // Weapon name
    ui_text_draw(_x + 52, _y, _name, global.ui_text_small, global.ui_c_white, _alpha);
}

// ---- Draw Section Color Overlay ----
function ui_section_overlay(_section, _intensity)
{
    var _color;
    switch (_section)
    {
        case "INTRO":   _color = make_color_rgb(60, 80, 180); break;
        case "BUILDUP": _color = make_color_rgb(120, 40, 200); break;
        case "MAIN":    _color = make_color_rgb(40, 120, 220); break;
        case "DROP":    _color = make_color_rgb(220, 40, 80); break;
        case "BREAK":   _color = make_color_rgb(80, 40, 160); break;
        case "OUTRO":   _color = make_color_rgb(40, 80, 120); break;
        default:        _color = global.ui_c_steel; break;
    }
    
    draw_set_color(_color);
    draw_set_alpha(_intensity);
    draw_rectangle(0, 0, global.ui_screen_w, global.ui_screen_h, false);
    draw_set_alpha(1);
}

// ---- Draw Combo Border Effect ----
function ui_combo_border(_combo, _alpha)
{
    if (_combo < 10) return;
    
    var _color = ui_color_combo(_combo);
    var _intensity = min(0.3, (_combo - 10) * 0.005);
    var _width = min(6, 1 + _combo * 0.05);
    
    // Top border
    draw_set_color(_color);
    draw_set_alpha(_alpha * _intensity);
    draw_rectangle(0, 0, global.ui_screen_w, _width, false);
    
    // Bottom border
    draw_rectangle(0, global.ui_screen_h - _width, global.ui_screen_w, global.ui_screen_h, false);
    
    // Left border
    draw_rectangle(0, 0, _width, global.ui_screen_h, false);
    
    // Right border
    draw_rectangle(global.ui_screen_w - _width, 0, global.ui_screen_w, global.ui_screen_h, false);
    
    draw_set_alpha(1);
}
