if (keyboard_check_pressed(vk_f11))
{
    if (!window_get_fullscreen())
    {
        window_set_fullscreen(true);
    }
    else
    {
        window_set_fullscreen(false);
        window_set_size(1280, 720);
        surface_resize(application_surface, 1280, 720);
        window_set_position((display_get_width() - 1280) / 2, (display_get_height() - 720) / 2);
    }
}

if (keyboard_check_pressed(vk_f1))
{
    global.debug_overlay = !global.debug_overlay;
    show_debug_message("DEBUG OVERLAY: " + (global.debug_overlay ? "ON" : "OFF"));
}

if (global.fade_alpha > 0 || global.fade_target > 0)
{
    if (global.fade_alpha < global.fade_target)
    {
        global.fade_alpha = min(1, global.fade_alpha + global.fade_speed);
        if (global.fade_alpha >= 1 && global.fade_target >= 1 && global.fade_pending_state != "")
        {
            var _next = global.fade_pending_state;
            var _is_menu = global.fade_pending_is_menu;
            global.fade_pending_state = "";
            global.fade_pending_is_menu = false;

            if (_is_menu)
            {
                if (instance_exists(obj_rhythm))
                    rhythm_stop_music(obj_rhythm);
                global.game_state = _next;
                global.score = 0;
                global.score_display = 0;
                global.wave = 1;
                global.enemies_alive = 0;
                global.enemies_spawned = 0;
                global.game_over = false;
                global.max_combo = 0;
                global.enemies_killed = 0;
                global.powerups_collected = 0;
                global.game_time = 0;
                global.level_data = -1;
                countdown_active = false;

                with (obj_enemy) instance_destroy();
                with (obj_boss) instance_destroy();
                with (obj_enemy_bullet) instance_destroy();
                with (obj_bullet) instance_destroy();
                with (obj_powerup) instance_destroy();
                with (obj_explosion) instance_destroy();
                with (obj_particle) instance_destroy();
                with (obj_score_popup) instance_destroy();

                if (instance_exists(obj_player))
                {
                    obj_player.hp = obj_player.max_hp;
                    obj_player.dead = false;
                    obj_player.invincible = false;
                    obj_player.invincible_timer = 0;
                    obj_player.combo = 0;
                    obj_player.combo_timer = 0;
                    obj_player.x = room_width / 2;
                    obj_player.y = room_height * 0.8;
                    obj_player.angle = 270;
                    obj_player.hspeed = 0;
                    obj_player.vspeed = 0;
                }
            }
            else
            {
                global.game_state = _next;
            }
            global.fade_target = 0;
        }
    }
    else if (global.fade_alpha > global.fade_target)
    {
        global.fade_alpha = max(0, global.fade_alpha - global.fade_speed);
    }
}

if (global.fade_alpha > 0 && global.fade_alpha < 1)
    exit;

switch (global.game_state)
{
    case "SELECT_MUSIC":
        if (keyboard_check_pressed(vk_up))
        {
            selected_index = max(0, selected_index - 1);
        }
        if (keyboard_check_pressed(vk_down))
        {
            selected_index = min(array_length(music_files) - 1, selected_index + 1);
        }

        var _target_scroll = selected_index;
        if (_target_scroll < scroll_offset)
            scroll_offset = _target_scroll;
        if (_target_scroll >= scroll_offset + max_visible)
            scroll_offset = _target_scroll - max_visible + 1;
        scroll_offset = clamp(scroll_offset, 0, max(0, array_length(music_files) - max_visible));
        var _target_y = scroll_offset * 80;
        scroll_y = lerp(scroll_y, _target_y, 0.15);

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space))
        {
            var _sel = music_files[selected_index];
            if (string_pos("MP3:", _sel) > 0)
            {
                show_debug_message("IMPORT: Cannot play MP3 directly. Run convert_to_wav.py first.");
            }
            else
            {
                global.selected_music = _sel;
                global.song_selected = true;
                if (instance_exists(obj_rhythm))
                    rhythm_start_analysis(obj_rhythm, global.selected_music);
                global.fade_target = 1;
                global.fade_speed = 0.06;
                global.fade_pending_state = "ANALYZING";
                global.fade_pending_is_menu = false;
            }
        }
        if (keyboard_check_pressed(ord("T")))
        {
            var _sel = music_files[selected_index];
            if (string_pos("MP3:", _sel) > 0)
            {
                show_debug_message("IMPORT: Cannot play MP3 directly. Run convert_to_wav.py first.");
            }
            else
            {
                global.tutorial_mode = true;
                global.selected_music = _sel;
                if (instance_exists(obj_rhythm))
                    rhythm_start_analysis(obj_rhythm, global.selected_music);
                global.fade_target = 1;
                global.fade_speed = 0.06;
                global.fade_pending_state = "ANALYZING";
                global.fade_pending_is_menu = false;
            }
        }
        if (keyboard_check_pressed(ord("I")))
        {
            var _file = get_open_filename_ext("Audio Files|*.wav;*.mp3", "", "", "Import a song");
            if (_file != "")
            {
                var _dest = music_import_start(_file);
                if (is_string(_dest) && string_pos("MP3:", _dest) == 1)
                {
                    var _mp3_path = string_delete(_dest, 1, 4);
                    var _display_name = filename_change_ext(filename_name(_mp3_path), "");
                    _display_name = string_replace_all(_display_name, "_", " ");
                    _display_name = string_upper(string_char_at(_display_name, 1)) + string_delete(_display_name, 1, 1);

                    array_push(music_files, _dest);
                    array_push(music_names, _display_name + " [CONVERTING...]");
                    selected_index = array_length(music_files) - 1;
                }
                else if (_dest != -1)
                {
                    import_state = "COPYING";
                    import_path = _dest;
                    import_progress = 0;
                    global.game_state = "IMPORTING";
                }
            }
        }

        var _has_pending_mp3 = false;
        for (var _pi = 0; _pi < array_length(music_files); _pi++)
        {
            if (string_pos("MP3:", music_files[_pi]) == 1)
            {
                _has_pending_mp3 = true;
                break;
            }
        }
        var _rescan_target = _has_pending_mp3 ? 30 : rescan_interval;
        rescan_timer++;
        if (rescan_timer >= _rescan_target)
        {
            rescan_timer = 0;
            for (var i = 0; i < array_length(music_files); i++)
            {
                if (string_pos("MP3:", music_files[i]) == 1)
                {
                    var _mp3_path = string_delete(music_files[i], 1, 4);
                    var _wav_check = string_replace(_mp3_path, ".mp3", ".wav");
                    var _json_check = string_replace(_mp3_path, ".mp3", ".json");

                    if (file_exists(_wav_check) && file_exists(_json_check))
                    {
                        music_files[i] = _wav_check;
                        var _dn = filename_change_ext(filename_name(_wav_check), "");
                        _dn = string_replace_all(_dn, "_", " ");
                        _dn = string_upper(string_char_at(_dn, 1)) + string_delete(_dn, 1, 1);
                        music_names[i] = _dn + " [IMPORTED]";
                        show_debug_message("IMPORT: MP3 converted! Now available: " + _wav_check);
                    }
                    else if (file_exists(_wav_check))
                    {
                        music_files[i] = _wav_check;
                        var _dn = filename_change_ext(filename_name(_wav_check), "");
                        _dn = string_replace_all(_dn, "_", " ");
                        _dn = string_upper(string_char_at(_dn, 1)) + string_delete(_dn, 1, 1);
                        music_names[i] = _dn + " [NEEDS JSON]";
                    }
                }
            }
        }
        break;

    case "IMPORTING":
        if (import_state == "COPYING")
        {
            if (instance_exists(obj_rhythm))
            {
                var _result = rhythm_start_analysis(obj_rhythm, import_path);
                if (_result)
                {
                    import_state = "ANALYZING";
                    show_debug_message("IMPORT: Analysis started OK");
                }
                else
                {
                    show_debug_message("IMPORT: FAILED to start analysis");
                    import_state = "NONE";
                    import_path = "";
                    global.game_state = "SELECT_MUSIC";
                }
            }
        }
        else if (import_state == "ANALYZING")
        {
            if (instance_exists(obj_rhythm) && obj_rhythm.analysis_complete)
            {
                var _json_path = string_replace(import_path, ".wav", ".json");
                music_import_save_json(_json_path, obj_rhythm.analysis_data, global.level_data);

                var _display = filename_change_ext(filename_name(import_path), "");
                _display = string_replace_all(_display, "_", " ");
                _display = string_upper(string_char_at(_display, 1)) + string_delete(_display, 1, 1) + " [IMPORTED]";

                array_push(music_files, import_path);
                array_push(music_names, _display);

                selected_index = array_length(music_files) - 1;

                import_state = "NONE";
                import_path = "";
                import_progress = 0;
                global.game_state = "SELECT_MUSIC";
            }
            else if (instance_exists(obj_rhythm))
            {
                import_progress = obj_rhythm.analysis_progress;
            }
        }
        else if (import_state == "MP3_WAITING")
        {
            import_timer++;
            var _wav_check = string_replace(import_path, ".mp3", ".wav");
            var _json_check = string_replace(import_path, ".mp3", ".json");

            if (file_exists(_wav_check) && file_exists(_json_check))
            {
                for (var i = 0; i < array_length(music_files); i++)
                {
                    if (music_files[i] == ("MP3:" + import_path))
                    {
                        music_files[i] = _wav_check;
                        var _dn = filename_change_ext(filename_name(_wav_check), "");
                        _dn = string_replace_all(_dn, "_", " ");
                        _dn = string_upper(string_char_at(_dn, 1)) + string_delete(_dn, 1, 1);
                        music_names[i] = _dn + " [IMPORTED]";
                        selected_index = i;
                        break;
                    }
                }

                import_state = "NONE";
                import_path = "";
                import_progress = 0;
                import_timer = 0;
                global.game_state = "SELECT_MUSIC";
                show_debug_message("IMPORT: MP3 conversion detected! Song ready.");
            }
            else if (file_exists(_wav_check))
            {
                import_progress = 0.5;
            }
            else
            {
                import_progress = min(1, import_timer / 1800);
            }

            if (keyboard_check_pressed(vk_escape))
            {
                import_state = "NONE";
                import_path = "";
                import_timer = 0;
                global.game_state = "SELECT_MUSIC";
            }
        }
        break;

    case "ANALYZING":
        if (instance_exists(obj_rhythm) && obj_rhythm.analysis_complete)
        {
            global.analysis_done = true;
            global.game_state = "RESULTS";
        }
        break;

    case "RESULTS":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space))
        {
            global.game_state = "PLAYING";
            global.wave = 1;
            global.wave_announce = 1;
            global.wave_announce_timer = 120;
            global.current_wave_index = 0;
            global.wave_beat_count = 0;
            global.score = 0;
            global.score_display = 0;
            global.enemies_alive = 0;
            global.enemies_spawned = 0;
            global.game_over = false;
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

            countdown_active = true;
            countdown_frame = 0;
            countdown_number = 3;
            countdown_flash = 1.0;
            countdown_particles = [];
            scr_screen_shake(4, 10);
        }
        if (keyboard_check_pressed(vk_escape))
        {
            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "SELECT_MUSIC";
            global.fade_pending_is_menu = true;
        }
        break;

    case "PLAYING":
        if (countdown_active)
        {
            countdown_frame++;
            countdown_flash = max(0, countdown_flash - 0.04);

            for (var _ci = array_length(countdown_particles) - 1; _ci >= 0; _ci--)
            {
                var _cp = countdown_particles[_ci];
                _cp.x += _cp.vx;
                _cp.y += _cp.vy;
                _cp.life--;
                if (_cp.life <= 0)
                    array_delete(countdown_particles, _ci, 1);
            }

            if (countdown_frame mod 60 == 0 && countdown_frame < 180)
            {
                countdown_number--;
                countdown_flash = 1.0;
                scr_screen_shake(4, 10);

                var _colors = [c_red, make_color_rgb(255, 160, 0), c_yellow, c_lime];
                var _col = _colors[3 - countdown_number];
                for (var _pi = 0; _pi < 12; _pi++)
                {
                    var _angle = random(360);
                    var _spd = random_range(2, 6);
                    array_push(countdown_particles, {
                        x: room_width / 2,
                        y: room_height / 2,
                        vx: lengthdir_x(_spd, _angle),
                        vy: lengthdir_y(_spd, _angle),
                        life: irandom_range(20, 40),
                        max_life: 40,
                        color: _col,
                        size: random_range(2, 5)
                    });
                }
            }

            if (countdown_frame == 1)
            {
                for (var _pi = 0; _pi < 8; _pi++)
                {
                    var _angle = random(360);
                    var _spd = random_range(1, 4);
                    array_push(countdown_particles, {
                        x: room_width / 2,
                        y: room_height / 2,
                        vx: lengthdir_x(_spd, _angle),
                        vy: lengthdir_y(_spd, _angle),
                        life: irandom_range(30, 50),
                        max_life: 50,
                        color: c_white,
                        size: random_range(1, 3)
                    });
                }
            }

            if (countdown_frame >= countdown_total)
            {
                countdown_active = false;
                if (instance_exists(obj_rhythm))
                    rhythm_start_music(obj_rhythm);
            }

            var _cam_x = 0;
            var _cam_y = 0;
            if (global.shake_timer > 0)
            {
                global.shake_timer--;
                _cam_x = random_range(-global.shake_intensity, global.shake_intensity);
                _cam_y = random_range(-global.shake_intensity, global.shake_intensity);
            }
            var _zoom = variable_global_exists("ai_camera_zoom") ? global.ai_camera_zoom : 1.0;
            camera_set_view_size(view_camera[0], 1280 / _zoom, 720 / _zoom);
            camera_set_view_pos(view_camera[0], _cam_x + (1280 - 1280 / _zoom) / 2, _cam_y + (720 - 720 / _zoom) / 2);
            break;
        }

        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P")))
        {
            global.game_state = "PAUSE";
            if (instance_exists(obj_rhythm) && obj_rhythm.music_started && obj_rhythm.current_sound != -1)
                audio_pause_sound(obj_rhythm.current_sound);
            break;
        }

        global.game_time++;

        var _cam_x = 0;
        var _cam_y = 0;
        if (global.shake_timer > 0)
        {
            global.shake_timer--;
            _cam_x = random_range(-global.shake_intensity, global.shake_intensity);
            _cam_y = random_range(-global.shake_intensity, global.shake_intensity);
        }

        var _zoom = variable_global_exists("ai_camera_zoom") ? global.ai_camera_zoom : 1.0;
        var _view_w = 1280 / _zoom;
        var _view_h = 720 / _zoom;
        camera_set_view_size(view_camera[0], _view_w, _view_h);
        var _cx = _cam_x + (1280 - _view_w) / 2;
        var _cy = _cam_y + (720 - _view_h) / 2;
        camera_set_view_pos(view_camera[0], _cx, _cy);

        if (global.wave_announce_timer > 0)
        {
            global.wave_announce_timer--;
        }

        if (global.score_display < global.score)
        {
            global.score_display += max(1, (global.score - global.score_display) * 0.1);
            if (global.score_display > global.score) global.score_display = global.score;
        }

        if (!global.game_over)
        {
            if (global.level_data == -1)
            {
                if (global.enemies_spawned < global.enemies_per_wave)
                {
                    global.spawn_timer--;
                    if (global.spawn_timer <= 0)
                    {
                        var _is_boss_wave = (global.wave % 5 == 0);

                        if (_is_boss_wave && global.enemies_spawned == 0)
                        {
                            instance_create_layer(room_width / 2, -64, "Instances", obj_boss);
                            global.enemies_spawned++;
                            global.enemies_alive++;
                            global.spawn_timer = 999;
                        }
                        else
                        {
                            var _side = irandom(3);
                            var _x, _y;
                            switch (_side)
                            {
                                case 0: _x = irandom_range(32, room_width - 32); _y = -32; break;
                                case 1: _x = -32; _y = irandom_range(32, room_height / 2); break;
                                case 2: _x = room_width + 32; _y = irandom_range(32, room_height / 2); break;
                                case 3: _x = irandom_range(32, room_width - 32); _y = -32; break;
                            }
                            var _enemy = instance_create_layer(_x, _y, "Instances", obj_enemy);

                            if (global.wave < 3)
                            {
                                _enemy.enemy_type = 0;
                            }
                            else if (global.wave < 5)
                            {
                                _enemy.enemy_type = (random(1) < 0.4) ? 1 : 0;
                            }
                            else if (global.wave < 8)
                            {
                                var _r = random(1);
                                if (_r < 0.35) _enemy.enemy_type = 0;
                                else if (_r < 0.7) _enemy.enemy_type = 1;
                                else _enemy.enemy_type = 2;
                            }
                            else
                            {
                                var _r = random(1);
                                if (_r < 0.25) _enemy.enemy_type = 0;
                                else if (_r < 0.5) _enemy.enemy_type = 1;
                                else if (_r < 0.8) _enemy.enemy_type = 2;
                                else _enemy.enemy_type = 3;
                            }

                            global.enemies_spawned++;
                            global.enemies_alive++;
                            global.spawn_timer = global.spawn_delay;
                        }
                    }
                }
                else if (global.enemies_alive <= 0)
                {
                    if (global.wave_delay > 0)
                    {
                        global.wave_delay--;
                    }
                    else
                    {
                        global.wave++;
                        global.enemies_per_wave = 5 + (global.wave * 2);
                        global.enemies_spawned = 0;
                        global.spawn_timer = 120;
                        global.spawn_delay = max(20, 60 - (global.wave * 3));
                        global.wave_delay = 120;
                        global.wave_announce = global.wave;
                        global.wave_announce_timer = 120;
                    }
                }
            }
        }
        break;

    case "PAUSE":
        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P")))
        {
            global.game_state = "PLAYING";
            if (instance_exists(obj_rhythm) && obj_rhythm.music_started && obj_rhythm.current_sound != -1)
                audio_resume_sound(obj_rhythm.current_sound);
        }
        if (keyboard_check_pressed(ord("R")))
        {
            if (instance_exists(obj_rhythm))
                rhythm_stop_music(obj_rhythm);
            room_restart();
        }
        if (keyboard_check_pressed(ord("Q")))
        {
            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "SELECT_MUSIC";
            global.fade_pending_is_menu = true;
        }
        break;

    case "GAME_OVER":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("R")))
        {
            var _song_key = highscores_get_song_key(global.selected_music);
            var _rank = highscores_get_rank(global.score, global.max_combo, false);
            highscores_add(_song_key, global.score, global.wave, global.max_combo, global.game_time, _rank);

            with (obj_enemy) instance_destroy();
            with (obj_boss) instance_destroy();
            with (obj_enemy_bullet) instance_destroy();
            with (obj_bullet) instance_destroy();
            with (obj_powerup) instance_destroy();
            with (obj_explosion) instance_destroy();
            with (obj_particle) instance_destroy();
            with (obj_score_popup) instance_destroy();

            if (instance_exists(obj_rhythm))
            {
                rhythm_stop_music(obj_rhythm);
                rhythm_cleanup(obj_rhythm);
                obj_rhythm.analysis_complete = false;
                rhythm_start_analysis(obj_rhythm, global.selected_music);
            }

            global.score = 0;
            global.score_display = 0;
            global.wave = 1;
            global.wave_announce = 1;
            global.wave_announce_timer = 120;
            global.current_wave_index = 0;
            global.wave_beat_count = 0;
            global.enemies_alive = 0;
            global.enemies_spawned = 0;
            global.game_over = false;
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

            if (instance_exists(obj_player))
            {
                obj_player.hp = obj_player.max_hp;
                obj_player.dead = false;
                obj_player.invincible = false;
                obj_player.invincible_timer = 0;
                obj_player.combo = 0;
                obj_player.combo_timer = 0;
                obj_player.x = room_width / 2;
                obj_player.y = room_height * 0.8;
                obj_player.angle = 270;
                obj_player.hspeed = 0;
                obj_player.vspeed = 0;
            }

            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "ANALYZING";
            global.fade_pending_is_menu = false;
        }
        if (keyboard_check_pressed(vk_escape))
        {
            var _song_key = highscores_get_song_key(global.selected_music);
            var _rank = highscores_get_rank(global.score, global.max_combo, false);
            highscores_add(_song_key, global.score, global.wave, global.max_combo, global.game_time, _rank);

            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "SELECT_MUSIC";
            global.fade_pending_is_menu = true;
        }
        break;

    case "VICTORY":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("R")))
        {
            var _song_key = highscores_get_song_key(global.selected_music);
            var _rank = highscores_get_rank(global.score, global.max_combo, true);
            highscores_add(_song_key, global.score, global.wave, global.max_combo, global.game_time, _rank);

            with (obj_enemy) instance_destroy();
            with (obj_boss) instance_destroy();
            with (obj_enemy_bullet) instance_destroy();
            with (obj_bullet) instance_destroy();
            with (obj_powerup) instance_destroy();
            with (obj_explosion) instance_destroy();
            with (obj_particle) instance_destroy();
            with (obj_score_popup) instance_destroy();

            if (instance_exists(obj_rhythm))
            {
                rhythm_stop_music(obj_rhythm);
                rhythm_cleanup(obj_rhythm);
                obj_rhythm.analysis_complete = false;
                rhythm_start_analysis(obj_rhythm, global.selected_music);
            }

            global.score = 0;
            global.score_display = 0;
            global.wave = 1;
            global.wave_announce = 1;
            global.wave_announce_timer = 120;
            global.current_wave_index = 0;
            global.wave_beat_count = 0;
            global.enemies_alive = 0;
            global.enemies_spawned = 0;
            global.game_over = false;
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

            if (instance_exists(obj_player))
            {
                obj_player.hp = obj_player.max_hp;
                obj_player.dead = false;
                obj_player.invincible = false;
                obj_player.invincible_timer = 0;
                obj_player.combo = 0;
                obj_player.combo_timer = 0;
                obj_player.x = room_width / 2;
                obj_player.y = room_height * 0.8;
                obj_player.angle = 270;
                obj_player.hspeed = 0;
                obj_player.vspeed = 0;
            }

            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "ANALYZING";
            global.fade_pending_is_menu = false;
        }
        if (keyboard_check_pressed(vk_escape))
        {
            var _song_key = highscores_get_song_key(global.selected_music);
            var _rank = highscores_get_rank(global.score, global.max_combo, true);
            highscores_add(_song_key, global.score, global.wave, global.max_combo, global.game_time, _rank);

            global.fade_target = 1;
            global.fade_speed = 0.06;
            global.fade_pending_state = "SELECT_MUSIC";
            global.fade_pending_is_menu = true;
        }
        break;
}

scr_combo_update();
