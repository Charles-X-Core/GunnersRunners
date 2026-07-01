function scr_generate_tutorial_level(_bpm)
{
    var _beat_sec = 60 / _bpm;

    var _level = {
        bpm: _bpm,
        total_waves: 8,
        waves: [],
        total_enemies: 0,
        boss_wave: 8,
        song_duration: _beat_sec * 200,
        sections: [],
        tutorial: true
    };

    var _w1 = {
        number: 1, section_type: "INTRO", section_index: 0, bpm: _bpm,
        energy: 0.2, enemies_per_beat: 0.3,
        enemy_types: { basic: 1.0, zigzag: 0.0, homing: 0.0, heavy: 0.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.0,
        shoot_delay: 30, enemy_hp_mult: 0.8,
        measures: 2, total_beats: 16, is_boss: false,
        tutorial_text: "SPACE = SHOOT"
    };
    array_push(_level.waves, _w1);

    var _w2 = {
        number: 2, section_type: "INTRO", section_index: 0, bpm: _bpm,
        energy: 0.25, enemies_per_beat: 0.35,
        enemy_types: { basic: 0.7, zigzag: 0.3, homing: 0.0, heavy: 0.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.0,
        shoot_delay: 28, enemy_hp_mult: 0.9,
        measures: 2, total_beats: 20, is_boss: false,
        tutorial_text: "W/A/S/D = MOVE"
    };
    array_push(_level.waves, _w2);

    var _w3 = {
        number: 3, section_type: "BUILDUP", section_index: 1, bpm: _bpm,
        energy: 0.35, enemies_per_beat: 0.35,
        enemy_types: { basic: 0.0, zigzag: 0.0, homing: 1.0, heavy: 0.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.0,
        shoot_delay: 24, enemy_hp_mult: 1.0,
        measures: 2, total_beats: 20, is_boss: false,
        tutorial_text: "HOMING CHASES YOU"
    };
    array_push(_level.waves, _w3);

    var _w4 = {
        number: 4, section_type: "BUILDUP", section_index: 1, bpm: _bpm,
        energy: 0.4, enemies_per_beat: 0.3,
        enemy_types: { basic: 0.0, zigzag: 0.0, homing: 0.0, heavy: 1.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.0,
        shoot_delay: 20, enemy_hp_mult: 1.0,
        measures: 2, total_beats: 24, is_boss: false,
        tutorial_text: "HEAVY = TOUGH + SHOOTS"
    };
    array_push(_level.waves, _w4);

    var _w5 = {
        number: 5, section_type: "MAIN", section_index: 2, bpm: _bpm,
        energy: 0.5, enemies_per_beat: 0.4,
        enemy_types: { basic: 0.5, zigzag: 0.5, homing: 0.0, heavy: 0.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.8,
        shoot_delay: 18, enemy_hp_mult: 1.0,
        measures: 2, total_beats: 24, is_boss: false,
        tutorial_text: "COLLECT POWER-UPS"
    };
    array_push(_level.waves, _w5);

    var _w6 = {
        number: 6, section_type: "MAIN", section_index: 2, bpm: _bpm,
        energy: 0.55, enemies_per_beat: 0.5,
        enemy_types: { basic: 0.25, zigzag: 0.30, homing: 0.25, heavy: 0.20 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.3,
        shoot_delay: 14, enemy_hp_mult: 1.1,
        measures: 2, total_beats: 32, is_boss: false,
        tutorial_text: "ALL TYPES MIXED"
    };
    array_push(_level.waves, _w6);

    var _w7 = {
        number: 7, section_type: "DROP", section_index: 3, bpm: _bpm,
        energy: 0.75, enemies_per_beat: 0.7,
        enemy_types: { basic: 0.05, zigzag: 0.20, homing: 0.40, heavy: 0.35 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.2,
        shoot_delay: 10, enemy_hp_mult: 1.3,
        measures: 2, total_beats: 32, is_boss: false,
        tutorial_text: "DROP! GO ALL OUT!"
    };
    array_push(_level.waves, _w7);

    var _w8 = {
        number: 8, section_type: "DROP", section_index: 3, bpm: _bpm,
        energy: 0.8, enemies_per_beat: 0.0,
        enemy_types: { basic: 0.0, zigzag: 0.0, homing: 0.0, heavy: 0.0 },
        spawn_zones: [1, 1, 1], powerup_rate: 0.5,
        shoot_delay: 10, enemy_hp_mult: 1.5,
        measures: 2, total_beats: 48, is_boss: true,
        tutorial_text: "!! BOSS !!"
    };
    array_push(_level.waves, _w8);

    _level.total_waves = 8;
    _level.boss_wave = 8;

    return _level;
}

function scr_tutorial_update()
{
    if (!global.tutorial_mode) return;

    if (instance_exists(obj_rhythm) && obj_rhythm.music_started)
    {
        var _widx = global.current_wave_index;
        if (_widx < array_length(global.level_data.waves))
        {
            var _wave = global.level_data.waves[_widx];
            if (variable_struct_exists(_wave, "tutorial_text"))
            {
                if (_wave.tutorial_text != global.tutorial_text)
                {
                    global.tutorial_text = _wave.tutorial_text;
                    global.tutorial_text_timer = 180;
                }
            }
        }
    }
}
