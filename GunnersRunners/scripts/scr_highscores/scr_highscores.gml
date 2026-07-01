function highscores_load()
{
    var _path = game_save_id + "highscores.json";
    if (!file_exists(_path))
    {
        global.highscores = {};
        return;
    }

    var _buff = buffer_load(_path);
    if (_buff == -1)
    {
        global.highscores = {};
        return;
    }

    buffer_seek(_buff, buffer_seek_start, 0);
    var _json = buffer_read(_buff, buffer_string);
    buffer_delete(_buff);

    var _data = json_parse(_json);
    if (is_struct(_data))
        global.highscores = _data;
    else
        global.highscores = {};
}

function highscores_save()
{
    var _path = game_save_id + "highscores.json";
    var _json = json_stringify(global.highscores);
    var _buff = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buff, buffer_string, _json);
    buffer_save(_buff, _path);
    buffer_delete(_buff);
}

function highscores_add(_song_key, _score, _wave, _combo, _time_s, _rank)
{
    if (!variable_struct_exists(global.highscores, _song_key))
        global.highscores[$ _song_key] = [];

    var _list = global.highscores[$ _song_key];

    var _entry = {
        score: _score,
        wave: _wave,
        combo: _combo,
        time: _time_s,
        rank: _rank
    };

    array_push(_list, _entry);

    array_sort(_list, function(_a, _b) {
        return _b.score - _a.score;
    });

    if (array_length(_list) > 5)
        array_resize(_list, 5);

    highscores_save();
}

function highscores_get_best(_song_key)
{
    if (!variable_struct_exists(global.highscores, _song_key))
        return -1;

    var _list = global.highscores[$ _song_key];
    if (array_length(_list) == 0)
        return -1;

    return _list[0];
}

function highscores_is_new_record(_song_key, _score)
{
    var _best = highscores_get_best(_song_key);
    if (_best == -1) return true;
    return _score > _best.score;
}

function highscores_get_rank(_score, _combo, _is_victory)
{
    if (!_is_victory) return "-";

    if (_score > 100000 && _combo >= 80) return "S";
    if (_score > 60000 && _combo >= 50) return "A";
    if (_score > 35000 && _combo >= 30) return "B";
    if (_score > 15000) return "C";
    if (_score > 5000) return "D";
    return "D";
}

function highscores_format_time(_frames)
{
    var _total_ms = (_frames / 60) * 1000;
    var _mins = _total_ms div 60000;
    var _secs = (_total_ms mod 60000) div 1000;
    var _ms = _total_ms mod 1000;
    return string_replace(string_format(_mins, 2, 0), " ", "0") + ":" +
           string_replace(string_format(_secs, 2, 0), " ", "0") + ":" +
           string_replace(string_format(_ms, 3, 0), " ", "0");
}

function highscores_get_song_key(_path)
{
    var _name = filename_name(_path);
    _name = string_replace(_name, ".wav", "");
    _name = string_replace(_name, ".mp3", "");
    return _name;
}
