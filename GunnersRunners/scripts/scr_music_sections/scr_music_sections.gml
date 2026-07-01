function scr_music_classify_section(_avg_energy, _prev_energy, _next_energy)
{
    var _rising = (_next_energy > _avg_energy + 0.05);
    var _falling = (_next_energy < _avg_energy - 0.05);

    if (_avg_energy < 0.15) return "INTRO";
    if (_avg_energy < 0.30 && _rising) return "BUILDUP";
    if (_avg_energy > 0.50) return "DROP";
    if (_avg_energy > 0.30 && !_falling) return "MAIN";
    if (_avg_energy < 0.18 && _falling) return "BREAK";
    if (_avg_energy < 0.25) return "OUTRO";

    return "MAIN";
}

function scr_music_detect_sections(_smoothed_profile, _chunk_dur)
{
    var _chunk_sec = 0.5;
    var _sections = [];
    var _len = array_length(_smoothed_profile);

    if (_len < 4) return _sections;

    var _min_section_chunks = 8;
    var _change_threshold = 0.06;

    var _current_start = 0;
    var _current_energy = _smoothed_profile[0];

    for (var i = 1; i < _len; i++)
    {
        var _delta = abs(_smoothed_profile[i] - _current_energy);

        if (_delta > _change_threshold && (i - _current_start) >= _min_section_chunks)
        {
            var _sum = 0;
            for (var j = _current_start; j < i; j++)
                _sum += _smoothed_profile[j];
            var _avg = _sum / (i - _current_start);

            var _next_avg = _avg;
            var _nend = min(i + _min_section_chunks, _len);
            if (_nend > i)
            {
                var _nsum = 0;
                for (var j = i; j < _nend; j++)
                    _nsum += _smoothed_profile[j];
                _next_avg = _nsum / (_nend - i);
            }

            var _type = scr_music_classify_section(_avg, _current_energy, _next_avg);

            array_push(_sections, {
                start_chunk: _current_start,
                end_chunk: i - 1,
                start_time: _current_start * _chunk_sec,
                end_time: (i - 1) * _chunk_sec,
                duration: (i - 1 - _current_start) * _chunk_sec,
                avg_energy: _avg,
                type: _type
            });

            _current_start = i;
            _current_energy = _smoothed_profile[i];
        }
    }

    var _sum = 0;
    for (var j = _current_start; j < _len; j++)
        _sum += _smoothed_profile[j];
    var _avg = _sum / max(1, _len - _current_start);

    array_push(_sections, {
        start_chunk: _current_start,
        end_chunk: _len - 1,
        start_time: _current_start * _chunk_sec,
        end_time: (_len - 1) * _chunk_sec,
        duration: (_len - 1 - _current_start) * _chunk_sec,
        avg_energy: _avg,
        type: scr_music_classify_section(_avg, _current_energy, 0)
    });

    return _sections;
}

function scr_music_get_section_at_time(_sections, _time)
{
    for (var i = 0; i < array_length(_sections); i++)
    {
        if (_time >= _sections[i].start_time && _time <= _sections[i].end_time)
            return _sections[i];
    }
    return _sections[array_length(_sections) - 1];
}
