// ============================================================
// GUNNERS RUNNERS — UI Panel System
// ============================================================
// Panel drawing with multiple styles, borders, and effects.
// ============================================================

// ---- Panel Types ----
enum UI_PANEL {
    SOLID,       // Carbon 95%, no blur, sharp
    TRANSLUCENT, // Carbon 70%, blur, rounded
    FLOATING,    // Carbon 85%, blur, rounded
    HUD,         // Carbon 80%, no blur, sharp
    MODAL,       // Carbon 90%, blur, rounded
    GHOST,       // Transparent, 1px border
}

// ---- Draw Solid Panel ----
function ui_panel_solid(_x1, _y1, _x2, _y2, _alpha)
{
    // Background
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.95);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Top highlight line
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.3);
    draw_line(_x1, _y1 + 1, _x2, _y1 + 1);
    
    // Border
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.5);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_alpha(1);
}

// ---- Draw Translucent Panel ----
function ui_panel_translucent(_x1, _y1, _x2, _y2, _alpha)
{
    // Background
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.70);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Border (rounded look via multiple rectangles)
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.4);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_alpha(1);
}

// ---- Draw Floating Panel ----
function ui_panel_floating(_x1, _y1, _x2, _y2, _alpha)
{
    // Shadow
    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.4);
    draw_rectangle(_x1 + 4, _y1 + 4, _x2 + 4, _y2 + 4, false);
    
    // Background
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.90);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Border
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.6);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_alpha(1);
}

// ---- Draw HUD Panel ----
function ui_panel_hud(_x1, _y1, _x2, _y2, _alpha)
{
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.80);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    draw_set_alpha(1);
}

// ---- Draw Modal Panel (with glow border) ----
function ui_panel_modal(_x1, _y1, _x2, _y2, _alpha, _accent_color)
{
    // Shadow
    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.5);
    draw_rectangle(_x1 + 6, _y1 + 6, _x2 + 6, _y2 + 6, false);
    
    // Background
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.95);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Accent border
    if (_accent_color != undefined)
    {
        draw_set_color(_accent_color);
        draw_set_alpha(_alpha * 0.6);
        draw_rectangle(_x1, _y1, _x2, _y2, true);
        draw_set_alpha(_alpha * 0.3);
        draw_rectangle(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, true);
    }
    else
    {
        draw_set_color(global.ui_c_steel);
        draw_set_alpha(_alpha * 0.6);
        draw_rectangle(_x1, _y1, _x2, _y2, true);
    }
    
    draw_set_alpha(1);
}

// ---- Draw Ghost Panel ----
function ui_panel_ghost(_x1, _y1, _x2, _y2, _alpha)
{
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.3);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_alpha(1);
}

// ---- Draw Panel with Glow Border ----
function ui_panel_glow(_x1, _y1, _x2, _y2, _alpha, _glow_color, _glow_radius)
{
    // Background
    draw_set_color(global.ui_c_carbon);
    draw_set_alpha(_alpha * 0.90);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // Glow border
    ui_glow_border(_x1, _y1, _x2, _y2, _glow_color, _glow_radius, _alpha * 0.6);
    
    draw_set_alpha(1);
}

// ---- Draw Separator Line ----
function ui_separator(_x1, _y, _x2, _style)
{
    // 0 = solid, 1 = glow, 2 = dashed
    switch (_style)
    {
        case 0: // Solid
            draw_set_color(global.ui_c_steel);
            draw_set_alpha(0.5);
            draw_line(_x1, _y, _x2, _y);
            break;
        case 1: // Glow
            ui_glow_line(_x1, _y, _x2, _y, global.ui_c_neon_blue, 1, 0.3);
            break;
        case 2: // Dashed
            draw_set_color(global.ui_c_steel);
            draw_set_alpha(0.3);
            var _dash = 8;
            var _gap = 4;
            for (var _x = _x1; _x < _x2; _x += _dash + _gap)
            {
                draw_line(_x, _y, min(_x + _dash, _x2), _y);
            }
            break;
    }
    draw_set_alpha(1);
}

// ---- Draw HP Bar ----
function ui_hp_bar(_x, _y, _w, _h, _percent, _alpha)
{
    // Background
    draw_set_color(global.ui_c_void_black);
    draw_set_alpha(_alpha * 0.8);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    
    // Fill
    var _fill_w = _w * clamp(_percent, 0, 1);
    var _color = ui_color_hp(_percent);
    draw_set_color(_color);
    draw_set_alpha(_alpha * 0.9);
    draw_rectangle(_x, _y, _x + _fill_w, _y + _h, false);
    
    // Glow on fill
    if (_percent > 0)
    {
        draw_set_alpha(_alpha * 0.2);
        draw_rectangle(_x, _y, _x + _fill_w, _y + _h div 2, false);
    }
    
    // Border
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.5);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    
    draw_set_alpha(1);
}

// ---- Draw Progress Bar ----
function ui_progress_bar(_x, _y, _w, _h, _percent, _color, _alpha)
{
    // Background
    draw_set_color(global.ui_c_void_black);
    draw_set_alpha(_alpha * 0.6);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    
    // Fill
    var _fill_w = _w * clamp(_percent, 0, 1);
    draw_set_color(_color);
    draw_set_alpha(_alpha * 0.8);
    draw_rectangle(_x, _y, _x + _fill_w, _y + _h, false);
    
    // Border
    draw_set_color(global.ui_c_steel);
    draw_set_alpha(_alpha * 0.3);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    
    draw_set_alpha(1);
}
