// ============================================================
// GUNNERS RUNNERS — UI Animation System
// ============================================================
// Motion design curves and animation utilities.
// All durations in frames (60fps).
// ============================================================

// ---- Animation Durations (frames at 60fps) ----
global.ui_anim_fast       = 6;    // 100ms — hover, micro-interactions
global.ui_anim_normal     = 12;   // 200ms — standard transitions
global.ui_anim_slow       = 18;   // 300ms — panel entrances
global.ui_anim_vslow      = 30;   // 500ms — score popups, dramatic
global.ui_anim_dramatic   = 48;   // 800ms — game over, victory

// ---- Easing Functions ----
// All take t in [0,1] and return [0,1]

function ui_ease_linear(_t)
{
    return _t;
}

function ui_ease_in_quad(_t)
{
    return _t * _t;
}

function ui_ease_out_quad(_t)
{
    return _t * (2 - _t);
}

function ui_ease_in_out_quad(_t)
{
    return (_t < 0.5) ? (2 * _t * _t) : (-1 + (4 - 2 * _t) * _t);
}

function ui_ease_in_cubic(_t)
{
    return _t * _t * _t;
}

function ui_ease_out_cubic(_t)
{
    var _u = 1 - _t;
    return 1 - _u * _u * _u;
}

function ui_ease_in_out_cubic(_t)
{
    if (_t < 0.5) return 4 * _t * _t * _t;
    var _u = 1 - _t;
    return 1 - 4 * _u * _u * _u;
}

function ui_ease_out_back(_t)
{
    var _s = 1.70158;
    var _u = 1 - _t;
    return 1 + (_s + 1) * _u * _u * _u - _s * _u * _u;
}

function ui_ease_out_elastic(_t)
{
    if (_t == 0 || _t == 1) return _t;
    var _p = 0.3;
    var _s = _p / 4;
    return power(2, -10 * _t) * sin((_t - _s) * (2 * pi) / _p) + 1;
}

function ui_ease_out_bounce(_t)
{
    if (_t < 1/2.75) return 7.5625 * _t * _t;
    if (_t < 2/2.75) { _t -= 1.5/2.75; return 7.5625 * _t * _t + 0.75; }
    if (_t < 2.5/2.75) { _t -= 2.25/2.75; return 7.5625 * _t * _t + 0.9375; }
    _t -= 2.625/2.75;
    return 7.5625 * _t * _t + 0.984375;
}

function ui_ease_in_expo(_t)
{
    return (_t == 0) ? 0 : power(2, 10 * (_t - 1));
}

function ui_ease_out_expo(_t)
{
    return (_t == 1) ? 1 : 1 - power(2, -10 * _t);
}

// ---- Animation State Helper ----
// Call this to create an animation state struct
function ui_anim_create(_duration, _ease_func)
{
    return {
        timer: 0,
        duration: _duration,
        ease: _ease_func,
        finished: false,
    };
}

// ---- Animation Update ----
// Returns current progress [0,1]
function ui_anim_update(_anim)
{
    _anim.timer = min(_anim.timer + 1, _anim.duration);
    _anim.finished = (_anim.timer >= _anim.duration);
    var _t = _anim.timer / _anim.duration;
    return _anim.ease(_t);
}

// ---- Animation Reset ----
function ui_anim_reset(_anim)
{
    _anim.timer = 0;
    _anim.finished = false;
}

// ---- Animation Skip to End ----
function ui_anim_finish(_anim)
{
    _anim.timer = _anim.duration;
    _anim.finished = true;
}

// ---- Lerp Helpers ----
function ui_lerp_value(_from, _to, _t)
{
    return lerp(_from, _to, _t);
}

function ui_lerp_color(_from, _to, _t)
{
    return ui_color_lerp(_from, _to, _t);
}

function ui_lerp_alpha(_from, _to, _t)
{
    return lerp(_from, _to, _t);
}

// ---- Breathing/Pulse Animation (BPM-synced) ----
function ui_breathing(_speed, _min, _max)
{
    return _min + (_max - _min) * (0.5 + 0.5 * sin(current_time * 0.001 * _speed));
}

// ---- Stagger Helper ----
// Returns delay for item at index _i with stagger _s
function ui_stagger(_i, _s)
{
    return _i * _s;
}
