// ============================================================
// GUNNERS RUNNERS — UI Color Palette System
// ============================================================
// All colors follow the "Neon Minimalism" art direction.
// Every color has a specific purpose and psychological function.
// ============================================================

// ---- PALETTE: Core Neutrals ----
// Used for backgrounds, panels, borders, text
global.ui_c_void_black  = make_color_rgb(12, 12, 18);    // #0C0C12 — Main background
global.ui_c_carbon      = make_color_rgb(20, 20, 28);    // #14141C — Panel surfaces
global.ui_c_steel       = make_color_rgb(40, 42, 52);    // #282A34 — Borders, separators
global.ui_c_ash         = make_color_rgb(120, 120, 140);  // #78788C — Secondary text
global.ui_c_smoke       = make_color_rgb(80, 80, 100);    // #505064 — Disabled text
global.ui_c_white       = make_color_rgb(240, 240, 245);  // #F0F0F5 — Primary text
global.ui_c_pure_white  = c_white;                         // Pure white for glow

// ---- PALETTE: Neon Energy ----
// Used for interactive elements, feedback, emphasis
global.ui_c_neon_blue   = make_color_rgb(0, 160, 255);   // #00A0FF — Primary, selection, focus
global.ui_c_neon_cyan   = make_color_rgb(0, 240, 220);   // #00F0DC — Power-ups, upgrades
global.ui_c_neon_magenta= make_color_rgb(255, 0, 180);   // #FF00B4 — Danger, boss, alert
global.ui_c_neon_gold   = make_color_rgb(255, 200, 40);  // #FFC828 — Score, combo, rewards
global.ui_c_neon_green  = make_color_rgb(0, 255, 120);   // #00FF78 — Success, HP full
global.ui_c_neon_red    = make_color_rgb(255, 40, 60);   // #FF283C — Damage, error, HP low
global.ui_c_neon_orange = make_color_rgb(255, 120, 0);   // #FF7800 — Warning, heat
global.ui_c_neon_purple = make_color_rgb(160, 60, 255);  // #A03CFF — Special, ultimate

// ---- PALETTE: State Colors ----
global.ui_c_state_normal   = global.ui_c_neon_blue;
global.ui_c_state_hover    = make_color_rgb(51, 176, 255);  // Blue +20% brightness
global.ui_c_state_pressed  = make_color_rgb(0, 128, 204);   // Blue -20% brightness
global.ui_c_state_focus    = global.ui_c_neon_cyan;
global.ui_c_state_disabled = global.ui_c_smoke;
global.ui_c_state_success  = global.ui_c_neon_green;
global.ui_c_state_error    = global.ui_c_neon_red;
global.ui_c_state_warning  = global.ui_c_neon_orange;
global.ui_c_state_selected = global.ui_c_neon_gold;

// ---- PALETTE: HP States ----
global.ui_c_hp_full   = global.ui_c_neon_green;
global.ui_c_hp_mid    = global.ui_c_neon_gold;
global.ui_c_hp_low    = global.ui_c_neon_red;

// ---- PALETTE: Combo States ----
global.ui_c_combo_none = global.ui_c_ash;
global.ui_c_combo_low  = global.ui_c_neon_blue;
global.ui_c_combo_mid  = global.ui_c_neon_cyan;
global.ui_c_combo_high = global.ui_c_neon_gold;

// ---- PALETTE: Rank Colors ----
global.ui_c_rank_s = global.ui_c_neon_gold;
global.ui_c_rank_a = global.ui_c_neon_magenta;
global.ui_c_rank_b = global.ui_c_neon_blue;
global.ui_c_rank_c = global.ui_c_neon_cyan;
global.ui_c_rank_d = global.ui_c_ash;
global.ui_c_rank_f = global.ui_c_neon_red;

// ---- PALETTE: Power-up Rarity ----
global.ui_c_rarity_common    = global.ui_c_ash;
global.ui_c_rarity_uncommon  = global.ui_c_neon_green;
global.ui_c_rarity_rare      = global.ui_c_neon_cyan;
global.ui_c_rarity_epic      = global.ui_c_neon_purple;
global.ui_c_rarity_legendary = global.ui_c_neon_gold;

// ---- PALETTE: Overlay Tints ----
global.ui_c_overlay_pause     = make_color_rgb(12, 12, 18);
global.ui_c_overlay_gameover  = make_color_rgb(20, 8, 8);    // Dark with red tint
global.ui_c_overlay_victory   = make_color_rgb(20, 18, 8);   // Dark with gold tint
global.ui_c_overlay_modal     = make_color_rgb(12, 12, 18);

// ---- PALETTE: Weapon Level Colors ----
global.ui_c_wpn_level[1] = make_color_rgb(180, 180, 180); // L1 SINGLE — Gray
global.ui_c_wpn_level[2] = make_color_rgb(80, 180, 255);  // L2 DUAL — Blue
global.ui_c_wpn_level[3] = make_color_rgb(180, 80, 255);  // L3 SPREAD — Purple
global.ui_c_wpn_level[4] = make_color_rgb(0, 200, 200);   // L3 HOMING — Cyan
global.ui_c_wpn_level[5] = make_color_rgb(255, 140, 0);   // L4 SHOTGUN — Orange
global.ui_c_wpn_level[6] = make_color_rgb(0, 200, 100);   // L4 CHAIN — Green
global.ui_c_wpn_level[7] = global.ui_c_neon_gold;          // L7 COMBO — Gold
global.ui_c_wpn_level[8] = global.ui_c_neon_purple;        // L8 ULTIMATE — Purple

// ---- Helper: Get HP color based on percentage ----
function ui_color_hp(_percent)
{
    if (_percent > 0.6) return global.ui_c_hp_full;
    if (_percent > 0.3) return global.ui_c_hp_mid;
    return global.ui_c_hp_low;
}

// ---- Helper: Get combo color based on count ----
function ui_color_combo(_combo)
{
    if (_combo >= 50) return global.ui_c_combo_high;
    if (_combo >= 20) return global.ui_c_combo_mid;
    if (_combo >= 5)  return global.ui_c_combo_low;
    return global.ui_c_combo_none;
}

// ---- Helper: Get rank color ----
function ui_color_rank(_rank)
{
    switch (_rank)
    {
        case "S": return global.ui_c_rank_s;
        case "A": return global.ui_c_rank_a;
        case "B": return global.ui_c_rank_b;
        case "C": return global.ui_c_rank_c;
        case "D": return global.ui_c_rank_d;
        default:  return global.ui_c_rank_f;
    }
}

// ---- Helper: Get weapon level color ----
function ui_color_weapon(_level)
{
    if (_level >= 1 && _level <= 8) return global.ui_c_wpn_level[_level];
    return global.ui_c_ash;
}

// ---- Helper: Lerp between two colors ----
function ui_color_lerp(_c1, _c2, _amount)
{
    var _r = lerp(color_get_red(_c1), color_get_red(_c2), _amount);
    var _g = lerp(color_get_green(_c1), color_get_green(_c2), _amount);
    var _b = lerp(color_get_blue(_c1), color_get_blue(_c2), _amount);
    return make_color_rgb(_r, _g, _b);
}
