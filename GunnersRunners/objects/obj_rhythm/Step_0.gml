if (global.game_state == "ANALYZING")
{
    if (!analysis_complete)
    {
        rhythm_update_analysis(id);
    }
    if (analysis_complete && global.tutorial_mode)
    {
        global.level_data = scr_generate_tutorial_level(global.bpm);
        global.current_wave_index = 0;
        global.wave_beat_count = 0;
        global.wave = 1;
        global.wave_announce = 1;
        global.wave_announce_timer = 120;
        global.tutorial_text = "";
        global.tutorial_text_timer = 0;
    }
}

if (global.game_state == "PLAYING")
{
    if (instance_exists(obj_game) && obj_game.countdown_active)
    {
        if (global.beat_flash > 0)
            global.beat_flash = max(0, global.beat_flash - 0.04);
        exit;
    }

    rhythm_update_beat(id);
    scr_music_ai_analyze();

    var _current_time_sec = audio_sound_get_track_position(current_sound) / 1000;
    if (current_sound == -1 || !audio_is_playing(current_sound))
        _current_time_sec = global.current_beat_index * (60 / global.bpm);
    scr_audio_director_update(_current_time_sec);

    if (array_length(global.director_events) > 0)
    {
        var _slowmo = scr_audio_director_should_slowmo();
        if (_slowmo && !instance_exists(obj_player) || (instance_exists(obj_player) && !obj_player.powerup_time_slow))
        {
            if (_slowmo)
                global.time_slow = true;
            else if (!instance_exists(obj_player) || !obj_player.powerup_time_slow)
                global.time_slow = false;
        }

        var _zoom_t = scr_audio_director_get_zoom_target();
        global.ai_camera_zoom_target = _zoom_t;
    }

    scr_music_ai_control_enemies();
    scr_music_ai_control_environment();
    scr_tutorial_update();

    var _beat_fired = global.on_beat;

    if (!_beat_fired)
    {
        beat_timer++;
        var _beat_interval = room_speed * (60 / global.bpm);
        if (beat_timer >= _beat_interval)
        {
            beat_timer = 0;
            _beat_fired = true;
            global.beat_in_measure = (global.beat_in_measure + 1) mod 8;
            global.beat_flash = 0.5;
        }
    }

    if (music_started && !music_failed)
    {
        if (current_sound != -1 && audio_is_playing(current_sound))
        {
            global.music_energy = audio_sound_get_gain(current_sound);
        }
    }
    else
    {
        global.music_energy = 0.5 + sin(current_time * 0.001) * 0.3;
    }

    if (_beat_fired && global.level_data != -1)
    {
        var _waves = global.level_data.waves;

        if (global.current_wave_index < array_length(_waves))
        {
            var _wave = _waves[global.current_wave_index];
            current_section = _wave.section_type;

            if (_wave.is_boss && global.wave_beat_count == 0)
            {
                if (!instance_exists(obj_boss))
                {
                    var _boss = instance_create_layer(room_width / 2, -64, "Instances", obj_boss);
                    global.enemies_alive++;
                    scr_screen_shake(5, 15);
                    global.section_flash = 0.8;
                    for (var _bp = 0; _bp < 8; _bp++)
                    {
                        var _pt = instance_create_layer(room_width / 2 + random_range(-80, 80), -32, "Instances", obj_particle);
                        _pt.vx = random_range(-3, 3);
                        _pt.vy = random_range(1, 4);
                        _pt.size = random_range(3, 6);
                        _pt.color = make_color_rgb(255, 80, 80);
                        _pt.life = irandom_range(30, 50);
                        _pt.max_life = _pt.life;
                    }
                }
            }
            else if (!_wave.is_boss)
            {
                var _wave_progress = global.wave_beat_count / max(1, _wave.total_beats);
                var _spawn_info = choreography_get_spawn(
                    _wave.section_type,
                    global.beat_in_measure,
                    _wave.energy,
                    _wave_progress
                );

                if (_spawn_info.spawn)
                {
                    for (var _si = 0; _si < _spawn_info.count; _si++)
                    {
                        if (_si < array_length(_spawn_info.positions))
                        {
                            var _pos = _spawn_info.positions[_si];
                            var _enemy = instance_create_layer(_pos.x, _pos.y, "Instances", obj_enemy);
                            _enemy.enemy_type = _spawn_info.enemy_type;
                            _enemy.hp_multiplier = _wave.enemy_hp_mult * (1 + global.energy_bass * 0.2);
                            _enemy.move_timer = irandom(100);
                            _enemy.shoot_chance = _spawn_info.shoot_chance;
                            _enemy.hit_timer = 0;
                            _enemy.prev_positions = [];
                            _enemy.trail_counter = 0;
                            if (array_length(global.director_events) > 0)
                                scr_audio_director_get_enemy_behavior(_enemy);
                            else
                                scr_music_ai_enemy_behavior(_enemy);
                            global.enemies_alive++;
                        }
                    }
                }
            }

            global.wave_beat_count++;

            if (global.wave_beat_count >= _wave.total_beats)
            {
                global.wave_beat_count = 0;
                global.current_wave_index++;

                global.wave = (global.current_wave_index < array_length(_waves))
                    ? _waves[global.current_wave_index].number
                    : global.level_data.total_waves;

                global.wave_announce = global.wave;
                global.wave_announce_timer = 120;
            }
        }
        else
        {
            if (random(1) < 0.15)
            {
                var _type = irandom(3);
                var _zones = [1, 1, 1];
                var _enemy = scr_rhythm_spawn_on_beat(global.beat_in_measure, _zones, _type);
                if (_enemy != noone)
                {
                    _enemy.hp_multiplier = 1.5;
                    _enemy.enemy_type = _type;
                    global.enemies_alive++;
                }
            }
        }
    }
    else if (_beat_fired && global.level_data == -1)
    {
        var _fallback_spawn = 0.12;
        if (random(1) < _fallback_spawn)
        {
            var _fx = irandom_range(64, room_width - 64);
            var _fy = irandom_range(-64, room_height * 0.2);
            var _fe = instance_create_layer(_fx, _fy, "Instances", obj_enemy);
            if (global.wave >= 5 && random(1) < 0.15)
                _fe.enemy_type = irandom_range(4, 6);
            else
                _fe.enemy_type = irandom(min(3, global.wave - 1));
            _fe.hp_multiplier = 1.0 + (global.wave * 0.1);
            global.enemies_alive++;
        }
    }

    if (music_started && !music_failed)
    {
        var _song_ended = (current_sound != -1 && !audio_is_playing(current_sound));
        var _all_waves_done = (global.level_data != -1 && global.current_wave_index >= array_length(global.level_data.waves));
        var _no_enemies = (global.enemies_alive <= 0);
        var _boss_defeated = variable_global_exists("boss_defeated") && global.boss_defeated;

        if (_song_ended && _all_waves_done && _no_enemies)
        {
            rhythm_stop_music(id);
            global.game_state = "VICTORY";
        }
        else if (_boss_defeated && _all_waves_done && _no_enemies && _song_ended)
        {
            rhythm_stop_music(id);
            global.game_state = "VICTORY";
        }
    }

    sky_drop_timer++;
    var _sky_interval = room_speed * 4;
    var _sky_drop_interval = _sky_interval / global.ai_adaptive_powerup_mult;
    if (sky_drop_timer >= _sky_drop_interval)
    {
        sky_drop_timer = 0;
        var _drop_count = 1;
        if (random(1) < 0.25)
            _drop_count = 2;

        var _sky_pool = [0, 2, 3, 5, 12, 10, 9, 14];
        for (var _d = 0; _d < _drop_count; _d++)
        {
            var _pu = instance_create_layer(irandom_range(128, room_width - 128), -32, "Instances", obj_powerup);
            _pu.vspeed = random_range(1.2, 2.5);
            _pu.hspeed = random_range(-0.5, 0.5);
            _pu.powerup_type = _sky_pool[irandom(array_length(_sky_pool) - 1)];
            _pu.lifetime = irandom_range(420, 600);
        }
    }

    if (global.beat_flash > 0)
        global.beat_flash = max(0, global.beat_flash - 0.04);
}
