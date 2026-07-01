function music_import_scan()
{
    var _songs_dir = game_save_id + "songs/";
    var _files = [];
    var _names = [];

    if (directory_exists(_songs_dir))
    {
        var _f = file_find_first(_songs_dir + "*.wav", fa_none);
        while (_f != "")
        {
            var _full = _songs_dir + _f;
            var _display_name = string_replace(_f, ".wav", "");
            _display_name = string_replace_all(_display_name, "_", " ");
            _display_name = string_upper(string_char_at(_display_name, 1)) + string_delete(_display_name, 1, 1);

            array_push(_files, _full);
            array_push(_names, _display_name + " [IMPORTED]");

            _f = file_find_next();
        }
        file_find_close();
    }

    return { files: _files, names: _names };
}

function music_import_scan_pending()
{
    var _songs_dir = game_save_id + "songs/";
    var _files = [];
    var _names = [];

    if (directory_exists(_songs_dir))
    {
        var _f = file_find_first(_songs_dir + "*.mp3", fa_none);
        while (_f != "")
        {
            var _full = _songs_dir + _f;
            var _wav_check = string_replace(_full, ".mp3", ".wav");
            if (!file_exists(_wav_check))
            {
                var _display_name = string_replace(_f, ".mp3", "");
                _display_name = string_replace_all(_display_name, "_", " ");
                _display_name = string_upper(string_char_at(_display_name, 1)) + string_delete(_display_name, 1, 1);
                array_push(_files, _full);
                array_push(_names, _display_name + " [NEEDS CONVERSION]");
            }
            _f = file_find_next();
        }
        file_find_close();
    }

    return { files: _files, names: _names };
}

function music_import_buffer_copy(_source_path, _dest_path)
{
    var _buff = buffer_load(_source_path);
    if (_buff == -1)
    {
        show_debug_message("IMPORT BUFFER ERROR: Could not load source: " + _source_path);
        return false;
    }

    if (file_exists(_dest_path))
        file_delete(_dest_path);

    buffer_save(_buff, _dest_path);
    var _size = buffer_get_size(_buff);
    buffer_delete(_buff);

    if (!file_exists(_dest_path))
    {
        show_debug_message("IMPORT BUFFER ERROR: Could not save to: " + _dest_path);
        return false;
    }

    show_debug_message("IMPORT BUFFER: Copied " + string(_size) + " bytes: " + _dest_path);
    return true;
}

function music_import_start(_source_path)
{
    var _songs_dir = game_save_id + "songs/";
    show_debug_message("IMPORT: game_save_id = " + game_save_id);
    show_debug_message("IMPORT: Source file = " + _source_path);
    show_debug_message("IMPORT: Source exists = " + string(file_exists(_source_path)));

    if (!directory_exists(_songs_dir))
    {
        directory_create(_songs_dir);
        show_debug_message("IMPORT: Created songs directory: " + _songs_dir);
    }

    var _filename = filename_name(_source_path);
    var _ext = string_lower(filename_ext(_source_path));

    if (_ext == ".mp3")
    {
        var _dest = _songs_dir + _filename;
        show_debug_message("IMPORT: MP3 detected, copying to songs folder: " + _dest);

        var _ok = music_import_buffer_copy(_source_path, _dest);
        if (!_ok)
        {
            show_debug_message("IMPORT ERROR: Could not copy MP3 to " + _dest);
            return -1;
        }

        show_debug_message("IMPORT: MP3 copied to songs folder. Auto-converter will process it.");
        return "MP3:" + _dest;
    }

    if (_ext != ".wav")
    {
        show_debug_message("IMPORT ERROR: Unsupported format: " + _ext);
        return -1;
    }

    var _dest = _songs_dir + _filename;
    show_debug_message("IMPORT: Destination = " + _dest);

    var _ok = music_import_buffer_copy(_source_path, _dest);
    if (!_ok)
    {
        show_debug_message("IMPORT ERROR: Could not copy WAV to " + _dest);
        return -1;
    }

    show_debug_message("IMPORT: File copied successfully");

    var _json_path = _songs_dir + string_replace(_filename, ".wav", ".json");
    if (file_exists(_json_path))
        file_delete(_json_path);

    return _dest;
}

function music_import_save_json(_json_path, _analysis_data, _level_data)
{
    var _save_data = {
        bpm: _analysis_data.bpm,
        duration: _analysis_data.duration,
        sections: _analysis_data.sections,
        waves: _level_data.waves,
        total_waves: _level_data.total_waves,
        boss_wave: _level_data.boss_wave,
        energy_profile: _analysis_data.energy_profile,
        smoothed_profile: _analysis_data.smoothed_profile
    };

    var _json = json_stringify(_save_data);
    var _buff = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buff, buffer_string, _json);
    buffer_save(_buff, _json_path);
    buffer_delete(_buff);

    show_debug_message("IMPORT: Saved analysis to " + _json_path);
}

function music_import_load_json(_json_path)
{
    if (!file_exists(_json_path))
        return -1;

    var _buff = buffer_load(_json_path);
    if (_buff == -1) return -1;

    buffer_seek(_buff, buffer_seek_start, 0);
    var _json = buffer_read(_buff, buffer_string);
    buffer_delete(_buff);

    var _data = json_parse(_json);
    if (!is_struct(_data))
        return -1;

    show_debug_message("IMPORT: Loaded analysis from " + _json_path);
    return _data;
}

function music_import_has_json(_wav_path)
{
    var _json_path = string_replace(_wav_path, ".wav", ".json");
    return file_exists(_json_path);
}
