function scr_level_generate(_analysis_data)
{
    var _sections = _analysis_data.sections;
    var _bpm = _analysis_data.bpm;
    var _duration = _analysis_data.duration;

    var _level = {
        bpm: _bpm,
        total_waves: 0,
        waves: [],
        total_enemies: 0,
        boss_wave: -1,
        song_duration: _duration,
        sections: _sections
    };

    var _wave_num = 0;
    var _max_waves = 12;
    var _total_song_beats = floor(_duration * _bpm / 60);

    for (var i = 0; i < array_length(_sections); i++)
    {
        var _sec = _sections[i];
        var _sec_duration = _sec.end_time - _sec.start_time;

        if (_sec_duration < 2) continue;

        var _waves_in_sec;
        switch (_sec.type)
        {
            case "INTRO":   _waves_in_sec = 1; break;
            case "BUILDUP": _waves_in_sec = 2; break;
            case "MAIN":    _waves_in_sec = 3; break;
            case "DROP":    _waves_in_sec = 3; break;
            case "BREAK":   _waves_in_sec = 2; break;
            case "OUTRO":   _waves_in_sec = 1; break;
            default:        _waves_in_sec = 1; break;
        }

        var _sec_beats = floor(_sec_duration * _bpm / 60);
        var _beats_per_wave = max(16, floor(_sec_beats / _waves_in_sec));

        for (var w = 0; w < _waves_in_sec && _wave_num < _max_waves; w++)
        {
            _wave_num++;

            var _wave = {
                number: _wave_num,
                section_type: _sec.type,
                section_index: i,
                bpm: _bpm,
                energy: _sec.avg_energy,
                enemies_per_beat: scr_level_calc_spawn_rate(_sec.avg_energy, _sec.type),
                enemy_types: scr_level_calc_enemy_types(_sec.avg_energy, _sec.type),
                spawn_zones: scr_level_calc_spawn_zones(_sec.type, _sec.avg_energy),
                powerup_rate: scr_level_calc_powerup_rate(_sec.type, _sec.avg_energy),
                shoot_delay: scr_level_calc_shoot_delay(_sec.type, _sec.avg_energy, _bpm),
                enemy_hp_mult: scr_level_calc_enemy_hp(_wave_num, _sec.avg_energy),
                measures: 2,
                total_beats: _beats_per_wave,
                is_boss: false
            };

            array_push(_level.waves, _wave);
            _level.total_enemies += _wave.enemies_per_beat * _wave.total_beats;
        }
    }

    if (_wave_num == 0)
    {
        var _fallback_beats = max(32, floor(_total_song_beats / 3));
        _wave_num = 3;
        for (var w = 0; w < 3; w++)
        {
            var _type = (w == 0) ? "INTRO" : ((w == 1) ? "MAIN" : "DROP");
            array_push(_level.waves, {
                number: w + 1,
                section_type: _type,
                section_index: 0,
                bpm: _bpm,
                energy: 0.3 + (w * 0.2),
                enemies_per_beat: 0.4 + (w * 0.15),
                enemy_types: scr_level_calc_enemy_types(0.3 + (w * 0.2), _type),
                spawn_zones: scr_level_calc_spawn_zones(_type, 0.3 + (w * 0.2)),
                powerup_rate: scr_level_calc_powerup_rate(_type, 0.3 + (w * 0.2)),
                shoot_delay: scr_level_calc_shoot_delay(_type, 0.3 + (w * 0.2), _bpm),
                enemy_hp_mult: 1.0 + (w * 0.3),
                measures: 2,
                total_beats: _fallback_beats,
                is_boss: false
            });
        }
    }

    var _covered_beats = 0;
    for (var i = 0; i < array_length(_level.waves); i++)
        _covered_beats += _level.waves[i].total_beats;

    if (_covered_beats < _total_song_beats && array_length(_level.waves) > 0)
    {
        var _last = array_length(_level.waves) - 1;
        _level.waves[_last].total_beats += (_total_song_beats - _covered_beats);
    }
    else if (_covered_beats > _total_song_beats + 64)
    {
        var _trim = _covered_beats - _total_song_beats;
        for (var i = array_length(_level.waves) - 1; i >= 0 && _trim > 0; i--)
        {
            var _remove = min(_trim, _level.waves[i].total_beats - 16);
            _level.waves[i].total_beats -= _remove;
            _trim -= _remove;
        }
    }

    var _boss_idx = array_length(_level.waves) - 1;

    _level.waves[_boss_idx].is_boss = true;
    _level.boss_wave = _level.waves[_boss_idx].number;

    _level.total_waves = array_length(_level.waves);

    return _level;
}

function scr_level_calc_spawn_rate(_energy, _section_type)
{
    switch (_section_type)
    {
        case "INTRO":   return 0.3 + (_energy * 0.15);
        case "BUILDUP": return 0.45 + (_energy * 0.2);
        case "MAIN":    return 0.55 + (_energy * 0.2);
        case "DROP":    return 0.65 + (_energy * 0.2);
        case "BREAK":   return 0.25 + (_energy * 0.1);
        case "OUTRO":   return 0.3 + (_energy * 0.15);
    }
    return 0.4;
}

function scr_level_calc_enemy_types(_energy, _section_type)
{
    switch (_section_type)
    {
        case "INTRO":
            return { basic: 0.85, zigzag: 0.15, homing: 0.0, heavy: 0.0, shield: 0.0, berserker: 0.0, sniper: 0.0 };
        case "BUILDUP":
            return { basic: 0.35, zigzag: 0.40, homing: 0.20, heavy: 0.05, shield: 0.0, berserker: 0.0, sniper: 0.0 };
        case "MAIN":
            return { basic: 0.15, zigzag: 0.25, homing: 0.30, heavy: 0.15, shield: (_energy > 0.5) ? 0.07 : 0.0, berserker: (_energy > 0.5) ? 0.05 : 0.0, sniper: (_energy > 0.6) ? 0.03 : 0.0 };
        case "DROP":
            return { basic: 0.03, zigzag: 0.15, homing: 0.32, heavy: 0.28, shield: (_energy > 0.5) ? 0.08 : 0.0, berserker: (_energy > 0.5) ? 0.08 : 0.0, sniper: (_energy > 0.6) ? 0.06 : 0.0 };
        case "BREAK":
            return { basic: 0.50, zigzag: 0.30, homing: 0.15, heavy: 0.05, shield: 0.0, berserker: 0.0, sniper: 0.0 };
        case "OUTRO":
            return { basic: 0.40, zigzag: 0.35, homing: 0.20, heavy: 0.05, shield: 0.0, berserker: 0.0, sniper: 0.0 };
    }
    return { basic: 0.5, zigzag: 0.3, homing: 0.15, heavy: 0.05, shield: 0.0, berserker: 0.0, sniper: 0.0 };
}

function scr_level_calc_spawn_zones(_section_type, _energy)
{
    switch (_section_type)
    {
        case "INTRO":
            if (_energy < 0.3) return [1, 1, 0];
            return [0, 1, 1];
        case "BUILDUP":
            if (_energy < 0.4) return [1, 1, 0];
            return [1, 0, 1];
        case "MAIN":
            return [1, 1, 1];
        case "DROP":
            if (_energy > 0.7) return [1, 1, 1];
            if (_energy > 0.4) return [1, 0, 1];
            return [0, 1, 0];
        case "BREAK":
            return [0, 1, 0];
        case "OUTRO":
            return [1, 1, 1];
    }
    return [1, 1, 1];
}

function scr_level_calc_powerup_rate(_section_type, _energy)
{
    switch (_section_type)
    {
        case "INTRO":   return 0.35;
        case "BUILDUP": return 0.25;
        case "MAIN":    return 0.20;
        case "DROP":    return 0.15;
        case "BREAK":   return 0.30;
        case "OUTRO":   return 0.25;
    }
    return 0.20;
}

function scr_level_calc_shoot_delay(_section_type, _energy, _bpm)
{
    var _base = 60 / _bpm;
    var _beat_frames = _base * 60;

    switch (_section_type)
    {
        case "INTRO":   return max(12, floor(_beat_frames * 2.0));
        case "BUILDUP": return max(10, floor(_beat_frames * 1.6));
        case "MAIN":    return max(8, floor(_beat_frames * 1.2));
        case "DROP":    return max(7, floor(_beat_frames * 1.0));
        case "BREAK":   return max(14, floor(_beat_frames * 2.5));
        case "OUTRO":   return max(12, floor(_beat_frames * 2.0));
    }
    return max(10, floor(_beat_frames * 1.5));
}

function scr_level_calc_enemy_hp(_wave_num, _energy)
{
    var _base = 1.0 + (_wave_num * 0.1);
    var _energy_bonus = _energy * 0.3;
    return _base + _energy_bonus;
}

function scr_level_pick_enemy_type(_type_weights)
{
    var _roll = random(1);
    var _cumulative = 0;

    _cumulative += _type_weights.basic;
    if (_roll < _cumulative) return 0;

    _cumulative += _type_weights.zigzag;
    if (_roll < _cumulative) return 1;

    _cumulative += _type_weights.homing;
    if (_roll < _cumulative) return 2;

    return 3;
}
