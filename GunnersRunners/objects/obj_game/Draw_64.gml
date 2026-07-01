draw_set_font(-1);

switch (global.game_state)
{
    case "SELECT_MUSIC":
        draw_clear(make_color_rgb(12, 12, 20));

        menu_bg_time += 0.016;
        menu_pulse = (menu_pulse + 0.03) mod (pi * 2);
        track_card_alpha = min(1, track_card_alpha + 0.04);
        track_card_slide = lerp(track_card_slide, 0, 0.12);

        for (var i = 0; i < array_length(menu_particles); i++)
        {
            var _p = menu_particles[i];
            _p.life++;
            _p.x += _p.vx + sin(_p.life * 0.02) * 0.3;
            _p.y += _p.vy;
            if (_p.y < -10 || _p.life > 700)
            {
                _p.x = random(room_width);
                _p.y = room_height + 10;
                _p.life = 0;
            }
            var _pa = _p.alpha * (0.5 + 0.5 * sin(_p.life * 0.05));
            draw_set_color(_p.color);
            draw_set_alpha(_pa);
            draw_circle(_p.x, _p.y, _p.size, false);
        }
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(40, 40, 70));
        draw_set_alpha(0.15);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        for (var i = 0; i < 5; i++)
        {
            var _line_y = 100 + i * 130;
            var _line_a = 0.03 + 0.02 * sin(menu_bg_time * 0.8 + i * 0.7);
            draw_set_color(make_color_rgb(80, 120, 200));
            draw_set_alpha(_line_a);
            draw_line_width(0, _line_y, room_width, _line_y, 1);
        }
        draw_set_alpha(1);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        var _title_y = 85;
        draw_set_color(make_color_rgb(255, 40, 40));
        draw_set_alpha(0.12);
        draw_text_transformed(room_width / 2 + 2, _title_y + 2, "GUNNERS", 2.8, 2.8, 0);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 60, 60));
        draw_text_transformed(room_width / 2, _title_y, "GUNNERS", 2.7, 2.7, 0);

        var _glow_alpha = 0.15 + 0.1 * sin(menu_pulse * 1.5);
        draw_set_color(make_color_rgb(255, 200, 50));
        draw_set_alpha(_glow_alpha);
        draw_text_transformed(room_width / 2, _title_y + 3, "GUNNERS", 2.9, 2.9, 0);
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(255, 200, 50));
        draw_text_transformed(room_width / 2, _title_y + 52, "RUNNERS", 2.7, 2.7, 0);

        draw_set_color(make_color_rgb(180, 180, 200));
        draw_set_alpha(0.5);
        draw_text_transformed(room_width / 2, _title_y + 88, "- SELECT YOUR TRACK -", 0.7, 0.7, 0);
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(80, 80, 120));
        draw_line_width(room_width / 2 - 250, _title_y + 108, room_width / 2 + 250, _title_y + 108, 1);

        var _list_top = 230;
        var _card_h = 72;
        var _card_w = 560;
        var _list_h = max_visible * _card_h;

        draw_set_color(c_black);
        draw_set_alpha(0.25);
        draw_rectangle(room_width / 2 - _card_w / 2 - 15, _list_top - 15, room_width / 2 + _card_w / 2 + 15, _list_top + _list_h + 15, false);
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(60, 60, 90));
        draw_set_alpha(0.3);
        draw_rectangle(room_width / 2 - _card_w / 2 - 15, _list_top - 15, room_width / 2 + _card_w / 2 + 15, _list_top + _list_h + 15, true);
        draw_set_alpha(1);

        var _view_start = scroll_offset;
        var _view_end = min(_view_start + max_visible, array_length(music_names));

        for (var i = _view_start; i < _view_end; i++)
        {
            var _card_idx = i - scroll_offset;
            var _target_y = _list_top + _card_idx * _card_h;
            var _y = _target_y + track_card_slide;

            var _selected = (i == selected_index);
            var _name_clean = music_names[i];
            var _is_converting = string_pos("CONVERTING", _name_clean) > 0;
            var _is_needs_conv = string_pos("NEEDS CONVERSION", _name_clean) > 0;
            var _is_needs_json = string_pos("NEEDS JSON", _name_clean) > 0;
            var _is_importable = !_is_converting && !_is_needs_conv && !_is_needs_json;

            var _card_x1 = room_width / 2 - _card_w / 2;
            var _card_x2 = room_width / 2 + _card_w / 2;
            var _card_y1 = _y - _card_h / 2 + 2;
            var _card_y2 = _y + _card_h / 2 - 2;

            if (_selected)
            {
                var _sel_pulse = 0.08 + 0.04 * sin(menu_pulse * 2);
                draw_set_alpha(_sel_pulse);
                draw_set_color(make_color_rgb(255, 180, 30));
                draw_rectangle(_card_x1 - 4, _card_y1 - 4, _card_x2 + 4, _card_y2 + 4, false);
                draw_set_alpha(1);

                draw_set_color(make_color_rgb(255, 200, 50));
                draw_set_alpha(0.12);
                draw_rectangle(_card_x1, _card_y1, _card_x2, _card_y2, false);
                draw_set_alpha(1);

                draw_set_color(make_color_rgb(255, 200, 50));
                draw_set_alpha(0.6);
                draw_rectangle(_card_x1, _card_y1, _card_x2, _card_y2, true);
                draw_set_alpha(1);
            }
            else
            {
                draw_set_color(make_color_rgb(40, 40, 60));
                draw_set_alpha(0.4);
                draw_rectangle(_card_x1, _card_y1, _card_x2, _card_y2, true);
                draw_set_alpha(1);
            }

            var _icon_x = _card_x1 + 28;
            var _icon_y = _y;

            if (_is_importable)
            {
                var _ic_col = _selected ? make_color_rgb(255, 180, 50) : make_color_rgb(80, 80, 100);
                draw_set_color(_ic_col);
                draw_set_alpha(_selected ? 0.8 : 0.4);
                draw_rectangle(_icon_x - 12, _icon_y - 12, _icon_x + 12, _icon_y + 12, false);
                draw_set_color(_selected ? c_black : make_color_rgb(50, 50, 60));
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_icon_x, _icon_y, "♪");
                draw_set_alpha(1);
            }
            else if (_is_converting)
            {
                var _spin_alpha = 0.4 + 0.4 * sin(current_time / 200);
                draw_set_color(make_color_rgb(100, 200, 255));
                draw_set_alpha(_spin_alpha);
                draw_rectangle(_icon_x - 12, _icon_y - 12, _icon_x + 12, _icon_y + 12, false);
                draw_set_color(c_black);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                var _spin_chars = ["-", "\\", "|", "/"];
                draw_text(_icon_x, _icon_y, _spin_chars[(current_time div 150) mod 4]);
                draw_set_alpha(1);
            }
            else
            {
                draw_set_color(make_color_rgb(255, 100, 50));
                draw_set_alpha(0.5);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_icon_x, _icon_y, "!");
                draw_set_alpha(1);
            }

            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);

            var _text_x = _icon_x + 24;

            if (_is_converting)
                draw_set_color(_selected ? make_color_rgb(100, 200, 255) : make_color_rgb(80, 140, 180));
            else if (_is_needs_conv)
                draw_set_color(_selected ? make_color_rgb(255, 180, 50) : make_color_rgb(150, 100, 40));
            else if (_is_needs_json)
                draw_set_color(_selected ? make_color_rgb(255, 255, 100) : make_color_rgb(150, 140, 40));
            else
                draw_set_color(_selected ? c_white : make_color_rgb(130, 130, 140));

            draw_set_alpha(track_card_alpha);
            draw_text(_text_x, _y - 8, _name_clean);

            if (_is_importable)
            {
                var _song_key = highscores_get_song_key(music_files[i]);
                var _best = highscores_get_best(_song_key);
                if (_best != -1)
                {
                    draw_set_color(make_color_rgb(255, 200, 50));
                    draw_set_alpha(0.45);
                    draw_text(_text_x, _y + 12, "BEST: " + string(_best.score) + "  RANK: " + _best.rank);
                    draw_set_alpha(1);
                }
            }

            draw_set_halign(fa_right);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(100, 100, 130));
            draw_set_alpha(0.4);

            if (_selected && _is_converting)
            {
                draw_set_color(make_color_rgb(100, 200, 255));
                draw_set_alpha(0.5 + 0.4 * sin(menu_pulse * 4));
                draw_text(_card_x2 - 15, _y, "CONVERTING...");
            }
            else if (_selected && _is_importable)
            {
                draw_set_color(make_color_rgb(255, 200, 80));
                draw_set_alpha(0.7 + 0.3 * sin(menu_pulse * 3));
                draw_text(_card_x2 - 15, _y, "▶ PLAY");
            }
            else if (_selected && !_is_importable)
            {
                draw_set_color(make_color_rgb(255, 150, 50));
                draw_set_alpha(0.7 + 0.3 * sin(menu_pulse * 3));
                draw_text(_card_x2 - 15, _y, "IMPORT");
            }
            draw_set_alpha(1);
            draw_set_halign(fa_center);
        }

        if (scroll_offset > 0)
        {
            var _arr_a = 0.4 + 0.3 * sin(current_time / 300);
            draw_set_color(make_color_rgb(180, 180, 200));
            draw_set_alpha(_arr_a);
            draw_set_halign(fa_center);
            draw_text(room_width / 2, _list_top - 20, "▲");
            draw_set_alpha(1);
        }

        var _max_scroll = max(0, array_length(music_names) - max_visible);
        if (scroll_offset < _max_scroll)
        {
            var _arr_a = 0.4 + 0.3 * sin(current_time / 300);
            draw_set_color(make_color_rgb(180, 180, 200));
            draw_set_alpha(_arr_a);
            draw_set_halign(fa_center);
            draw_text(room_width / 2, _list_top + _list_h + 20, "▼");
            draw_set_alpha(1);
        }

        var _footer_y = room_height - 55;

        draw_set_color(make_color_rgb(60, 60, 90));
        draw_line_width(room_width / 2 - 280, _footer_y - 20, room_width / 2 + 280, _footer_y - 20, 1);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(make_color_rgb(160, 160, 180));
        draw_set_alpha(0.6 + 0.2 * sin(current_time / 500));
        draw_text(room_width / 2, _footer_y + 5, "[▲▼] Select    [ENTER] Play    [T] Tutorial");
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(255, 200, 80));
        draw_set_alpha(0.45 + 0.25 * sin(current_time / 400));
        draw_text(room_width / 2, _footer_y + 30, "[I] Import WAV / MP3");
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(60, 60, 80));
        draw_set_alpha(0.25);
        draw_text(room_width / 2, _footer_y + 50, "[F1] Debug Overlay    [F11] Fullscreen");
        draw_set_alpha(1);
        break;

    case "IMPORTING":
        draw_clear(c_black);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        if (import_state == "MP3_WAITING")
        {
            draw_clear(make_color_rgb(12, 12, 20));

            var _cx = room_width / 2;
            var _cy = room_height / 2;

            var _dots = "";
            var _dot_count = (current_time div 400) mod 4;
            for (var _di = 0; _di < _dot_count; _di++)
                _dots += ".";

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            draw_set_color(make_color_rgb(255, 180, 50));
            draw_set_alpha(0.12);
            draw_text_transformed(_cx + 2, _cy - 80 + 2, "CONVERTING SONG" + _dots, 2.0, 2.0, 0);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(255, 180, 50));
            draw_text_transformed(_cx, _cy - 80, "CONVERTING SONG" + _dots, 2.0, 2.0, 0);

            var _fname = filename_name(import_path);
            draw_set_color(make_color_rgb(200, 200, 210));
            draw_set_alpha(0.7);
            draw_text(_cx, _cy - 30, _fname);
            draw_set_alpha(1);

            var _bar_w = 500;
            var _bar_h = 16;
            var _bar_x = _cx - _bar_w / 2;
            var _bar_y = _cy + 10;

            draw_set_color(make_color_rgb(30, 30, 45));
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

            var _show_progress = import_progress;
            if (_show_progress == 0)
                _show_progress = min(0.95, (import_timer / 600) * 0.95);

            draw_set_color(make_color_rgb(255, 180, 50));
            draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _show_progress), _bar_y + _bar_h, false);

            draw_set_color(make_color_rgb(60, 60, 80));
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

            draw_set_color(c_white);
            draw_set_alpha(0.8);
            draw_text(_cx, _bar_y + _bar_h + 25, "Analyzing audio data...");
            draw_set_alpha(1);

            if (import_timer > 600)
            {
                draw_set_color(make_color_rgb(120, 120, 140));
                draw_set_alpha(0.5);
                draw_text(_cx, _cy + 100, "If stuck, run start_converter.bat");
                draw_set_alpha(1);
            }

            draw_set_color(make_color_rgb(100, 100, 120));
            draw_set_alpha(0.4);
            draw_text(_cx, room_height - 40, "[ESC] Cancel");
            draw_set_alpha(1);
        }
        else
        {
            draw_set_color(make_color_rgb(255, 200, 80));
            draw_text_transformed(room_width / 2, 200, "IMPORTING SONG...", 1.5, 1.5, 0);

            if (import_state == "COPYING")
            {
                draw_set_color(make_color_rgb(200, 200, 200));
                draw_text(room_width / 2, 280, "Copying file...");
            }
            else if (import_state == "ANALYZING")
            {
                var _bar_w = 600;
                var _bar_h = 24;
                var _bar_x = (room_width - _bar_w) / 2;
                var _bar_y = 270;

                draw_set_color(make_color_rgb(40, 40, 40));
                draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

                draw_set_color(make_color_rgb(255, 200, 80));
                draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * import_progress), _bar_y + _bar_h, false);

                draw_set_color(c_white);
                draw_text(room_width / 2, _bar_y + 50, string(floor(import_progress * 100)) + "%");

                draw_set_color(make_color_rgb(150, 150, 150));
                draw_text(room_width / 2, 340, "Analyzing audio data...");
            }
        }
        break;

    case "ANALYZING":
        draw_clear(c_black);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(make_color_rgb(100, 200, 255));
        draw_text_transformed(room_width / 2, 100, "ANALYZING...", 1.5, 1.5, 0);

        if (instance_exists(obj_rhythm))
        {
            var _prog = obj_rhythm.analysis_progress;
            var _bar_w = 600;
            var _bar_h = 24;
            var _bar_x = (room_width - _bar_w) / 2;
            var _bar_y = 200;

            draw_set_color(make_color_rgb(40, 40, 40));
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

            draw_set_color(make_color_rgb(100, 255, 100));
            draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _prog), _bar_y + _bar_h, false);

            draw_set_color(make_color_rgb(255, 255, 255));
            draw_set_alpha(0.7);
            draw_text(room_width / 2, _bar_y + 50, string(floor(_prog * 100)) + "%");
            draw_set_alpha(1);

            if (array_length(obj_rhythm.analysis_profile) > 0)
            {
                var _profile = obj_rhythm.analysis_profile;
                var _wave_x = 100;
                var _wave_w = room_width - 200;
                var _wave_h = 180;
                var _wave_y = 320;

                draw_set_alpha(0.2);
                draw_set_color(make_color_rgb(100, 200, 255));
                draw_rectangle(_wave_x, _wave_y, _wave_x + _wave_w, _wave_y + _wave_h, true);
                draw_set_alpha(1);

                var _drawn = min(array_length(_profile), floor(_prog * array_length(_profile)));
                for (var i = 0; i < _drawn; i++)
                {
                    var _px = _wave_x + (i / array_length(_profile)) * _wave_w;
                    var _ph = _profile[i] * _wave_h;
                    draw_set_color(make_color_rgb(100, 200, 255));
                    draw_line_width(_px, _wave_y + _wave_h, _px, _wave_y + _wave_h - _ph, 2);
                }
            }
        }
        break;

    case "RESULTS":
        draw_clear(c_black);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(make_color_rgb(255, 200, 50));
        draw_text_transformed(room_width / 2, 50, "ANALYSIS COMPLETE", 1.5, 1.5, 0);

        if (global.level_data != -1)
        {
            var _ly = 120;
            var _sp = 36;

            draw_set_color(make_color_rgb(100, 200, 255));
            draw_text(room_width / 2, _ly, "BPM: " + string(global.bpm));
            _ly += _sp;

            draw_set_color(c_white);
            draw_text(room_width / 2, _ly, "DURATION: " + string(floor(global.level_data.song_duration)) + "s");
            _ly += _sp;

            draw_text(room_width / 2, _ly, "WAVES: " + string(global.level_data.total_waves));
            _ly += _sp;

            if (global.level_data.boss_wave > 0)
            {
                draw_set_color(make_color_rgb(255, 50, 50));
                draw_text(room_width / 2, _ly, "BOSS: WAVE " + string(global.level_data.boss_wave));
            }
            _ly += _sp + 10;

            draw_set_color(make_color_rgb(100, 100, 100));
            draw_text(room_width / 2, _ly, "--- STRUCTURE ---");
            _ly += 20;

            for (var i = 0; i < array_length(global.level_data.waves) && i < 10; i++)
            {
                var _w = global.level_data.waves[i];
                var _col = c_white;
                if (_w.is_boss) _col = make_color_rgb(255, 50, 50);
                else if (_w.section_type == "DROP") _col = make_color_rgb(255, 200, 50);
                else if (_w.section_type == "BUILDUP") _col = make_color_rgb(100, 200, 255);
                else if (_w.section_type == "INTRO") _col = make_color_rgb(150, 150, 150);
                else if (_w.section_type == "BREAK") _col = make_color_rgb(200, 100, 255);

                draw_set_color(_col);
                var _label = "W" + string(_w.number) + " " + _w.section_type;
                if (_w.is_boss) _label += " [BOSS]";
                draw_text(room_width / 2, _ly, _label);
                _ly += 26;
            }

            _ly += 20;
            draw_set_color(make_color_rgb(100, 255, 100));
            draw_set_alpha(0.4 + sin(current_time / 300) * 0.4);
            draw_text(room_width / 2, _ly, "PRESS ENTER TO START");
            draw_set_alpha(1);
        }
        break;

    case "PLAYING":
        var _energy = 0;
        if (instance_exists(obj_rhythm) && obj_rhythm.music_started)
            _energy = global.music_energy;

        var _t = current_time * 0.001;
        var _bpm_t = _t * (global.bpm / 60);
        var _beat01 = global.beat_flash;

        var _bass = global.energy_bass;
        var _mids = global.energy_mids;
        var _highs = global.energy_highs;
        var _onset = global.onset_intensity;
        var _centroid = global.spectral_centroid;
        var _flatness = global.spectral_flatness;
        var _peak_d = global.peak_density;
        var _chroma_r = global.chroma_r;
        var _chroma_g = global.chroma_g;
        var _chroma_b = global.chroma_b;

        var _sec = "MAIN";
        if (instance_exists(obj_rhythm))
            _sec = obj_rhythm.current_section;

        var _bg_col = get_section_bg_color(_sec);

        var _pal_r, _pal_g, _pal_b;
        switch (_sec)
        {
            case "INTRO":   _pal_r = 60;  _pal_g = 80;  _pal_b = 180; break;
            case "BUILDUP": _pal_r = 120; _pal_g = 40;  _pal_b = 200; break;
            case "MAIN":    _pal_r = 40;  _pal_g = 120; _pal_b = 220; break;
            case "DROP":    _pal_r = 220; _pal_g = 40;  _pal_b = 80;  break;
            case "BREAK":   _pal_r = 80;  _pal_g = 40;  _pal_b = 160; break;
            case "OUTRO":   _pal_r = 40;  _pal_g = 80;  _pal_b = 120; break;
            default:        _pal_r = 40;  _pal_g = 80;  _pal_b = 160; break;
        }

        _pal_r = lerp(_pal_r, _chroma_r * 255, _bass * 0.4);
        _pal_g = lerp(_pal_g, _chroma_g * 255, _mids * 0.3);
        _pal_b = lerp(_pal_b, _chroma_b * 255, _highs * 0.3);

        draw_set_alpha(_energy * 0.08 + _bass * 0.06);
        draw_set_color(make_color_rgb(_pal_r, _pal_g, _pal_b));
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        var _bass_bar_h = _bass * 120;
        draw_set_alpha(_bass * 0.2);
        draw_set_color(make_color_rgb(220, 40, 40));
        draw_rectangle(0, room_height - _bass_bar_h, 30, room_height, false);
        draw_rectangle(room_width - 30, room_height - _bass_bar_h, room_width, room_height, false);
        draw_set_alpha(1);

        var _mids_bar_h = _mids * 80;
        draw_set_alpha(_mids * 0.15);
        draw_set_color(make_color_rgb(40, 220, 120));
        draw_rectangle(34, room_height - _mids_bar_h, 58, room_height, false);
        draw_rectangle(room_width - 58, room_height - _mids_bar_h, room_width - 34, room_height, false);
        draw_set_alpha(1);

        var _highs_bar_h = _highs * 60;
        draw_set_alpha(_highs * 0.15);
        draw_set_color(make_color_rgb(80, 120, 255));
        draw_rectangle(62, room_height - _highs_bar_h, 82, room_height, false);
        draw_rectangle(room_width - 82, room_height - _highs_bar_h, room_width - 62, room_height, false);
        draw_set_alpha(1);

        for (var _i = 0; _i < 16; _i++)
        {
            var _wh = _energy * 60 * (0.5 + sin(_bpm_t * 0.8 + _i * 0.4) * 0.5);
            var _a = 0.08 + _energy * 0.06;
            draw_set_alpha(_a);
            var _cr = clamp(_pal_r + _i * 10, 0, 255);
            var _cg = clamp(_pal_g + sin(_bpm_t + _i) * 30, 0, 255);
            var _cb = clamp(_pal_b + _i * 5, 0, 255);
            draw_set_color(make_color_rgb(_cr, _cg, _cb));

            var _lx = _i * (room_width / 16);
            draw_rectangle(_lx, 0, _lx + (room_width / 16) - 2, _wh, false);
            draw_rectangle(_lx, room_height, _lx + (room_width / 16) - 2, room_height - _wh, false);
        }
        draw_set_alpha(1);

        if (instance_exists(obj_rhythm))
        {
            var _ring_speed = 4 + _energy * 6 + _bass * 4;
            obj_rhythm.pulse_ring += _ring_speed;
            if (obj_rhythm.pulse_ring > room_width)
                obj_rhythm.pulse_ring = 0;

            var _ring_r = obj_rhythm.pulse_ring;
            var _ring_a = max(0, 1 - (_ring_r / room_width)) * 0.12 * (0.5 + _energy);
            draw_set_alpha(_ring_a);
            draw_set_color(make_color_rgb(_pal_r, _pal_g, _pal_b));
            draw_circle(room_width / 2, room_height / 2, _ring_r, true);
            draw_circle(room_width / 2, room_height / 2, _ring_r * 0.7, true);
            draw_set_alpha(1);
        }

        if (_onset > 0.3)
        {
            draw_set_alpha(_onset * 0.15);
            draw_set_color(make_color_rgb(255, 255, 255));
            var _os_r = _onset * 200;
            draw_circle(room_width / 2, room_height / 2, _os_r, true);
            draw_circle(room_width / 2, room_height / 2, _os_r * 0.6, true);
            draw_set_alpha(1);
        }

        if (instance_exists(obj_rhythm))
        {
            for (var _i = 0; _i < array_length(obj_rhythm.particles); _i++)
            {
                var _p = obj_rhythm.particles[_i];
                _p.x += _p.vx + sin(_bpm_t + _i) * 0.3;
                _p.y += _p.vy - _energy * 0.5;

                if (_p.y < -10) { _p.y = room_height + 10; _p.x = irandom(room_width); }
                if (_p.x < -10) _p.x = room_width + 10;
                if (_p.x > room_width + 10) _p.x = -10;

                var _pa = _p.alpha * (0.3 + _energy * 0.7);
                draw_set_alpha(_pa);

                var _pc_r = lerp(_pal_r, 255, _bass * 0.5);
                var _pc_g = lerp(_pal_g, 100, _mids * 0.5);
                var _pc_b = lerp(_pal_b, 255, _highs * 0.5);
                draw_set_color(make_color_rgb(_pc_r + 60, _pc_g + 60, _pc_b + 60));
                draw_circle(_p.x, _p.y, _p.size * (1 + _energy * 0.5 + _onset * 0.5), false);
            }
            draw_set_alpha(1);
        }

        for (var _i = 0; _i < 4; _i++)
        {
            var _ea = _energy * 0.25;
            draw_set_alpha(_ea);
            draw_set_color(make_color_rgb(_pal_r, _pal_g, _pal_b));
            switch (_i)
            {
                case 0: draw_rectangle(0, 0, room_width, 2 + _energy * 4 + _bass * 6, false); break;
                case 1: draw_rectangle(0, room_height - 2 - _energy * 4 - _bass * 6, room_width, room_height, false); break;
                case 2: draw_rectangle(0, 0, 2 + _energy * 4 + _highs * 6, room_height, false); break;
                case 3: draw_rectangle(room_width - 2 - _energy * 4 - _highs * 6, 0, room_width, room_height, false); break;
            }
        }
        draw_set_alpha(1);

        var _vig_a = 0.15 + _energy * 0.1;
        draw_set_alpha(_vig_a);
        draw_set_color(c_black);
        for (var _v = 0; _v < 6; _v++)
        {
            var _vw = 80 - _v * 12;
            draw_rectangle(0, 0, _vw, room_height, false);
            draw_rectangle(room_width - _vw, 0, room_width, room_height, false);
        }
        draw_set_alpha(1);

        if (_beat01 > 0.3)
        {
            var _bf = _beat01;
            var _beat_hue = (_centroid * 200) mod 255;
            draw_set_alpha((_bf - 0.3) * 0.25);
            draw_set_color(make_color_hsv(_beat_hue, 100 + _flatness * 155, 255));
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);

            var _beat_border = 4 + _bass * 8;
            draw_set_alpha((_bf - 0.3) * 0.4);
            draw_set_color(make_color_rgb(_pal_r, _pal_g, _pal_b));
            draw_rectangle(0, 0, room_width, _beat_border, false);
            draw_rectangle(0, room_height - _beat_border, room_width, room_height, false);
            draw_rectangle(0, 0, _beat_border, room_height, false);
            draw_rectangle(room_width - _beat_border, 0, room_width, room_height, false);
            draw_set_alpha(1);
        }

        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        var _dot_r = 5 + _beat01 * 12;
        draw_set_alpha(0.2 + _beat01 * 0.8);
        draw_set_color(make_color_rgb(255, 200, 50));
        draw_circle(room_width / 2, room_height - 14, _dot_r, false);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        var _margin = 16;

        scr_draw_panel(_margin - 6, _margin - 4, _margin + 160, _margin + 100, 0.55);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        scr_draw_text_outlined(_margin, _margin, "SCORE", make_color_rgb(255, 200, 50), c_black, 1, 1, 1);
        scr_draw_text_outlined(_margin, _margin + 18, string(floor(global.score_display)), c_white, c_black, 1, 1, 1);

        if (instance_exists(obj_player) && !obj_player.dead)
        {
            var _bar_x = _margin;
            var _bar_y = _margin + 40;
            var _bar_w = 120;
            var _bar_h = 14;
            var _hp_pct = (obj_player.hp / obj_player.max_hp) * 100;

            scr_draw_text_outlined(_bar_x, _bar_y - 14, "HP", make_color_rgb(180, 180, 180), c_black, 0.7, 1, 1);

            draw_set_alpha(0.4);
            draw_set_color(c_dkgray);
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
            draw_set_alpha(1);

            var _hp_color = (_hp_pct > 60) ? c_lime : ((_hp_pct > 30) ? c_yellow : c_red);
            draw_set_alpha(0.9);
            draw_set_color(_hp_color);
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * (_hp_pct / 100), _bar_y + _bar_h, false);
            draw_set_alpha(1);

            draw_set_alpha(0.3);
            draw_set_color(c_white);
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * (_hp_pct / 100), _bar_y + 2, false);
            draw_set_alpha(1);

            var _wl_eff = weapon_get_effective_level();
            var _wl_col = weapon_get_level_color(_wl_eff);
            var _wl_name = weapon_get_level_name(_wl_eff);
            var _wl_label = "WPN LV." + string(_wl_eff);
            if (global.weapon_temp >= 0) _wl_label += " [TEMP]";
            scr_draw_text_outlined(_bar_x, _bar_y + 22, _wl_label, _wl_col, c_black, 0.8, 1, 1);
            draw_set_alpha(0.6);
            draw_set_color(_wl_col);
            draw_text(_bar_x + 80, _bar_y + 22, _wl_name);
            draw_set_alpha(1);

            var _band_y = _bar_y + 38;
            var _band_w = 80;
            var _band_h = 5;

            draw_set_alpha(0.5);
            draw_set_color(make_color_rgb(220, 40, 40));
            draw_rectangle(_bar_x, _band_y, _bar_x + _band_w * _bass, _band_y + _band_h, false);
            draw_set_color(c_dkgray);
            draw_rectangle(_bar_x + _band_w * _bass, _band_y, _bar_x + _band_w, _band_y + _band_h, false);

            draw_set_color(make_color_rgb(40, 220, 120));
            draw_rectangle(_bar_x, _band_y + 8, _bar_x + _band_w * _mids, _band_y + 8 + _band_h, false);
            draw_set_color(c_dkgray);
            draw_rectangle(_bar_x + _band_w * _mids, _band_y + 8, _bar_x + _band_w, _band_y + 8 + _band_h, false);

            draw_set_color(make_color_rgb(80, 120, 255));
            draw_rectangle(_bar_x, _band_y + 16, _bar_x + _band_w * _highs, _band_y + 16 + _band_h, false);
            draw_set_color(c_dkgray);
            draw_rectangle(_bar_x + _band_w * _highs, _band_y + 16, _bar_x + _band_w, _band_y + 16 + _band_h, false);

            draw_set_alpha(0.5);
            draw_set_color(c_white);
            draw_text(_bar_x + _band_w + 8, _band_y - 1, "B");
            draw_text(_bar_x + _band_w + 8, _band_y + 7, "M");
            draw_text(_bar_x + _band_w + 8, _band_y + 15, "H");
            draw_set_alpha(1);
        }

        if (instance_exists(obj_player) && obj_player.is_grabbed)
        {
            var _gi = clamp((global.energy_bass - 0.65) / 0.35, 0, 1);
            var _threshold = 12 + floor(_gi * 13);
            var _progress = clamp(obj_player.grab_shake_input / _threshold, 0, 1);

            var _gb_w = 260;
            var _gb_h = 28;
            var _gb_x = (room_width - _gb_w) / 2;
            var _gb_y = room_height - 60;

            draw_set_alpha(0.7);
            draw_set_color(c_dkgray);
            draw_rectangle(_gb_x - 2, _gb_y - 2, _gb_x + _gb_w + 2, _gb_y + _gb_h + 2, false);

            draw_set_alpha(0.85);
            var _gb_col = _progress < 0.5
                ? make_color_rgb(255, 80, 50)
                : (_progress < 0.8 ? make_color_rgb(255, 180, 50) : make_color_rgb(80, 255, 120));
            draw_set_color(_gb_col);
            draw_rectangle(_gb_x, _gb_y, _gb_x + _gb_w * _progress, _gb_y + _gb_h, false);

            draw_set_alpha(0.5);
            draw_set_color(c_black);
            draw_rectangle(_gb_x + _gb_w * _progress, _gb_y, _gb_x + _gb_w, _gb_y + _gb_h, false);

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_alpha(0.9);
            draw_set_color(c_white);
            draw_text(_gb_x + _gb_w / 2, _gb_y + _gb_h / 2, "SHAKE TO ESCAPE  A D A D A D");
            draw_set_alpha(1);

            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        if (global.weapon_choosing)
        {
            draw_set_alpha(0.6);
            draw_set_color(c_black);
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);

            var _cx = room_width / 2;
            var _cy = room_height / 2;

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            draw_set_alpha(0.9);
            draw_set_color(c_white);
            draw_text(_cx, _cy - 60, "CHOOSE YOUR PATH");
            draw_set_alpha(0.5);
            draw_text(_cx, _cy - 40, "Weapon Level 2 reached!");

            draw_set_alpha(0.9);
            draw_set_color(make_color_rgb(180, 80, 255));
            draw_rectangle(_cx - 200, _cy - 10, _cx - 30, _cy + 40, false);
            draw_set_color(c_white);
            draw_text(_cx - 115, _cy + 15, "[A] OFFENSIVE");
            draw_set_alpha(0.6);
            draw_text(_cx - 115, _cy + 30, "SPREAD > SHOTGUN");

            draw_set_alpha(0.9);
            draw_set_color(make_color_rgb(0, 200, 200));
            draw_rectangle(_cx + 30, _cy - 10, _cx + 200, _cy + 40, false);
            draw_set_color(c_white);
            draw_text(_cx + 115, _cy + 15, "[D] CONTROL");
            draw_set_alpha(0.6);
            draw_text(_cx + 115, _cy + 30, "HOMING > CHAIN");

            draw_set_alpha(0.4 + sin(current_time * 0.005) * 0.3);
            draw_set_color(c_yellow);
            draw_text(_cx, _cy + 70, "Press A or D to choose");

            draw_set_alpha(1);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        draw_set_halign(fa_right);
        draw_set_valign(fa_top);

        var _rx = room_width - _margin;

        scr_draw_panel(_rx - 136, _margin - 4, _rx + 6, _margin + 76, 0.55);

        scr_draw_text_outlined(_rx, _margin, "WAVE", make_color_rgb(100, 200, 255), c_black, 1, 1, 1);
        scr_draw_text_outlined(_rx, _margin + 16, string(global.wave), c_white, c_black, 1, 1, 1);

        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        draw_set_alpha(0.8);
        draw_set_color(make_color_rgb(_pal_r + 80, _pal_g + 80, _pal_b + 80));
        draw_text(_rx, _margin + 34, _sec);
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(200, 100, 255));
        draw_set_alpha(0.6);
        draw_text(_rx, _margin + 52, string(global.bpm) + " BPM");
        draw_set_alpha(1);

        if (global.combo_alpha > 0 && global.combo_display > 1)
        {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            var _combo_x = room_width / 2;
            var _combo_y = 60;
            var _combo_scale = 1.3 + (global.combo_display * 0.1);

            draw_set_alpha(global.combo_alpha * 0.4);
            draw_set_color(make_color_rgb(255, 200, 0));
            draw_rectangle(_combo_x - 70, _combo_y - 16, _combo_x + 70, _combo_y + 16, false);

            draw_set_alpha(global.combo_alpha);
            draw_set_color(c_white);
            draw_text_transformed(_combo_x, _combo_y, "x" + string(global.combo_display), _combo_scale, _combo_scale, 0);
            draw_set_alpha(1);
        }

        if (global.wave_announce_timer > 0)
        {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            var _announce_alpha = 1;
            if (global.wave_announce_timer > 100)
                _announce_alpha = (120 - global.wave_announce_timer) / 20;
            else if (global.wave_announce_timer < 20)
                _announce_alpha = global.wave_announce_timer / 20;

            draw_set_alpha(_announce_alpha * 0.6);
            draw_set_color(c_black);
            draw_rectangle(0, room_height / 2 - 50, room_width, room_height / 2 + 50, false);

            draw_set_alpha(_announce_alpha * 0.3);
            draw_set_color(make_color_rgb(_pal_r, _pal_g, _pal_b));
            draw_rectangle(0, room_height / 2 - 50, room_width, room_height / 2 + 50, false);

            draw_set_alpha(_announce_alpha);
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_text_transformed(room_width / 2, room_height / 2 - 5, "WAVE " + string(global.wave_announce), 2.0, 2.0, 0);

            if (instance_exists(obj_rhythm) && global.level_data != -1)
            {
                var _widx = global.current_wave_index;
                if (_widx < array_length(global.level_data.waves) && global.level_data.waves[_widx].is_boss)
                {
                    draw_set_color(make_color_rgb(255, 50, 50));
                    draw_text_transformed(room_width / 2, room_height / 2 + 30, "!! BOSS !!", 1.5, 1.5, 0);
                }
            }
            draw_set_alpha(1);
        }

        if (instance_exists(obj_player) && !obj_player.dead)
        {
            var _pu_x = 16;
            var _pu_y = room_height - 50;
            var _pu_i = 0;
            var _pu_row2_y = room_height - 26;
            var _pu_i2 = 0;

            var _wl_eff2 = weapon_get_effective_level();
            var _wl_col = weapon_get_level_color(_wl_eff2);
            var _wl_name = weapon_get_level_name(_wl_eff2);
            var _wl_badge = "LV" + string(_wl_eff2);
            if (global.weapon_temp >= 0) _wl_badge += " T";
            scr_draw_powerup_badge(_pu_x, _pu_y, _wl_badge, _wl_col, c_white, _wl_name, 1);
            _pu_i++;

            if (obj_player.powerup_shield)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "SHI", make_color_rgb(0, 150, 255), c_white, string(ceil(obj_player.powerup_shield_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_speed)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "SPD", make_color_rgb(0, 200, 100), c_white, string(ceil(obj_player.powerup_speed_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_rapid)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "RAP", make_color_rgb(255, 50, 255), c_white, string(ceil(obj_player.powerup_rapid_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_mini)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "MIN", make_color_rgb(255, 140, 190), c_black, string(ceil(obj_player.powerup_mini_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_ghost)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "GOS", make_color_rgb(160, 160, 200), c_black, string(ceil(obj_player.powerup_ghost_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_magnet)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "MAG", make_color_rgb(255, 200, 0), c_black, string(ceil(obj_player.powerup_magnet_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_score_x2)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "x2", make_color_rgb(255, 200, 0), c_black, string(ceil(obj_player.powerup_score_x2_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_score_x3)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "x3", make_color_rgb(255, 160, 0), c_black, string(ceil(obj_player.powerup_score_x3_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_time_slow)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "SLO", make_color_rgb(50, 80, 255), c_white, string(ceil(obj_player.powerup_time_slow_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_rage)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "RGE", make_color_rgb(200, 30, 30), c_white, string(ceil(obj_player.powerup_rage_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_regen)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "REG", make_color_rgb(80, 220, 80), c_black, string(ceil(obj_player.powerup_regen_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_trippy)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "TRP", make_color_rgb(200, 0, 200), c_white, string(ceil(obj_player.powerup_trippy_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_disco)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                scr_draw_powerup_badge(_tx, _ty, "DSB", make_color_rgb(255, 180, 0), c_black, string(ceil(obj_player.powerup_disco_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
            if (obj_player.powerup_rainbow)
            {
                var _tx = (_pu_i < 20) ? _pu_x + (_pu_i * 52) : _pu_x + (_pu_i2 * 52);
                var _ty = (_pu_i < 20) ? _pu_y : _pu_row2_y;
                var _rb_hue = (current_time * 0.2) mod 255;
                scr_draw_powerup_badge(_tx, _ty, "RNB", make_color_hsv(_rb_hue, 200, 255), c_white, string(ceil(obj_player.powerup_rainbow_timer / 60)), 1);
                if (_pu_i < 20) _pu_i++; else _pu_i2++;
            }
        }

        if (global.nuke_flash > 0.01)
        {
            draw_set_alpha(global.nuke_flash * 0.6);
            draw_set_color(c_white);
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);

            gpu_set_blendmode(bm_add);
            draw_set_alpha(global.nuke_flash * 0.3);
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_rectangle(0, 0, room_width, room_height, false);
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);

            global.nuke_flash *= 0.9;
        }

        if (global.time_slow)
        {
            draw_set_alpha(0.08);
            draw_set_color(make_color_rgb(80, 120, 255));
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);

            draw_set_alpha(0.04);
            draw_set_color(make_color_rgb(150, 200, 255));
            for (var _sl = 0; _sl < room_height; _sl += 4)
            {
                draw_rectangle(0, _sl, room_width, _sl + 1, false);
            }
            draw_set_alpha(1);
        }

        if (global.trippy_mode)
        {
            var _trippy_t = current_time * 0.002;
            gpu_set_blendmode(bm_add);
            for (var _ti = 0; _ti < 6; _ti++)
            {
                var _ta = 0.06 + sin(_trippy_t + _ti * 1.2) * 0.04;
                draw_set_alpha(_ta);
                var _tc = make_color_hsv((_trippy_t * 30 + _ti * 40) mod 255, 200, 255);
                draw_set_color(_tc);
                var _tx = room_width / 2 + cos(_trippy_t + _ti * 0.8) * 200;
                var _ty = room_height / 2 + sin(_trippy_t * 0.7 + _ti) * 150;
                draw_circle(_tx, _ty, 80 + sin(_trippy_t + _ti) * 40, false);
            }
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);

            draw_set_alpha(0.08);
            draw_set_color(make_color_hsv((_trippy_t * 50) mod 255, 255, 255));
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);
        }

        if (global.disco_mode)
        {
            var _disco_t = current_time * 0.003;
            var _beat_sync = global.on_beat ? 1.0 : 0.5;

            gpu_set_blendmode(bm_add);
            for (var _di = 0; _di < 12; _di++)
            {
                var _da = (0.08 + _energy * 0.12) * _beat_sync;
                draw_set_alpha(_da);
                var _dc = make_color_hsv((_disco_t * 40 + _di * 30) mod 255, 255, 255);
                draw_set_color(_dc);
                var _dang = _disco_t * 2 + _di * 30;
                var _len = room_width * (0.8 + _beat_sync * 0.2);
                draw_line_width(room_width / 2, room_height / 2,
                    room_width / 2 + lengthdir_x(_len, _dang),
                    room_height / 2 + lengthdir_y(_len, _dang),
                    2 + _energy * 5 + _beat_sync * 3);
            }
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);

            for (var _dj = 0; _dj < 6; _dj++)
            {
                var _dang2 = _disco_t * 1.5 + _dj * 60;
                var _rad = 150 + sin(_disco_t * 2 + _dj) * 50;
                var _djx = room_width / 2 + lengthdir_x(_rad, _dang2);
                var _djy = room_height / 2 + lengthdir_y(_rad, _dang2);
                var _dja = 0.12 + _energy * 0.08;
                draw_set_alpha(_dja);
                draw_set_color(make_color_hsv((_disco_t * 60 + _dj * 42) mod 255, 255, 255));
                draw_circle(_djx, _djy, 20 + _energy * 15 + _beat_sync * 10, false);
            }
            draw_set_alpha(1);

            if (global.on_beat && global.beat_strength > 0.8)
            {
                draw_set_alpha(0.1);
                draw_set_color(make_color_hsv((_disco_t * 100) mod 255, 200, 255));
                draw_rectangle(0, 0, room_width, room_height, false);
                draw_set_alpha(1);
            }
        }

        if (global.rainbow_mode && global.rainbow_intensity > 0.01)
        {
            var _rb_t = current_time * 0.005;
            var _rb_sync = global.on_beat ? 1.0 : 0.3;
            var _rb_int = global.rainbow_intensity;

            gpu_set_blendmode(bm_add);
            draw_set_alpha(0.12 * _rb_int * _rb_sync);
            draw_rectangle_color(0, 0, room_width, room_height,
                make_color_hsv((_rb_t * 80) mod 255, 255, 255),
                make_color_hsv((_rb_t * 80 + 85) mod 255, 255, 255),
                make_color_hsv((_rb_t * 80 + 170) mod 255, 255, 255),
                make_color_hsv((_rb_t * 80 + 42) mod 255, 255, 255),
                false);

            for (var _ri = 0; _ri < 16; _ri++)
            {
                var _ra = (0.06 + _energy * 0.15) * _rb_int;
                draw_set_alpha(_ra);
                draw_set_color(make_color_hsv((_rb_t * 50 + _ri * 22) mod 255, 255, 255));
                var _rang = _rb_t * 3 + _ri * 22.5;
                var _rlen = room_width * (0.9 + _rb_sync * 0.1);
                draw_line_width(room_width / 2, room_height / 2,
                    room_width / 2 + lengthdir_x(_rlen, _rang),
                    room_height / 2 + lengthdir_y(_rlen, _rang),
                    1 + _energy * 4);
            }

            for (var _si = 0; _si < 24; _si++)
            {
                var _sang = _rb_t * 2 + _si * 15;
                var _srad = 50 + _si * 8 + sin(_rb_t + _si * 0.5) * 20;
                var _sx = room_width / 2 + lengthdir_x(_srad, _sang);
                var _sy = room_height / 2 + lengthdir_y(_srad, _sang);
                draw_set_alpha(0.2 * _rb_int);
                draw_set_color(make_color_hsv((_rb_t * 100 + _si * 15) mod 255, 255, 255));
                draw_circle(_sx, _sy, 3 + _energy * 4, false);
            }

            if (global.on_beat && global.beat_strength > 0.6)
            {
                var _ca_off = 4 * _rb_int;
                draw_set_alpha(0.08 * _rb_int);
                draw_set_color(c_red);
                draw_rectangle(-_ca_off, 0, room_width - _ca_off, room_height, false);
                draw_set_color(c_green);
                draw_rectangle(0, 0, room_width, room_height, false);
                draw_set_color(c_blue);
                draw_rectangle(_ca_off, 0, room_width + _ca_off, room_height, false);
            }

            if (global.on_beat && global.beat_strength > 0.85)
            {
                draw_set_alpha(0.15 * _rb_int);
                draw_set_color(make_color_hsv((_rb_t * 200) mod 255, 150, 255));
                draw_rectangle(0, 0, room_width, room_height, false);
            }

            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);
        }

        if (global.section_flash > 0.01)
        {
            draw_set_alpha(global.section_flash * 0.35);
            draw_set_color(make_color_rgb(global.section_flash_r, global.section_flash_g, global.section_flash_b));
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);
        }

        if (_sec != "SELECT_MUSIC")
        {
            var _vig_col = get_section_glow_color(_sec);
            var _vig_a = 0.2 + _energy * 0.1;
            draw_set_alpha(_vig_a);
            draw_set_color(_vig_col);
            draw_rectangle(0, 0, 40, room_height, false);
            draw_rectangle(room_width - 40, 0, room_width, room_height, false);
            draw_rectangle(0, 0, room_width, 25, false);
            draw_rectangle(0, room_height - 25, room_width, room_height, false);
            draw_set_alpha(1);
        }

        if (global.combo_border_alpha > 0.01)
        {
            var _cba = global.combo_border_alpha;
            var _cbw = 3 + _cba * 10;
            draw_set_alpha(_cba);
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_rectangle(0, 0, room_width, _cbw, false);
            draw_rectangle(0, room_height - _cbw, room_width, room_height, false);
            draw_rectangle(0, 0, _cbw, room_height, false);
            draw_rectangle(room_width - _cbw, 0, room_width, room_height, false);
            draw_set_alpha(1);
        }

        if (global.tutorial_mode && global.tutorial_text != "" && global.tutorial_text_timer > 0)
        {
            var _ta = min(1, global.tutorial_text_timer / 30);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            draw_set_alpha(_ta * 0.6);
            draw_set_color(c_black);
            draw_rectangle(room_width / 2 - 200, room_height * 0.28 - 20, room_width / 2 + 200, room_height * 0.28 + 20, false);

            draw_set_alpha(_ta);
            draw_set_color(make_color_rgb(255, 220, 80));
            draw_text_transformed(room_width / 2, room_height * 0.28, global.tutorial_text, 1.5, 1.5, 0);
            draw_set_alpha(1);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        if (countdown_active)
        {
            draw_set_alpha(0.4);
            draw_set_color(c_black);
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_alpha(1);

            for (var _ci = 0; _ci < array_length(countdown_particles); _ci++)
            {
                var _cp = countdown_particles[_ci];
                var _pa = _cp.life / _cp.max_life;
                draw_set_alpha(_pa * 0.8);
                draw_set_color(_cp.color);
                draw_circle(_cp.x, _cp.y, _cp.size * _pa, false);
            }
            draw_set_alpha(1);

            if (countdown_flash > 0)
            {
                draw_set_alpha(countdown_flash * 0.3);
                draw_set_color(c_white);
                draw_rectangle(0, 0, room_width, room_height, false);
                draw_set_alpha(1);
            }

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            if (countdown_frame < 180)
            {
                var _t_in_number = (countdown_frame mod 60) / 60;
                var _num_scale = lerp(3, 1, min(1, _t_in_number * 3));
                var _num_alpha = 1;

                var _num_col = c_white;
                if (countdown_number == 2) _num_col = make_color_rgb(255, 160, 0);
                else if (countdown_number == 1) _num_col = c_yellow;
                else if (countdown_number == 0) _num_col = c_lime;

                draw_set_alpha(_num_alpha);
                scr_draw_text_outlined(room_width / 2, room_height / 2, string(countdown_number), _num_col, c_black, _num_alpha, _num_scale, _num_scale);
            }
            else
            {
                var _go_t = (countdown_frame - 180) / 30;
                var _go_scale = lerp(2, 1, min(1, _go_t * 2));
                var _go_alpha = min(1, _go_t * 3);
                scr_draw_text_outlined(room_width / 2, room_height / 2, "GO!", c_lime, c_black, _go_alpha, _go_scale, _go_scale);
            }

            draw_set_alpha(1);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;

    case "PAUSE":
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        scr_draw_panel(room_width / 2 - 200, room_height / 2 - 160, room_width / 2 + 200, room_height / 2 + 160, 0.85);

        draw_set_color(make_color_rgb(255, 200, 50));
        draw_text_transformed(room_width / 2, room_height / 2 - 130, "PAUSED", 2.0, 2.0, 0);

        var _py = room_height / 2 - 60;
        draw_set_color(make_color_rgb(200, 200, 200));
        draw_text(room_width / 2, _py, "Score: " + string(floor(global.score_display)));
        _py += 30;
        draw_text(room_width / 2, _py, "Wave: " + string(global.wave));
        _py += 30;
        draw_text(room_width / 2, _py, "Combo: x" + string(global.max_combo));
        _py += 50;

        var _pulse_a = 0.5 + sin(current_time / 300) * 0.3;

        draw_set_color(make_color_rgb(100, 255, 100));
        draw_set_alpha(_pulse_a);
        draw_text(room_width / 2, _py, "[ESC] Resume");
        _py += 30;

        draw_set_color(make_color_rgb(255, 200, 80));
        draw_text(room_width / 2, _py, "[R] Restart");
        _py += 30;

        draw_set_color(make_color_rgb(255, 100, 100));
        draw_text(room_width / 2, _py, "[Q] Quit to Menu");
        draw_set_alpha(1);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        break;

    case "GAME_OVER":
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        scr_draw_panel(room_width / 2 - 220, room_height / 2 - 200, room_width / 2 + 220, room_height / 2 + 200, 0.85);

        draw_set_color(make_color_rgb(255, 50, 50));
        draw_text_transformed(room_width / 2, room_height / 2 - 170, "GAME OVER", 2.2, 2.2, 0);

        var _gy = room_height / 2 - 100;
        var _gl = 30;

        draw_set_color(make_color_rgb(255, 200, 50));
        draw_text(room_width / 2, _gy, "Score: " + string(floor(global.score)));
        _gy += _gl;

        draw_set_color(make_color_rgb(255, 150, 255));
        draw_text(room_width / 2, _gy, "Max Combo: x" + string(global.max_combo));
        _gy += _gl;

        draw_set_color(make_color_rgb(255, 100, 100));
        draw_text(room_width / 2, _gy, "Enemies: " + string(global.enemies_killed));
        _gy += _gl;

        draw_set_color(make_color_rgb(100, 255, 200));
        draw_text(room_width / 2, _gy, "Power-ups: " + string(global.powerups_collected));
        _gy += _gl;

        var _wl_eff_go = weapon_get_effective_level();
        var _wl_col_go = weapon_get_level_color(_wl_eff_go);
        draw_set_color(_wl_col_go);
        draw_text(room_width / 2, _gy, "Weapon: LV." + string(_wl_eff_go) + " " + weapon_get_level_name(_wl_eff_go));
        _gy += _gl;

        draw_set_color(make_color_rgb(200, 200, 200));
        draw_text(room_width / 2, _gy, "Time: " + highscores_format_time(global.game_time));
        _gy += _gl;

        draw_text(room_width / 2, _gy, "Wave: " + string(global.wave));
        _gy += _gl + 10;

        var _song_key = highscores_get_song_key(global.selected_music);
        var _best = highscores_get_best(_song_key);
        if (_best != -1)
        {
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_set_alpha(0.7);
            draw_text(room_width / 2, _gy, "BEST: " + string(_best.score) + "  RANK: " + _best.rank);
            draw_set_alpha(1);
        }
        _gy += 30;

        achievements_check(false);
        if (array_length(global.achievements_this_run) > 0)
        {
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_set_alpha(0.8);
            draw_text(room_width / 2, _gy, "NEW BADGES!");
            _gy += 20;
            for (var _abi = 0; _abi < min(array_length(global.achievements_this_run), 3); _abi++)
            {
                for (var _abj = 0; _abj < array_length(global.achievements); _abj++)
                {
                    if (global.achievements[_abj].id == global.achievements_this_run[_abi])
                    {
                        draw_set_color(global.achievements[_abj].color);
                        draw_text(room_width / 2, _gy, global.achievements[_abj].name);
                        _gy += 18;
                        break;
                    }
                }
            }
            achievements_save();
            _gy += 5;
        }

        draw_set_color(make_color_rgb(200, 200, 200));
        draw_set_alpha(0.5 + sin(current_time / 300) * 0.3);
        draw_text(room_width / 2, _gy, "[ENTER] Retry    [ESC] Menu");
        draw_set_alpha(1);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        break;

    case "VICTORY":
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        scr_draw_panel(room_width / 2 - 260, room_height / 2 - 260, room_width / 2 + 260, room_height / 2 + 260, 0.85);

        draw_set_color(make_color_rgb(50, 255, 50));
        draw_text_transformed(room_width / 2, room_height / 2 - 230, "VICTORY!", 2.5, 2.5, 0);

        var _vy = room_height / 2 - 170;
        var _vl = 28;

        draw_set_color(make_color_rgb(255, 200, 50));
        draw_text(room_width / 2, _vy, "Score: " + string(floor(global.score)));
        _vy += _vl;

        draw_set_color(make_color_rgb(255, 150, 255));
        draw_text(room_width / 2, _vy, "Max Combo: x" + string(global.max_combo));
        _vy += _vl;

        draw_set_color(make_color_rgb(255, 100, 100));
        draw_text(room_width / 2, _vy, "Enemies: " + string(global.enemies_killed));
        _vy += _vl;

        draw_set_color(make_color_rgb(100, 255, 200));
        draw_text(room_width / 2, _vy, "Power-ups: " + string(global.powerups_collected));
        _vy += _vl;

        var _wl_eff_v = weapon_get_effective_level();
        var _wl_col_v = weapon_get_level_color(_wl_eff_v);
        draw_set_color(_wl_col_v);
        draw_text(room_width / 2, _vy, "Weapon: LV." + string(_wl_eff_v) + " " + weapon_get_level_name(_wl_eff_v));
        _vy += _vl;

        draw_set_color(make_color_rgb(200, 200, 200));
        draw_text(room_width / 2, _vy, "Time: " + highscores_format_time(global.game_time));
        _vy += _vl;

        var _total_w = 0;
        if (global.level_data != -1)
            _total_w = global.level_data.total_waves;
        draw_text(room_width / 2, _vy, "Waves: " + string(_total_w) + "/" + string(_total_w));
        _vy += _vl + 8;

        var _song_key = highscores_get_song_key(global.selected_music);
        var _rank = highscores_get_rank(global.score, global.max_combo, true);
        var _is_new = highscores_is_new_record(_song_key, global.score);

        var _rank_col = c_white;
        if (_rank == "S") _rank_col = make_color_rgb(255, 215, 0);
        else if (_rank == "A") _rank_col = make_color_rgb(255, 100, 100);
        else if (_rank == "B") _rank_col = make_color_rgb(100, 200, 255);
        else if (_rank == "C") _rank_col = make_color_rgb(100, 255, 100);
        else _rank_col = make_color_rgb(180, 180, 180);

        draw_set_color(_rank_col);
        draw_text_transformed(room_width / 2, _vy, "RANK:  " + _rank, 1.8, 1.8, 0);
        _vy += 38;

        if (_is_new)
        {
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_set_alpha(0.6 + sin(current_time / 200) * 0.4);
            draw_text(room_width / 2, _vy, "NEW RECORD!");
            draw_set_alpha(1);
        }
        else
        {
            var _best2 = highscores_get_best(_song_key);
            if (_best2 != -1)
            {
                draw_set_color(make_color_rgb(200, 200, 200));
                draw_set_alpha(0.6);
                draw_text(room_width / 2, _vy, "BEST: " + string(_best2.score) + "  RANK: " + _best2.rank);
                draw_set_alpha(1);
            }
        }
        _vy += 28;

        achievements_check(true);
        if (array_length(global.achievements_this_run) > 0)
        {
            draw_set_color(make_color_rgb(255, 200, 50));
            draw_set_alpha(0.9);
            draw_text(room_width / 2, _vy, "-- NEW BADGES --");
            _vy += 22;

            for (var _abi = 0; _abi < min(array_length(global.achievements_this_run), 5); _abi++)
            {
                for (var _abj = 0; _abj < array_length(global.achievements); _abj++)
                {
                    if (global.achievements[_abj].id == global.achievements_this_run[_abi])
                    {
                        achievements_draw_badge(room_width / 2 - 80 + (_abi * 40), _vy, global.achievements[_abj], 14);
                        break;
                    }
                }
            }
            _vy += 35;
            achievements_save();
        }

        var _pend_count = 0;
        for (var _pi = 0; _pi < array_length(global.achievements); _pi++)
        {
            if (!global.achievements[_pi].unlocked) _pend_count++;
        }
        if (_pend_count > 0)
        {
            draw_set_color(make_color_rgb(120, 120, 140));
            draw_set_alpha(0.5);
            draw_text(room_width / 2, _vy, string(_pend_count) + " badges remaining");
            draw_set_alpha(1);
            _vy += 20;
        }

        _vy += 5;
        draw_set_color(make_color_rgb(200, 200, 200));
        draw_set_alpha(0.5 + sin(current_time / 300) * 0.3);
        draw_text(room_width / 2, _vy, "[ENTER] Retry    [ESC] Menu");
        draw_set_alpha(1);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        break;
}

if (global.debug_overlay && global.game_state == "PLAYING")
{
    var _dx = 8;
    var _dy = 8;
    var _dw = 340;
    var _dh = 420;
    var _dline = 16;

    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(_dx - 4, _dy - 4, _dx + _dw, _dy + _dh, false);
    draw_set_alpha(1);

    var _cy = _dy + 4;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(make_color_rgb(255, 200, 50));
    draw_set_font(-1);
    draw_text(_dx + 4, _cy, "=== AI DEBUG [F1] ===");
    _cy += _dline + 4;

    var _bass = global.energy_bass;
    var _mids = global.energy_mids;
    var _highs = global.energy_highs;
    var _onset = global.onset_intensity;
    var _centroid = global.spectral_centroid;
    var _flatness = global.spectral_flatness;
    var _beat_str = global.beat_strength;
    var _peak = global.peak_density;

    draw_set_color(make_color_rgb(220, 40, 40));
    draw_text(_dx + 4, _cy, "Bass:    " + string(round(_bass * 100)) + "%");
    var _bx = _dx + 130;
    draw_set_color(c_dkgray); draw_rectangle(_bx, _cy + 1, _bx + 100, _cy + 13, false);
    draw_set_color(make_color_rgb(220, 40, 40)); draw_rectangle(_bx, _cy + 1, _bx + 100 * _bass, _cy + 13, false);
    _cy += _dline;

    draw_set_color(make_color_rgb(40, 220, 120));
    draw_text(_dx + 4, _cy, "Mids:    " + string(round(_mids * 100)) + "%");
    draw_set_color(c_dkgray); draw_rectangle(_bx, _cy + 1, _bx + 100, _cy + 13, false);
    draw_set_color(make_color_rgb(40, 220, 120)); draw_rectangle(_bx, _cy + 1, _bx + 100 * _mids, _cy + 13, false);
    _cy += _dline;

    draw_set_color(make_color_rgb(80, 120, 255));
    draw_text(_dx + 4, _cy, "Highs:   " + string(round(_highs * 100)) + "%");
    draw_set_color(c_dkgray); draw_rectangle(_bx, _cy + 1, _bx + 100, _cy + 13, false);
    draw_set_color(make_color_rgb(80, 120, 255)); draw_rectangle(_bx, _cy + 1, _bx + 100 * _highs, _cy + 13, false);
    _cy += _dline;

    draw_set_color(make_color_rgb(255, 255, 255));
    draw_text(_dx + 4, _cy, "Onset:   " + string(round(_onset * 100)) + "%");
    draw_set_color(c_dkgray); draw_rectangle(_bx, _cy + 1, _bx + 100, _cy + 13, false);
    draw_set_color(c_white); draw_rectangle(_bx, _cy + 1, _bx + 100 * _onset, _cy + 13, false);
    _cy += _dline + 4;

    var _intensity = global.ai_intensity_score;

    var _trend = "FLAT";
    var _trend_col = c_gray;
    if (global.ai_energy_trend > 0.03) { _trend = "RISING"; _trend_col = c_lime; }
    else if (global.ai_energy_trend < -0.03) { _trend = "FALLING"; _trend_col = c_red; }

    draw_set_color(make_color_rgb(255, 200, 50));
    draw_text(_dx + 4, _cy, "Intensity: " + string(round(_intensity * 100)) + "%  ");
    draw_set_color(_trend_col);
    draw_text(_dx + 200, _cy, "Trend: " + _trend);
    _cy += _dline;

    var _drop = global.ai_drop_imminent;
    var _break = global.ai_break_incoming;
    draw_set_color(_drop ? c_yellow : c_gray);
    draw_text(_dx + 4, _cy, "Drop Imminent: " + (_drop ? "YES" : "no"));
    draw_set_color(_break ? make_color_rgb(200, 100, 255) : c_gray);
    draw_text(_dx + 190, _cy, "Break: " + (_break ? "YES" : "no"));
    _cy += _dline + 4;

    var _sec = "MAIN";
    if (instance_exists(obj_rhythm))
        _sec = obj_rhythm.current_section;
    draw_set_color(make_color_rgb(100, 200, 255));
    draw_text(_dx + 4, _cy, "Section: " + _sec);
    draw_set_color(make_color_rgb(200, 100, 255));
    draw_text(_dx + 190, _cy, "BPM: " + string(global.bpm));
    _cy += _dline;

    var _beat_pos = "0/0";
    var _beat_s = 0;
    if (instance_exists(obj_rhythm) && obj_rhythm.music_started)
    {
        var _pos_s = audio_sound_get_track_position(obj_rhythm.current_sound) / 1000;
        var _beat_sec = 60 / max(1, global.bpm);
        var _idx = floor(_pos_s / _beat_sec);
        var _total = array_length(global.beat_times);
        _beat_pos = string(_idx) + "/" + string(_total);
        _beat_s = _beat_str;
    }
    draw_set_color(c_white);
    draw_text(_dx + 4, _cy, "Beat: " + _beat_pos + "  Str: " + string(round(_beat_s * 100)) + "%");
    _cy += _dline + 4;

    var _spawn_mult = global.ai_adaptive_spawn_mult;
    var _combo = global.combo_display;
    draw_set_color(make_color_rgb(100, 255, 100));
    draw_text(_dx + 4, _cy, "Spawn x" + string(round(_spawn_mult * 100) / 100) + "  Combo: " + string(_combo));
    _cy += _dline;

    var _formation = global.ai_last_formation;
    draw_set_color(make_color_rgb(255, 180, 100));
    draw_text(_dx + 4, _cy, "Formation: " + _formation);
    _cy += _dline;

    var _w = global.ai_last_weights;
    draw_set_color(make_color_rgb(255, 80, 80));
    draw_text(_dx + 4, _cy, "B:" + string(round(_w.basic * 100)) + "%");
    draw_set_color(make_color_rgb(255, 160, 50));
    draw_text(_dx + 80, _cy, "Z:" + string(round(_w.zigzag * 100)) + "%");
    draw_set_color(make_color_rgb(200, 100, 255));
    draw_text(_dx + 160, _cy, "H:" + string(round(_w.homing * 100)) + "%");
    draw_set_color(make_color_rgb(200, 40, 40));
    draw_text(_dx + 240, _cy, "V:" + string(round(_w.heavy * 100)) + "%");
    _cy += _dline + 4;

    var _total_w = 0;
    if (global.level_data != -1)
        _total_w = global.level_data.total_waves;
    draw_set_color(make_color_rgb(180, 180, 180));
    draw_text(_dx + 4, _cy, "Enemies: " + string(global.enemies_alive) + "  Wave: " + string(global.wave) + "/" + string(_total_w));
    _cy += _dline;

    var _zoom = global.ai_camera_zoom;
    draw_set_color(make_color_rgb(150, 200, 255));
    draw_text(_dx + 4, _cy, "Zoom: " + string(round(_zoom * 1000) / 1000));
    _cy += _dline + 4;

    var _c_r = global.chroma_r;
    var _c_g = global.chroma_g;
    var _c_b = global.chroma_b;
    draw_set_color(make_color_rgb(180, 180, 180));
    draw_text(_dx + 4, _cy, "Chroma RGB:");
    draw_set_color(make_color_rgb(_c_r * 255, _c_g * 255, _c_b * 255));
    draw_rectangle(_dx + 130, _cy, _dx + 230, _cy + 14, false);
    draw_set_color(c_white);
    draw_text(_dx + 240, _cy, string(round(_c_r * 100)) + "," + string(round(_c_g * 100)) + "," + string(round(_c_b * 100)));
    _cy += _dline + 4;

    draw_set_color(make_color_rgb(120, 120, 120));
    draw_text(_dx + 4, _cy, "Flatness: " + string(round(_flatness * 100)) + "%  Centroid: " + string(round(_centroid * 100)) + "%");
    _cy += _dline;
    draw_text(_dx + 4, _cy, "Peak Density: " + string(round(_peak * 100)) + "%");
}

if (global.fade_alpha > 0)
{
    draw_set_alpha(global.fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
