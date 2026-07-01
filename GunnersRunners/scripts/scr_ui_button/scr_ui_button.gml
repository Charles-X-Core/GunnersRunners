// ============================================================
// GUNNERS RUNNERS — UI Button System
// ============================================================
// Interactive buttons with state management and visual feedback.
// ============================================================

// ---- Button Types ----
enum UI_BTN {
    PRIMARY,    // Neon Blue fill, white text
    SECONDARY,  // Transparent, blue border/text
    DANGER,     // Red fill, white text
    GHOST,      // Transparent, gray text
    ICON,       // Square, icon only
    SELECTED,   // Gold fill, black text
    DISABLED,   // Gray, no interaction
}

// ---- Button States ----
enum UI_BTN_STATE {
    NORMAL,
    HOVER,
    PRESSED,
    FOCUS,
    SELECTED,
    DISABLED,
    LOADING,
}

// ---- Button Struct ----
function ui_button_create(_x, _y, _w, _h, _text, _type)
{
    return {
        x: _x,
        y: _y,
        w: _w,
        h: _h,
        text: _text,
        type: _type,
        state: UI_BTN_STATE.NORMAL,
        hovered: false,
        pressed: false,
        clicked: false,
        enabled: true,
        alpha: 1,
        glow_t: 0,
    };
}

// ---- Button Update (call in Step) ----
function ui_button_update(_btn, _mouse_x, _mouse_y)
{
    _btn.clicked = false;
    
    if (!_btn.enabled)
    {
        _btn.state = UI_BTN_STATE.DISABLED;
        _btn.hovered = false;
        _btn.pressed = false;
        return;
    }
    
    // Check hover
    var _over = (_mouse_x >= _btn.x && _mouse_x <= _btn.x + _btn.w &&
                 _mouse_y >= _btn.y && _mouse_y <= _btn.y + _btn.h);
    _btn.hovered = _over;
    
    // Check press
    if (_over && mouse_check_button(mb_left))
    {
        _btn.pressed = true;
        _btn.state = UI_BTN_STATE.PRESSED;
    }
    else
    {
        if (_btn.pressed && _over)
        {
            _btn.clicked = true;
        }
        _btn.pressed = false;
    }
    
    // Set state
    if (_btn.pressed)
        _btn.state = UI_BTN_STATE.PRESSED;
    else if (_over)
        _btn.state = UI_BTN_STATE.HOVER;
    else
        _btn.state = UI_BTN_STATE.NORMAL;
    
    // Glow animation
    _btn.glow_t = lerp(_btn.glow_t, _over ? 1 : 0, 0.15);
}

// ---- Button Draw ----
function ui_button_draw(_btn)
{
    var _x1 = _btn.x;
    var _y1 = _btn.y;
    var _x2 = _btn.x + _btn.w;
    var _y2 = _btn.y + _btn.h;
    var _a = _btn.alpha;
    
    // Determine colors based on type and state
    var _bg_color, _text_color, _border_color, _glow_color;
    
    switch (_btn.type)
    {
        case UI_BTN.PRIMARY:
            _bg_color = global.ui_c_neon_blue;
            _text_color = global.ui_c_white;
            _border_color = global.ui_c_neon_blue;
            _glow_color = global.ui_c_neon_blue;
            break;
        case UI_BTN.SECONDARY:
            _bg_color = undefined;
            _text_color = global.ui_c_neon_blue;
            _border_color = global.ui_c_neon_blue;
            _glow_color = global.ui_c_neon_blue;
            break;
        case UI_BTN.DANGER:
            _bg_color = global.ui_c_neon_red;
            _text_color = global.ui_c_white;
            _border_color = global.ui_c_neon_red;
            _glow_color = global.ui_c_neon_red;
            break;
        case UI_BTN.GHOST:
            _bg_color = undefined;
            _text_color = global.ui_c_ash;
            _border_color = global.ui_c_steel;
            _glow_color = global.ui_c_ash;
            break;
        case UI_BTN.SELECTED:
            _bg_color = global.ui_c_neon_gold;
            _text_color = global.ui_c_void_black;
            _border_color = global.ui_c_neon_gold;
            _glow_color = global.ui_c_neon_gold;
            break;
        case UI_BTN.DISABLED:
            _bg_color = global.ui_c_steel;
            _text_color = global.ui_c_smoke;
            _border_color = global.ui_c_steel;
            _glow_color = undefined;
            break;
        default:
            _bg_color = global.ui_c_steel;
            _text_color = global.ui_c_white;
            _border_color = global.ui_c_steel;
            _glow_color = undefined;
            break;
    }
    
    // State modifiers
    switch (_btn.state)
    {
        case UI_BTN_STATE.HOVER:
            // Brighten
            break;
        case UI_BTN_STATE.PRESSED:
            // Darken + shrink
            _x1 += 1;
            _y1 += 1;
            _x2 -= 1;
            _y2 -= 1;
            break;
        case UI_BTN_STATE.FOCUS:
            _border_color = global.ui_c_state_focus;
            break;
    }
    
    // Shadow (for floating buttons)
    if (_btn.type == UI_BTN.PRIMARY || _btn.type == UI_BTN.DANGER || _btn.type == UI_BTN.SELECTED)
    {
        draw_set_color(c_black);
        draw_set_alpha(_a * 0.3);
        draw_rectangle(_x1 + 2, _y1 + 2, _x2 + 2, _y2 + 2, false);
    }
    
    // Background
    if (_bg_color != undefined)
    {
        draw_set_color(_bg_color);
        draw_set_alpha(_a * 0.9);
        draw_rectangle(_x1, _y1, _x2, _y2, false);
        
        // Highlight (top half, lighter)
        draw_set_alpha(_a * 0.15);
        draw_rectangle(_x1, _y1, _x2, _y1 + (_y2 - _y1) / 2, false);
    }
    
    // Border
    draw_set_color(_border_color);
    draw_set_alpha(_a * 0.6);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // Glow on hover
    if (_btn.glow_t > 0.01 && _glow_color != undefined)
    {
        ui_glow_border(_x1, _y1, _x2, _y2, _glow_color, 8, _a * _btn.glow_t * 0.4);
    }
    
    // Text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_text_color);
    draw_set_alpha(_a);
    draw_text((_x1 + _x2) / 2, (_y1 + _y2) / 2, _btn.text);
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

// ---- Draw Button at Position (quick helper) ----
function ui_draw_button(_x, _y, _w, _h, _text, _type, _alpha)
{
    var _btn = ui_button_create(_x, _y, _w, _h, _text, _type);
    _btn.alpha = _alpha;
    ui_button_draw(_btn);
    return _btn;
}
