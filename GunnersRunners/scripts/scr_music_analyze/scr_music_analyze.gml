function scr_music_load_wav(_filename)
{
    show_debug_message("WAV LOAD: Attempting to load: " + _filename);
    show_debug_message("WAV LOAD: File exists: " + string(file_exists(_filename)));

    var _buff = buffer_load(_filename);
    if (_buff == -1)
    {
        show_debug_message("WAV LOAD: buffer_load FAILED for: " + _filename);
        return -1;
    }

    show_debug_message("WAV LOAD: Buffer loaded, size: " + string(buffer_get_size(_buff)));

    buffer_seek(_buff, buffer_seek_start, 0);

    var _riff = "";
    repeat(4) _riff += chr(buffer_read(_buff, buffer_u8));
    buffer_read(_buff, buffer_u32);

    var _wave = "";
    repeat(4) _wave += chr(buffer_read(_buff, buffer_u8));

    show_debug_message("WAV LOAD: Header check - RIFF='" + _riff + "' WAVE='" + _wave + "'");

    if (_riff != "RIFF" || _wave != "WAVE")
    {
        show_debug_message("WAV LOAD: NOT a valid WAV file (bad header)");
        buffer_delete(_buff);
        return -1;
    }

    var _format = 0;
    var _channels = 0;
    var _sample_rate = 0;
    var _bits_per_sample = 0;
    var _data_offset = 0;
    var _data_size = 0;

    while (buffer_tell(_buff) < buffer_get_size(_buff) - 8)
    {
        var _chunk_id = "";
        repeat(4) _chunk_id += chr(buffer_read(_buff, buffer_u8));
        var _chunk_size = buffer_read(_buff, buffer_u32);

        switch (_chunk_id)
        {
            case "fmt ":
                _format = buffer_read(_buff, buffer_u16);
                _channels = buffer_read(_buff, buffer_u16);
                _sample_rate = buffer_read(_buff, buffer_u32);
                buffer_read(_buff, buffer_u32);
                buffer_read(_buff, buffer_u16);
                _bits_per_sample = buffer_read(_buff, buffer_u16);
                if (_chunk_size > 16)
                    buffer_seek(_buff, buffer_seek_relative, _chunk_size - 16);
                break;

            case "data":
                _data_offset = buffer_tell(_buff);
                _data_size = _chunk_size;
                buffer_seek(_buff, buffer_seek_relative, _chunk_size);
                break;

            default:
                buffer_seek(_buff, buffer_seek_relative, _chunk_size);
                break;
        }
    }

    var _bytes_per_sample = _bits_per_sample / 8;
    var _duration = _data_size / (_sample_rate * _channels * _bytes_per_sample);

    show_debug_message("WAV LOAD: format=" + string(_format) + " channels=" + string(_channels) +
        " rate=" + string(_sample_rate) + " bits=" + string(_bits_per_sample) +
        " data_offset=" + string(_data_offset) + " data_size=" + string(_data_size) +
        " duration=" + string(floor(_duration)) + "s");

    if (_format != 1)
    {
        show_debug_message("WAV LOAD: WARNING - format=" + string(_format) + " (1=PCM, expected PCM)");
    }
    if (_data_size <= 0)
    {
        show_debug_message("WAV LOAD: ERROR - no data chunk found");
        buffer_delete(_buff);
        return -1;
    }

    return {
        buffer: _buff,
        format: (_bits_per_sample == 8) ? buffer_u8 : buffer_s16,
        channels: _channels,
        sample_rate: _sample_rate,
        bits_per_sample: _bits_per_sample,
        data_offset: _data_offset,
        data_size: _data_size,
        bytes_per_sample: _bytes_per_sample,
        duration: _duration
    };
}

function scr_music_get_energy_profile(_wav_data, _chunk_sec)
{
    if (_wav_data == -1) return [];

    var _chunk_size = _chunk_sec || 0.5;
    var _bytes_per_frame = _wav_data.bytes_per_sample * _wav_data.channels;
    var _samples_per_chunk = _wav_data.sample_rate * _chunk_size;
    var _bytes_per_chunk = _samples_per_chunk * _bytes_per_frame;
    var _num_chunks = floor(_wav_data.data_size / _bytes_per_chunk);

    if (_num_chunks <= 0) return [];

    var _profile = array_create(_num_chunks, 0);

    for (var i = 0; i < _num_chunks; i++)
    {
        var _offset = _wav_data.data_offset + (i * _bytes_per_chunk);
        var _sum_squares = 0;
        var _count = 0;

        buffer_seek(_wav_data.buffer, buffer_seek_start, _offset);

        var _end = min(_offset + _bytes_per_chunk, _wav_data.data_offset + _wav_data.data_size);

        while (buffer_tell(_wav_data.buffer) < _end)
        {
            var _raw = buffer_read(_wav_data.buffer, _wav_data.format);
            var _norm;

            if (_wav_data.format == buffer_u8)
                _norm = (_raw - 128) / 128.0;
            else
                _norm = _raw / 32768.0;

            _sum_squares += _norm * _norm;
            _count++;
        }

        if (_count > 0)
            _profile[i] = sqrt(_sum_squares / _count);
    }

    return _profile;
}

function scr_music_smooth_profile(_profile, _win)
{
    var _win_size = _win || 12;
    var _len = array_length(_profile);
    if (_len == 0) return [];

    var _smoothed = array_create(_len, 0);

    for (var i = 0; i < _len; i++)
    {
        var _sum = 0;
        var _count = 0;
        for (var j = max(0, i - _win_size); j <= min(_len - 1, i + _win_size); j++)
        {
            _sum += _profile[j];
            _count++;
        }
        _smoothed[i] = _sum / _count;
    }

    return _smoothed;
}

function scr_music_normalize_profile(_profile)
{
    var _len = array_length(_profile);
    if (_len == 0) return [];

    var _min = 999999;
    var _max = 0;
    for (var i = 0; i < _len; i++)
    {
        if (_profile[i] < _min) _min = _profile[i];
        if (_profile[i] > _max) _max = _profile[i];
    }

    var _range = _max - _min;
    if (_range < 0.001) return array_create(_len, 0.5);

    var _result = array_create(_len, 0);
    for (var i = 0; i < _len; i++)
    {
        _result[i] = (_profile[i] - _min) / _range;
    }

    return _result;
}

function scr_music_detect_beats(_profile, _thresh)
{
    var _threshold = _thresh || 1.8;
    var _beats = [];
    var _window = 10;
    var _min_gap = 4;

    if (array_length(_profile) < _window) return _beats;

    var _last_beat_chunk = -_min_gap;

    for (var i = _window; i < array_length(_profile); i++)
    {
        var _sum = 0;
        for (var j = i - _window; j < i; j++)
            _sum += _profile[j];
        var _avg = _sum / _window;

        if (_avg > 0.01 && _profile[i] > _avg * _threshold && (i - _last_beat_chunk) >= _min_gap)
        {
            array_push(_beats, {
                chunk: i,
                energy: _profile[i],
                strength: _profile[i] / _avg
            });
            _last_beat_chunk = i;
        }
    }

    return _beats;
}

function scr_music_estimate_bpm(_beats, _chunk_dur)
{
    var _chunk_size = _chunk_dur || 0.5;
    if (array_length(_beats) < 4) return 120;

    var _intervals = [];
    for (var i = 1; i < array_length(_beats); i++)
    {
        var _diff = _beats[i].chunk - _beats[i - 1].chunk;
        if (_diff > 1)
            array_push(_intervals, _diff);
    }

    if (array_length(_intervals) < 3) return 120;

    array_sort(_intervals, true);

    var _mid = array_length(_intervals) div 2;
    var _median = _intervals[_mid];

    var _sum = 0;
    var _count = 0;
    for (var i = 0; i < array_length(_intervals); i++)
    {
        if (abs(_intervals[i] - _median) <= _median * 0.5)
        {
            _sum += _intervals[i];
            _count++;
        }
    }

    if (_count < 3) return 120;

    var _avg_interval = _sum / _count;

    var _bpm = 60 / (_avg_interval * _chunk_size);

    if (_bpm > 160)
        _bpm = _bpm / 2;
    else if (_bpm < 70)
        _bpm = _bpm * 2;

    _bpm = round(_bpm);
    _bpm = clamp(_bpm, 80, 180);

    return _bpm;
}

function scr_music_analyze_full(_filename)
{
    var _json_path = string_replace(_filename, ".wav", ".json");
    if (file_exists(_json_path))
    {
        var _json_data = scr_music_load_analysis_json(_json_path);
        if (_json_data != -1)
        {
            show_debug_message("ANALYSIS: Loaded pre-computed JSON from Python analyzer");
            return _json_data;
        }
    }

    show_debug_message("ANALYSIS: No JSON found, running GameMaker analysis");

    var _wav = scr_music_load_wav(_filename);
    if (_wav == -1) return -1;

    var _profile = scr_music_get_energy_profile(_wav, 0.5);
    var _smoothed = scr_music_smooth_profile(_profile, 12);
    _smoothed = scr_music_smooth_profile(_smoothed, 6);
    _smoothed = scr_music_normalize_profile(_smoothed);
    var _beats = scr_music_detect_beats(_smoothed, 1.4);
    var _bpm = scr_music_estimate_bpm(_beats, 0.5);
    var _sections = scr_music_detect_sections(_smoothed, 0.5);

    return {
        wav: _wav,
        energy_profile: _profile,
        smoothed_profile: _smoothed,
        beats: _beats,
        bpm: _bpm,
        sections: _sections,
        duration: _wav.duration,
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
}

function scr_music_load_analysis_json(_json_path)
{
    if (!file_exists(_json_path))
    {
        show_debug_message("JSON LOAD: File not found: " + _json_path);
        return -1;
    }

    var _buff = buffer_load(_json_path);
    if (_buff == -1)
    {
        show_debug_message("JSON LOAD: Failed to load buffer: " + _json_path);
        return -1;
    }

    buffer_seek(_buff, buffer_seek_start, 0);
    var _json = buffer_read(_buff, buffer_string);
    buffer_delete(_buff);

    var _data = json_parse(_json);
    if (!is_struct(_data))
    {
        show_debug_message("JSON LOAD: Failed to parse JSON");
        return -1;
    }

    var _bpm = 120;
    var _duration = 0;
    var _beat_regularity = 0.5;
    var _dynamic_range = 20;
    var _loudness = -16.0;
    if (variable_struct_exists(_data, "bpm")) _bpm = _data.bpm;
    if (variable_struct_exists(_data, "duration")) _duration = _data.duration;
    if (variable_struct_exists(_data, "beat_regularity")) _beat_regularity = _data.beat_regularity;
    if (variable_struct_exists(_data, "dynamic_range")) _dynamic_range = _data.dynamic_range;
    if (variable_struct_exists(_data, "loudness_lufs")) _loudness = _data.loudness_lufs;

    var _sections_raw = [];
    if (variable_struct_exists(_data, "sections")) _sections_raw = _data.sections;

    var _sections = [];
    for (var i = 0; i < array_length(_sections_raw); i++)
    {
        var _s = _sections_raw[i];
        var _st = 0; var _et = 0; var _en = 0.5; var _ty = "MAIN";
        var _sb = 0.5; var _sm = 0.5; var _sh = 0.5;
        var _sop = 0.5; var _spd = 0.5;
        if (variable_struct_exists(_s, "start_time")) _st = _s.start_time;
        if (variable_struct_exists(_s, "end_time")) _et = _s.end_time;
        if (variable_struct_exists(_s, "energy")) _en = _s.energy;
        if (variable_struct_exists(_s, "type")) _ty = _s.type;
        if (variable_struct_exists(_s, "energy_bass")) _sb = _s.energy_bass;
        if (variable_struct_exists(_s, "energy_mids")) _sm = _s.energy_mids;
        if (variable_struct_exists(_s, "energy_highs")) _sh = _s.energy_highs;
        if (variable_struct_exists(_s, "onset_power")) _sop = _s.onset_power;
        if (variable_struct_exists(_s, "peak_density")) _spd = _s.peak_density;
        array_push(_sections, {
            start_time: _st, end_time: _et, start_chunk: 0, end_chunk: 0,
            duration: _et - _st, avg_energy: _en, type: _ty,
            energy_bass: _sb, energy_mids: _sm, energy_highs: _sh,
            onset_power: _sop, peak_density: _spd
        });
    }

    var _energy = []; var _beat_times = []; var _beat_strengths = [];
    var _onset_times = []; var _onset_strength = [];
    var _energy_bass = []; var _energy_mids = []; var _energy_highs = [];
    var _tempo_curve = []; var _spectral_centroid = []; var _spectral_flatness = [];
    var _peak_density = []; var _onset_power = [];
    var _chroma_data = [];

    if (variable_struct_exists(_data, "energy_profile")) _energy = _data.energy_profile;
    if (variable_struct_exists(_data, "beat_times")) _beat_times = _data.beat_times;
    if (variable_struct_exists(_data, "beat_strengths")) _beat_strengths = _data.beat_strengths;
    if (variable_struct_exists(_data, "onset_times")) _onset_times = _data.onset_times;
    if (variable_struct_exists(_data, "onset_strength")) _onset_strength = _data.onset_strength;
    if (variable_struct_exists(_data, "energy_bass")) _energy_bass = _data.energy_bass;
    if (variable_struct_exists(_data, "energy_mids")) _energy_mids = _data.energy_mids;
    if (variable_struct_exists(_data, "energy_highs")) _energy_highs = _data.energy_highs;
    if (variable_struct_exists(_data, "tempo_curve")) _tempo_curve = _data.tempo_curve;
    if (variable_struct_exists(_data, "spectral_centroid")) _spectral_centroid = _data.spectral_centroid;
    if (variable_struct_exists(_data, "spectral_flatness")) _spectral_flatness = _data.spectral_flatness;
    if (variable_struct_exists(_data, "peak_density")) _peak_density = _data.peak_density;
    if (variable_struct_exists(_data, "onset_power")) _onset_power = _data.onset_power;

    if (variable_struct_exists(_data, "chroma"))
    {
        var _chroma_obj = _data.chroma;
        var _chroma_names = ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"];
        for (var c = 0; c < 12; c++)
        {
            if (variable_struct_exists(_chroma_obj, _chroma_names[c]))
                array_push(_chroma_data, _chroma_obj[$ _chroma_names[c]]);
            else
                array_push(_chroma_data, []);
        }
    }

    var _smoothed = scr_music_smooth_profile(_energy, 6);
    _smoothed = scr_music_normalize_profile(_smoothed);

    show_debug_message("JSON LOAD v3: BPM=" + string(_bpm) + " Duration=" + string(_duration) +
        " Sections=" + string(array_length(_sections)) +
        " Beats=" + string(array_length(_beat_times)) +
        " Onsets=" + string(array_length(_onset_times)) +
        " Chroma=" + string(array_length(_chroma_data)) +
        " DynRange=" + string(_dynamic_range) + "dB");

    return {
        wav: -1,
        energy_profile: _energy,
        smoothed_profile: _smoothed,
        beats: [],
        bpm: _bpm,
        sections: _sections,
        duration: _duration,
        beat_times: _beat_times,
        beat_strengths: _beat_strengths,
        beat_regularity: _beat_regularity,
        onset_times: _onset_times,
        onset_strength: _onset_strength,
        energy_bass: _energy_bass,
        energy_mids: _energy_mids,
        energy_highs: _energy_highs,
        tempo_curve: _tempo_curve,
        spectral_centroid: _spectral_centroid,
        spectral_flatness: _spectral_flatness,
        peak_density: _peak_density,
        onset_power: _onset_power,
        chroma_data: _chroma_data,
        loudness_lufs: _loudness,
        dynamic_range: _dynamic_range
    };
}
