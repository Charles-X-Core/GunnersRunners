// ============================================================
// GUNNERS RUNNERS — UI Spacing System
// ============================================================
// Grid-based spacing using 8px unit. All values must be
// multiples of 8 for visual consistency.
// ============================================================

// ---- Base Unit ----
global.ui_grid = 8;

// ---- Spacing Scale ----
global.ui_sp_xs  = 4;   // Between very close elements
global.ui_sp_sm  = 8;   // Between related elements
global.ui_sp_md  = 16;  // Between same-level elements
global.ui_sp_lg  = 24;  // Between sections
global.ui_sp_xl  = 32;  // Between major groups
global.ui_sp_2xl = 48;  // Screen edge margins
global.ui_sp_3xl = 64;  // Major section separation

// ---- Screen Dimensions ----
global.ui_screen_w = 1280;
global.ui_screen_h = 720;
global.ui_center_x = 640;
global.ui_center_y = 360;

// ---- Safe Areas ----
global.ui_safe_margin    = 16;
global.ui_safe_top       = 16;
global.ui_safe_bottom    = 704;   // 720 - 16
global.ui_safe_left      = 16;
global.ui_safe_right     = 1264;  // 1280 - 16

// ---- HUD Zones ----
global.ui_hud_top_y      = 16;
global.ui_hud_bottom_y   = 688;   // 720 - 32
global.ui_hud_left_x     = 16;
global.ui_hud_right_x    = 1264;

// ---- Gameplay Safe Zone (no UI elements here) ----
global.ui_gameplay_margin = 80;

// ---- Panel Dimensions ----
global.ui_panel_min_w = 200;
global.ui_panel_min_h = 120;
global.ui_panel_radius_solid  = 0;   // Sharp corners
global.ui_panel_radius_soft   = 4;   // Soft corners
global.ui_panel_radius_round  = 8;   // Rounded corners
global.ui_panel_radius_pill   = 999; // Full round

// ---- Button Dimensions ----
global.ui_btn_h_sm   = 32;
global.ui_btn_h_md   = 40;
global.ui_btn_h_lg   = 48;
global.ui_btn_h_xl   = 56;
global.ui_btn_pad_h_sm = 16;
global.ui_btn_pad_h_md = 24;
global.ui_btn_pad_h_lg = 32;
global.ui_btn_pad_h_xl = 40;
global.ui_btn_gap     = 8;  // Between buttons

// ---- Badge Dimensions ----
global.ui_badge_w = 48;
global.ui_badge_h = 18;
global.ui_badge_gap = 8;

// ---- Helper: Snap to grid ----
function ui_snap(_value)
{
    return round(_value / global.ui_grid) * global.ui_grid;
}

// ---- Helper: Get panel rect centered ----
function ui_panel_rect_centered(_w, _h)
{
    var _x1 = global.ui_center_x - _w div 2;
    var _y1 = global.ui_center_y - _h div 2;
    return [_x1, _y1, _x1 + _w, _y1 + _h];
}

// ---- Helper: Get panel rect at position ----
function ui_panel_rect_at(_x, _y, _w, _h, _anchor_x, _anchor_y)
{
    var _x1 = _x - _w * _anchor_x;
    var _y1 = _y - _h * _anchor_y;
    return [_x1, _y1, _x1 + _w, _y1 + _h];
}

// ---- Helper: Clamp to safe area ----
function ui_safe_clamp(_x, _y, _w, _h)
{
    var _nx = clamp(_x, global.ui_safe_left, global.ui_safe_right - _w);
    var _ny = clamp(_y, global.ui_safe_top, global.ui_safe_bottom - _h);
    return [_nx, _ny];
}
