scr_game_create();
global.game_state = "SELECT_MUSIC";
global.combo_display = 0;
global.combo_alpha = 0;
global.shake_intensity = 0;
global.shake_duration = 0;
global.shake_timer = 0;
global.wave_announce = 0;
global.wave_announce_timer = 0;
global.score_display = 0;
global.score_pop_timer = 0;

global.analysis_done = false;
global.song_selected = false;

if (instance_exists(obj_intro)) instance_destroy(obj_intro);

window_set_size(1280, 720);
surface_resize(application_surface, 1280, 720);
display_reset(0, false);
window_set_position((display_get_width() - 1280) / 2, (display_get_height() - 720) / 2);

music_files = [];
music_names = [];

var _paris_path = "";
var _hydro_path = "";

if (file_exists("datafiles/music_paris.wav"))
    _paris_path = "datafiles/music_paris.wav";
else if (file_exists("music_paris.wav"))
    _paris_path = "music_paris.wav";

if (file_exists("datafiles/music_hydrogen.wav"))
    _hydro_path = "datafiles/music_hydrogen.wav";
else if (file_exists("music_hydrogen.wav"))
    _hydro_path = "music_hydrogen.wav";

if (_paris_path != "")
{
    array_push(music_files, _paris_path);
    array_push(music_names, "M.O.O.N. - Paris");
}
if (_hydro_path != "")
{
    array_push(music_files, _hydro_path);
    array_push(music_names, "M.O.O.N. - Hydrogen");
}

var _imported = music_import_scan();
for (var i = 0; i < array_length(_imported.files); i++)
{
    array_push(music_files, _imported.files[i]);
    array_push(music_names, _imported.names[i]);
}

if (array_length(music_files) == 0)
{
    array_push(music_files, "music_paris.wav");
    array_push(music_names, "M.O.O.N. - Paris");
}

selected_index = 0;
global.selected_music = music_files[0];

countdown_value = 3;
countdown_timer = 0;

menu_pulse = 0;

import_state = "NONE";
import_path = "";
import_progress = 0;
import_timer = 0;

rescan_timer = 0;
rescan_interval = 120;

global.debug_overlay = false;

global.max_combo = 0;
global.enemies_killed = 0;
global.powerups_collected = 0;
global.game_time = 0;
global.weapon_level = 1;
global.weapon_branch = "";
global.weapon_temp = -1;
global.weapon_temp_timer = 0;
global.weapon_choosing = false;
global.boss_defeated = false;

global.stats_elites_killed = 0;
global.stats_hp_min = 6;
global.stats_weapon_max_level = 1;

achievements_init();
achievements_load();

global.fade_alpha = 0;
global.fade_target = 0;
global.fade_speed = 0.05;
global.fade_callback = -1;
global.fade_pending_state = "";
global.fade_pending_is_menu = false;

countdown_active = false;
countdown_frame = 0;
countdown_total = 210;
countdown_number = 3;
countdown_flash = 0;
countdown_particles = [];

scroll_offset = 0;
scroll_y = 0;
max_visible = 5;

menu_particles = [];
for (var i = 0; i < 40; i++)
{
    array_push(menu_particles, {
        x: random(room_width),
        y: random(room_height),
        vx: random_range(-0.3, 0.3),
        vy: random_range(-0.5, -0.1),
        size: random_range(1, 3),
        alpha: random_range(0.1, 0.4),
        color: choose(make_color_rgb(255, 80, 80), make_color_rgb(80, 200, 255), make_color_rgb(255, 200, 50), make_color_rgb(150, 255, 150)),
        life: irandom(600)
    });
}
menu_bg_time = 0;
track_card_alpha = 0;
track_card_slide = 0;

global.highscores = {};
highscores_load();
