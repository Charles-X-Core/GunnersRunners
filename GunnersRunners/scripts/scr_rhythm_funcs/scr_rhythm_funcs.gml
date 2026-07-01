function rhythm_start_analysis(_inst, _filename)
{
    _inst.analysis_filename = _filename;
    _inst.analysis_progress = 0;
    _inst.analysis_step = 1;
    _inst.analysis_complete = false;
    _inst.analysis_chunks_processed = 0;
    _inst.analysis_chunks_total = 0;
    _inst.analysis_profile = [];
    _inst.analysis_smoothed = [];
    _inst.analysis_beats = [];
    _inst.analysis_bpm = 120;
    _inst.analysis_current_chunk = 0;
    _inst.analysis_chunks_per_step = 4;

    var _json_path = string_replace(_filename, ".wav", ".json");
    if (file_exists(_json_path))
    {
        show_debug_message("ANALYSIS: Found pre-computed JSON, loading directly...");
        var _json_data = scr_music_load_analysis_json(_json_path);
        if (_json_data != -1)
        {
            _inst.analysis_data = _json_data;

            _inst.analysis_bpm = _json_data.bpm;
            global.bpm = _json_data.bpm;
            _inst.beat_interval = room_speed * (60 / global.bpm);

            global.beat_times = _json_data.beat_times;
            global.beat_strengths_arr = _json_data.beat_strengths;
            global.onset_times = _json_data.onset_times;
            global.onset_strengths = _json_data.onset_strength;
            global.energy_bass_profile = _json_data.energy_bass;
            global.energy_mids_profile = _json_data.energy_mids;
            global.energy_highs_profile = _json_data.energy_highs;
            global.spectral_centroid_profile = _json_data.spectral_centroid;
            global.spectral_flatness_profile = _json_data.spectral_flatness;
            global.peak_density_profile = _json_data.peak_density;
            global.onset_power_profile = _json_data.onset_power;
            global.chroma_profiles = _json_data.chroma_data;
            global.tempo_curve = _json_data.tempo_curve;
            global.current_beat_index = 0;
            global.current_onset_index = 0;
            global.beat_regularity = _json_data.beat_regularity;
            global.dynamic_range = _json_data.dynamic_range;

            global.level_data = scr_level_generate(_json_data);
            _inst.analysis_progress = 1.0;
            _inst.analysis_step = 6;
            _inst.analysis_complete = true;
            _inst.analysis_done = true;

            _inst.wav_cache = scr_music_load_wav(_filename);
            if (_inst.wav_cache == -1)
            {
                show_debug_message("WARNING: Could not load WAV for playback, analysis only");
            }

            show_debug_message("JSON ANALYSIS: BPM=" + string(_json_data.bpm) +
                " Duration=" + string(_json_data.duration) +
                " Sections=" + string(array_length(_json_data.sections)) +
                " Beats=" + string(array_length(_json_data.beat_times)) +
                " Onsets=" + string(array_length(_json_data.onset_times)));
            show_debug_message("Level: " + string(global.level_data.total_waves) + " waves, boss at wave " + string(global.level_data.boss_wave));
            return true;
        }
    }

    _inst.wav_cache = scr_music_load_wav(_filename);
    if (_inst.wav_cache == -1)
    {
        show_debug_message("ERROR: Could not load WAV: " + _filename);
        return false;
    }

    var _bps = _inst.wav_cache.bytes_per_sample;
    var _ch = _inst.wav_cache.channels;
    var _sr = _inst.wav_cache.sample_rate;
    var _bytes_per_frame = _bps * _ch;
    var _samples_per_chunk = _sr * 0.5;
    var _bytes_per_chunk = _samples_per_chunk * _bytes_per_frame;

    _inst.analysis_chunks_total = floor(_inst.wav_cache.data_size / _bytes_per_chunk);
    _inst.analysis_bytes_per_chunk = _bytes_per_chunk;

    if (_inst.analysis_chunks_total <= 0)
    {
        _inst.analysis_chunks_total = 1;
    }

    _inst.analysis_profile = array_create(_inst.analysis_chunks_total, 0);

    show_debug_message("WAV: " + string(_inst.wav_cache.data_size) + " bytes, " +
        string(_inst.analysis_chunks_total) + " chunks, " +
        string(floor(_inst.wav_cache.duration)) + "s, " +
        string(_sr) + "Hz " + string(_ch) + "ch " + string(_inst.wav_cache.bits_per_sample) + "bit");

    return true;
}

function rhythm_update_analysis(_inst)
{
    if (_inst.analysis_complete) return true;
    if (_inst.wav_cache == -1) return false;

    switch (_inst.analysis_step)
    {
        case 1:
        {
            var _max = _inst.analysis_chunks_per_step;
            var _i = _inst.analysis_current_chunk;
            var _total = _inst.analysis_chunks_total;
            var _wav = _inst.wav_cache;
            var _bpc = _inst.analysis_bytes_per_chunk;
            var _processed = 0;

            while (_i < _total && _processed < _max)
            {
                var _offset = _wav.data_offset + (_i * _bpc);
                var _end = min(_offset + _bpc, _wav.data_offset + _wav.data_size);
                var _sum_sq = 0;
                var _cnt = 0;

                buffer_seek(_wav.buffer, buffer_seek_start, _offset);

                while (buffer_tell(_wav.buffer) < _end)
                {
                    var _raw = buffer_read(_wav.buffer, _wav.format);
                    var _norm;
                    if (_wav.format == buffer_u8)
                        _norm = (_raw - 128) / 128.0;
                    else
                        _norm = _raw / 32768.0;
                    _sum_sq += _norm * _norm;
                    _cnt++;
                }

                _inst.analysis_profile[_i] = (_cnt > 0) ? sqrt(_sum_sq / _cnt) : 0;

                _i++;
                _processed++;
            }

            _inst.analysis_current_chunk = _i;
            _inst.analysis_chunks_processed = _i;
            _inst.analysis_progress = 0.1 + (_i / _total) * 0.45;

            if (_i >= _total)
            {
                _inst.analysis_step = 2;
                show_debug_message("Energy profile done: " + string(array_length(_inst.analysis_profile)) + " chunks");
            }
            break;
        }

        case 2:
        {
            _inst.analysis_smoothed = scr_music_smooth_profile(_inst.analysis_profile, 12);
            _inst.analysis_smoothed = scr_music_smooth_profile(_inst.analysis_smoothed, 6);
            _inst.analysis_smoothed = scr_music_normalize_profile(_inst.analysis_smoothed);
            _inst.analysis_progress = 0.6;
            _inst.analysis_step = 3;
            show_debug_message("Profile smoothed + normalized");
            break;
        }

        case 3:
        {
            _inst.analysis_beats = scr_music_detect_beats(_inst.analysis_smoothed, 1.4);
            _inst.analysis_progress = 0.7;
            _inst.analysis_step = 4;
            show_debug_message("Beats detected: " + string(array_length(_inst.analysis_beats)));
            break;
        }

        case 4:
        {
            var _bpm = scr_music_estimate_bpm(_inst.analysis_beats, 0.5);
            if (_bpm < 80 || _bpm > 200)
                _bpm = 128;
            _inst.analysis_bpm = _bpm;
            global.bpm = _bpm;
            _inst.beat_interval = room_speed * (60 / global.bpm);
            _inst.analysis_progress = 0.8;
            _inst.analysis_step = 5;
            show_debug_message("BPM: " + string(_bpm));
            break;
        }

        case 5:
        {
            var _sections = scr_music_detect_sections(_inst.analysis_smoothed, 0.5);

            if (array_length(_sections) < 2)
            {
                var _dur = _inst.wav_cache.duration;
                _sections = [
                    { start_chunk: 0, end_chunk: floor(_dur * 2), start_time: 0, end_time: _dur * 0.3, duration: _dur * 0.3, avg_energy: 0.3, type: "INTRO" },
                    { start_chunk: 0, end_chunk: floor(_dur * 2), start_time: _dur * 0.3, end_time: _dur * 0.6, duration: _dur * 0.3, avg_energy: 0.5, type: "MAIN" },
                    { start_chunk: 0, end_chunk: floor(_dur * 2), start_time: _dur * 0.6, end_time: _dur * 0.85, duration: _dur * 0.25, avg_energy: 0.7, type: "DROP" },
                    { start_chunk: 0, end_chunk: floor(_dur * 2), start_time: _dur * 0.85, end_time: _dur, duration: _dur * 0.15, avg_energy: 0.3, type: "OUTRO" }
                ];
                show_debug_message("Fallback sections: " + string(array_length(_sections)));
            }
            else
            {
                show_debug_message("Detected " + string(array_length(_sections)) + " sections");
                for (var s = 0; s < array_length(_sections); s++)
                {
                    show_debug_message("  [" + string(s) + "] " + _sections[s].type +
                        " energy=" + string(round(_sections[s].avg_energy * 100)) + "%" +
                        " " + string(floor(_sections[s].start_time)) + "s-" + string(floor(_sections[s].end_time)) + "s");
                }
            }

            _inst.analysis_data = {
                wav: _inst.wav_cache,
                energy_profile: _inst.analysis_profile,
                smoothed_profile: _inst.analysis_smoothed,
                beats: _inst.analysis_beats,
                bpm: global.bpm,
                sections: _sections,
                duration: _inst.wav_cache.duration,
                beat_times: [],
                onset_times: [],
                onset_strength: [],
                energy_bass: [],
                energy_mids: [],
                energy_highs: [],
                tempo_curve: [],
                spectral_centroid: [],
                loudness_lufs: -16.0
            };

            global.beat_times = [];
            global.onset_times = [];
            global.onset_strengths = [];
            global.energy_bass_profile = [];
            global.energy_mids_profile = [];
            global.energy_highs_profile = [];
            global.tempo_curve = [];
            global.current_beat_index = 0;
            global.current_onset_index = 0;

            global.level_data = scr_level_generate(_inst.analysis_data);
            _inst.analysis_progress = 1.0;
            _inst.analysis_step = 6;
            _inst.analysis_complete = true;

            show_debug_message("Level: " + string(global.level_data.total_waves) + " waves, boss at wave " + string(global.level_data.boss_wave));
            break;
        }
    }

    return _inst.analysis_complete;
}

function rhythm_start_music(_inst)
{
    if (_inst.wav_cache == -1)
    {
        show_debug_message("ERROR: No WAV cache, starting without music");
        _inst.music_started = true;
        _inst.music_failed = true;
        return;
    }

    var _src = _inst.wav_cache.buffer;
    var _offset = _inst.wav_cache.data_offset;
    var _size = _inst.wav_cache.data_size;

    var _types = [buffer_fast, buffer_fixed, buffer_grow];
    var _buf_snd = -1;
    var _play_buf = -1;

    for (var _t = 0; _t < array_length(_types); _t++)
    {
        _play_buf = buffer_create(_size, _types[_t], 1);
        if (_play_buf == -1) continue;

        buffer_copy(_src, _offset, _size, _play_buf, 0);

        _buf_snd = audio_create_buffer_sound(
            _play_buf,
            _inst.wav_cache.format,
            _inst.wav_cache.sample_rate,
            0,
            _size,
            _inst.wav_cache.channels == 1 ? audio_mono : audio_stereo
        );

        if (_buf_snd != -1)
        {
            show_debug_message("Music started with buffer type " + string(_types[_t]));
            break;
        }
        buffer_delete(_play_buf);
        _play_buf = -1;
    }

    if (_buf_snd == -1)
    {
        show_debug_message("ERROR: All buffer types failed, starting without music");
        _inst.music_started = true;
        _inst.music_failed = true;
        return;
    }

    _inst.play_buffer = _play_buf;
    _inst.buffer_sound_id = _buf_snd;
    _inst.current_sound = audio_play_sound(_buf_snd, 0, false);
    audio_sound_gain(_inst.current_sound, 0.7, 0);
    _inst.music_started = true;
    _inst.music_failed = false;
    _inst.last_beat_fired_index = -1;
    show_debug_message("Music playing: sound ID=" + string(_inst.current_sound));
}

function rhythm_stop_music(_inst)
{
    if (_inst.current_sound != -1 && audio_is_playing(_inst.current_sound))
    {
        audio_stop_sound(_inst.current_sound);
    }
    if (variable_instance_exists(_inst, "buffer_sound_id") && _inst.buffer_sound_id != -1)
    {
        if (audio_exists(_inst.buffer_sound_id))
            audio_free_buffer_sound(_inst.buffer_sound_id);
        _inst.buffer_sound_id = -1;
    }
    if (variable_instance_exists(_inst, "play_buffer") && _inst.play_buffer != -1)
    {
        buffer_delete(_inst.play_buffer);
        _inst.play_buffer = -1;
    }
    _inst.current_sound = -1;
    _inst.music_started = false;
}

function rhythm_update_beat(_inst)
{
    global.on_beat = false;

    if (!_inst.music_started || _inst.current_sound == -1 || !audio_is_playing(_inst.current_sound))
    {
        return;
    }

    var _pos = audio_sound_get_track_position(_inst.current_sound);
    var _pos_sec = _pos / 1000;

    if (array_length(global.beat_times) > 0)
    {
        while (global.current_beat_index < array_length(global.beat_times) - 1
            && global.beat_times[global.current_beat_index + 1] <= _pos_sec)
        {
            global.current_beat_index++;
        }

        if (global.current_beat_index != _inst.last_beat_fired_index)
        {
            _inst.last_beat_fired_index = global.current_beat_index;
            global.on_beat = true;
            global.beat_flash = 1;
            global.beat_count = global.current_beat_index;
            global.beat_in_measure = global.current_beat_index mod 8;
        }
    }
    else
    {
        var _beat_sec = 60 / global.bpm;
        var _current_beat = floor(_pos_sec / _beat_sec);

        if (_current_beat != global.beat_count)
        {
            global.beat_count = _current_beat;
            global.beat_in_measure = _current_beat mod 8;
            global.on_beat = true;
            global.beat_flash = 1;
        }
    }

    if (array_length(global.onset_times) > 0)
    {
        while (global.current_onset_index < array_length(global.onset_times) - 1
            && global.onset_times[global.current_onset_index + 1] <= _pos_sec)
        {
            global.current_onset_index++;
        }

        var _ot = global.onset_times[global.current_onset_index];
        var _time_since_onset = _pos_sec - _ot;
        if (_time_since_onset < 0.15 && global.current_onset_index < array_length(global.onset_strengths))
        {
            global.onset_intensity = global.onset_strengths[global.current_onset_index];
        }
        else
        {
            global.onset_intensity = max(0, global.onset_intensity - 0.05);
        }
    }

    if (array_length(global.energy_bass_profile) > 0)
    {
        var _chunk_sec = 0.5;
        var _chunk_idx = floor(_pos_sec / _chunk_sec);
        _chunk_idx = clamp(_chunk_idx, 0, array_length(global.energy_bass_profile) - 1);
        global.energy_bass = global.energy_bass_profile[_chunk_idx];

        _chunk_idx = clamp(_chunk_idx, 0, array_length(global.energy_mids_profile) - 1);
        global.energy_mids = global.energy_mids_profile[_chunk_idx];

        _chunk_idx = clamp(_chunk_idx, 0, array_length(global.energy_highs_profile) - 1);
        global.energy_highs = global.energy_highs_profile[_chunk_idx];

        if (array_length(global.spectral_centroid_profile) > 0)
        {
            _chunk_idx = clamp(_chunk_idx, 0, array_length(global.spectral_centroid_profile) - 1);
            global.spectral_centroid = global.spectral_centroid_profile[_chunk_idx];
        }

        if (array_length(global.spectral_flatness_profile) > 0)
        {
            _chunk_idx = clamp(_chunk_idx, 0, array_length(global.spectral_flatness_profile) - 1);
            global.spectral_flatness = global.spectral_flatness_profile[_chunk_idx];
        }

        if (array_length(global.peak_density_profile) > 0)
        {
            _chunk_idx = clamp(_chunk_idx, 0, array_length(global.peak_density_profile) - 1);
            global.peak_density = global.peak_density_profile[_chunk_idx];
        }

        if (array_length(global.onset_power_profile) > 0)
        {
            _chunk_idx = clamp(_chunk_idx, 0, array_length(global.onset_power_profile) - 1);
        }

        if (array_length(global.chroma_profiles) == 12 && global.on_beat)
        {
            var _max_chroma = 0;
            var _max_idx = 0;
            for (var _c = 0; _c < 12; _c++)
            {
                if (array_length(global.chroma_profiles[_c]) > 0)
                {
                    var _ci = clamp(_chunk_idx, 0, array_length(global.chroma_profiles[_c]) - 1);
                    if (global.chroma_profiles[_c][_ci] > _max_chroma)
                    {
                        _max_chroma = global.chroma_profiles[_c][_ci];
                        _max_idx = _c;
                    }
                }
            }
            global.chroma_dominant = _max_idx;

            var _cr = 0; var _cg = 0; var _cb = 0;
            for (var _c = 0; _c < 12; _c++)
            {
                if (array_length(global.chroma_profiles[_c]) > 0)
                {
                    var _ci2 = clamp(_chunk_idx, 0, array_length(global.chroma_profiles[_c]) - 1);
                    var _val = global.chroma_profiles[_c][_ci2];
                    switch (_c)
                    {
                        case 0: case 1: _cr += _val; break;
                        case 2: case 3: case 4: _cr += _val * 0.5; _cg += _val * 0.5; break;
                        case 5: case 6: case 7: _cg += _val; break;
                        case 8: case 9: _cg += _val * 0.5; _cb += _val * 0.5; break;
                        case 10: case 11: _cb += _val; break;
                    }
                }
            }
            var _ctotal = _cr + _cg + _cb;
            if (_ctotal > 0)
            {
                global.chroma_r = _cr / _ctotal;
                global.chroma_g = _cg / _ctotal;
                global.chroma_b = _cb / _ctotal;
            }
        }
    }
    else
    {
        global.energy_bass = global.music_energy;
        global.energy_mids = global.music_energy;
        global.energy_highs = global.music_energy;
    }

    if (global.on_beat && global.current_beat_index < array_length(global.beat_strengths_arr))
    {
        global.beat_strength = global.beat_strengths_arr[global.current_beat_index];
    }

    global.music_energy = audio_sound_get_gain(_inst.current_sound);
}

function rhythm_cleanup(_inst)
{
    if (_inst.wav_cache != -1 && variable_struct_exists(_inst.wav_cache, "buffer"))
    {
        if (audio_exists(_inst.current_sound))
        {
            audio_stop_sound(_inst.current_sound);
        }
        if (variable_instance_exists(_inst, "buffer_sound_id") && _inst.buffer_sound_id != -1)
        {
            if (audio_exists(_inst.buffer_sound_id))
                audio_free_buffer_sound(_inst.buffer_sound_id);
            _inst.buffer_sound_id = -1;
        }
        buffer_delete(_inst.wav_cache.buffer);
    }
    if (variable_instance_exists(_inst, "play_buffer") && _inst.play_buffer != -1)
    {
        buffer_delete(_inst.play_buffer);
        _inst.play_buffer = -1;
    }
    _inst.wav_cache = -1;
    _inst.analysis_data = -1;
}
