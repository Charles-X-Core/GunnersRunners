hp = 30 + (global.wave * 8);
max_hp = hp;
speed_val = 1;
score_value = 500;
move_timer = 0;
shoot_timer = 0;
shoot_pattern = 0;

current_phase = 1;
phase_transition_timer = 0;
phase_aura_alpha = 0;

weak_points = [];
var _wp_count = 2;
for (var _wi = 0; _wi < _wp_count; _wi++)
{
    array_push(weak_points, {
        hp: 5,
        max_hp: 5,
        angle: _wi * 180,
        alive: true,
        hit_flash: 0
    });
}

minion_timer = 0;
desperation_mode = false;
beam_active = false;
beam_timer = 0;
beam_charge = 0;
song_progress = 0;
rush_cooldown = 0;

defeated = false;
defeat_timer = 0;
defeat_score_timer = 0;
