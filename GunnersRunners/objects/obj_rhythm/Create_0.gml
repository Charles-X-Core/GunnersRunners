analysis_data = -1;
analysis_filename = "";
analysis_progress = 0;
analysis_step = 0;
analysis_total_steps = 0;
analysis_complete = false;
analysis_chunks_processed = 0;
analysis_chunks_total = 0;
analysis_profile = [];
analysis_smoothed = [];
analysis_beats = [];
analysis_bpm = 120;
analysis_current_chunk = 0;
analysis_chunks_per_step = 4;
analysis_bytes_per_chunk = 0;

global.bpm = 120;
global.beat_count = 0;
global.beat_in_measure = 0;
global.on_beat = false;
global.beat_flash = 0;
global.music_energy = 0;
global.music_intensity = 0;
global.level_data = -1;
global.current_wave_index = 0;
global.wave_beat_count = 0;

global.energy_bass = 0;
global.energy_mids = 0;
global.energy_highs = 0;
global.onset_intensity = 0;
global.beat_strength = 0;
global.peak_density = 0;
global.spectral_centroid = 0;
global.spectral_flatness = 0;
global.chroma_dominant = 0;
global.chroma_r = 0;
global.chroma_g = 0;
global.chroma_b = 0;
global.dynamic_range = 20;
global.beat_regularity = 0.5;

global.beat_times = [];
global.beat_strengths_arr = [];
global.onset_times = [];
global.onset_strengths = [];
global.energy_bass_profile = [];
global.energy_mids_profile = [];
global.energy_highs_profile = [];
global.spectral_centroid_profile = [];
global.spectral_flatness_profile = [];
global.peak_density_profile = [];
global.onset_power_profile = [];
global.chroma_profiles = [];
global.tempo_curve = [];
global.current_beat_index = 0;
global.current_onset_index = 0;
last_beat_fired_index = -1;

beat_timer = 0;
beat_interval = room_speed * (60 / global.bpm);
current_sound = -1;
energy_history = array_create(43, 0);
energy_index = 0;

wav_cache = -1;
play_buffer = -1;
buffer_sound_id = -1;
analysis_done = false;
music_started = false;
music_failed = false;

current_section = "INTRO";
section_flash = 0;
particles = [];
for (var _i = 0; _i < 24; _i++)
{
    array_push(particles, {
        x: irandom(room_width),
        y: irandom(room_height),
        vx: random_range(-0.5, 0.5),
        vy: random_range(-1, -0.2),
        size: random_range(1, 3),
        alpha: random_range(0.3, 0.8)
    });
}
energy_bars = array_create(32, 0);
energy_index = 0;
pulse_ring = 0;
sky_drop_timer = 0;

global.time_slow = false;
global.nuke_flash = 0;
global.trippy_mode = false;
global.trippy_timer = 0;
global.disco_mode = false;
global.disco_timer = 0;
global.rainbow_mode = false;
global.rainbow_timer = 0;
global.rainbow_intensity = 0;

scr_music_ai_init();
