// ============================================================
// GUNNERS RUNNERS — UI Typography System
// ============================================================
// Text rendering with hierarchy, glow, and effects.
// ============================================================

// ---- Font Sizes (fallback to default if custom fonts not loaded) ----
global.ui_font_title   = -1;  // Will use draw_text_transformed for scaling
global.ui_font_hud     = -1;
global.ui_font_body    = -1;

// ---- Text Sizes by Level ----
global.ui_text_h1 = 2.0;   // ~48px — Main titles (VICTORY, GAME OVER)
global.ui_text_h2 = 1.5;   // ~36px — Subtitles (WAVE 7, BOSS)
global.ui_text_h3 = 1.2;   // ~28px — Section headers
global.ui_text_h4 = 1.0;   // ~24px — HUD important elements
global.ui_text_body = 0.8;  // ~18px — Normal text
global.ui_text_small = 0.65; // ~15px — Labels, hints
global.ui_text_micro = 0.5;  // ~12px — Timestamps, metadata

// ---- Text Hierarchy Constants ----
enum UI_TEXT {
    H1,
    H2,
    H3,
    H4,
    BODY,
    SMALL,
    MICRO,
}

// ---- Get scale for text level ----
function ui_text_scale(_level)
{
    switch (_level)
    {
        case UI_TEXT.H1:     return global.ui_text_h1;
        case UI_TEXT.H2:     return global.ui_text_h2;
        case UI_TEXT.H3:     return global.ui_text_h3;
        case UI_TEXT.H4:     return global.ui_text_h4;
        case UI_TEXT.BODY:   return global.ui_text_body;
        case UI_TEXT.SMALL:  return global.ui_text_small;
        case UI_TEXT.MICRO:  return global.ui_text_micro;
        default:             return global.ui_text_body;
    }
}

// ---- Core Text Drawing ----
function ui_text_draw(_x, _y, _text, _scale, _color, _alpha)
{
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
    draw_set_alpha(1);
}

// ---- Text with Outline (primary method) ----
function ui_text_outlined(_x, _y, _text, _scale, _color, _outline_color, _alpha)
{
    var _ox = max(1, floor(_scale * 0.5));
    
    // Outline
    draw_set_color(_outline_color);
    draw_set_alpha(_alpha * 0.8);
    draw_text_transformed(_x - _ox, _y, _text, _scale, _scale, 0);
    draw_text_transformed(_x + _ox, _y, _text, _scale, _scale, 0);
    draw_text_transformed(_x, _y - _ox, _text, _scale, _scale, 0);
    draw_text_transformed(_x, _y + _ox, _text, _scale, _scale, 0);
    
    // Main
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
    draw_set_alpha(1);
}

// ---- Text with Glow ----
function ui_text_glow(_x, _y, _text, _scale, _color, _alpha, _glow_alpha)
{
    // Glow layer
    draw_set_color(_color);
    draw_set_alpha(_alpha * _glow_alpha);
    draw_text_transformed(_x, _y, _text, _scale * 1.05, _scale * 1.05, 0);
    draw_set_alpha(_alpha * _glow_alpha * 0.5);
    draw_text_transformed(_x - 1, _y, _text, _scale, _scale, 0);
    draw_text_transformed(_x + 1, _y, _text, _scale, _scale, 0);
    draw_text_transformed(_x, _y - 1, _text, _scale, _scale, 0);
    draw_text_transformed(_x, _y + 1, _text, _scale, _scale, 0);
    
    // Main text
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
    draw_set_alpha(1);
}

// ---- Score Text (monospace, large) ----
function ui_text_score(_x, _y, _score, _alpha)
{
    var _text = string(_score);
    var _scale = global.ui_text_h2;
    
    // Glow
    ui_text_glow(_x, _y, _text, _scale, global.ui_c_neon_gold, _alpha, 0.3);
}

// ---- Combo Text (dynamic scale) ----
function ui_text_combo(_x, _y, _combo, _alpha)
{
    if (_combo < 2) return;
    
    var _text = string(_combo) + "x";
    var _base_scale = global.ui_text_h3;
    var _combo_scale = min(2.0, _base_scale + _combo * 0.005);
    var _color = ui_color_combo(_combo);
    
    ui_text_glow(_x, _y, _text, _combo_scale, _color, _alpha, 0.4);
}

// ---- Timer Text ----
function ui_text_timer(_x, _y, _time_ms, _alpha)
{
    var _minutes = _time_ms div 60000;
    var _seconds = (_time_ms mod 60000) div 1000;
    var _millis  = (_time_ms mod 1000) div 10;
    
    var _text = string_format(_minutes, 2, 0) + ":" 
              + string_format(_seconds, 2, 0) + ":"
              + string_format(_millis, 2, 0);
    
    // Replace spaces with 0
    _text = string_replace_all(_text, " ", "0");
    
    ui_text_draw(_x, _y, _text, global.ui_text_small, global.ui_c_ash, _alpha);
}

// ---- Section Text ----
function ui_text_section(_x, _y, _section, _alpha)
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
        default:        _color = global.ui_c_ash; break;
    }
    
    ui_text_outlined(_x, _y, _section, global.ui_text_small, _color, global.ui_c_void_black, _alpha);
}

// ---- Wave Announcement Text ----
function ui_text_wave_announce(_x, _y, _wave, _max_wave, _alpha)
{
    var _text = "WAVE " + string(_wave) + "/" + string(_max_wave);
    ui_text_glow(_x, _y, _text, global.ui_text_h2, global.ui_c_neon_gold, _alpha, 0.5);
}

// ---- Rank Text (large, centered) ----
function ui_text_rank(_x, _y, _rank, _alpha, _scale_override)
{
    var _scale = _scale_override != undefined ? _scale_override : 3.0;
    var _color = ui_color_rank(_rank);
    
    ui_text_glow(_x, _y, _rank, _scale, _color, _alpha, 0.6);
}

// ---- Helper: Align Reset ----
function ui_text_align_reset()
{
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

// ---- Helper: Set Align ----
function ui_text_align(_h, _v)
{
    draw_set_halign(_h);
    draw_set_valign(_v);
}

// ---- Helper: Center Align ----
function ui_text_align_center()
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
}

// ---- Helper: Measure text width at scale ----
function ui_text_width(_text, _scale)
{
    return string_width(_text) * _scale;
}

// ---- Helper: Measure text height at scale ----
function ui_text_height(_text, _scale)
{
    return string_height(_text) * _scale;
}
