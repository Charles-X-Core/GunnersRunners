powerup_type = irandom(21);
vspeed = 1.5;
hspeed = random_range(-0.3, 0.3);
move_timer = 0;
bob_speed = 0.06;
bob_amount = 4;
lifetime = 480;
blink_start = 360;

if (instance_exists(obj_rhythm) && obj_rhythm.music_started && global.level_data != -1)
{
    if (global.current_wave_index < array_length(global.level_data.waves))
    {
        var _sec = global.level_data.waves[global.current_wave_index].section_type;
        var _wn = global.wave;
        var _combo = instance_exists(obj_player) ? obj_player.combo : 0;
        var _hp = instance_exists(obj_player) ? obj_player.hp : 6;
        var _energy = global.music_energy;

        powerup_type = scr_powerup_select_section(_sec, _wn, _combo, _hp, _energy);
    }
}

function scr_powerup_select_section(_sec, _wn, _combo, _hp, _energy)
{
    var _pool = [];

    switch (_sec)
    {
        case "INTRO":
            array_push(_pool, { id: 2,  weight: 30 });
            array_push(_pool, { id: 5,  weight: 20 });
            array_push(_pool, { id: 13, weight: (_hp < 4) ? 15 : 0 });
            array_push(_pool, { id: 12, weight: 15 });
            array_push(_pool, { id: 10, weight: (_combo >= 3) ? 10 : 0 });
            array_push(_pool, { id: 0,  weight: 10 });
            break;

        case "BUILDUP":
            array_push(_pool, { id: 0,  weight: 25 });
            array_push(_pool, { id: 3,  weight: 20 });
            array_push(_pool, { id: 12, weight: 15 });
            array_push(_pool, { id: 19, weight: (_hp < 3) ? 15 : 0 });
            array_push(_pool, { id: 14, weight: (_wn >= 3 && _combo >= 5) ? 10 : 0 });
            array_push(_pool, { id: 2,  weight: 10 });
            break;

        case "MAIN":
            array_push(_pool, { id: 4,  weight: 20 });
            array_push(_pool, { id: 6,  weight: 20 });
            array_push(_pool, { id: 18, weight: (_wn >= 4 && _combo >= 8) ? 15 : 0 });
            array_push(_pool, { id: 3,  weight: 10 });
            array_push(_pool, { id: 7,  weight: (_wn >= 5 && _combo >= 5) ? 10 : 0 });
            array_push(_pool, { id: 17, weight: (_energy > 0.6) ? 10 : 0 });
            array_push(_pool, { id: 0,  weight: 10 });
            break;

        case "DROP":
            array_push(_pool, { id: 1,  weight: 15 });
            array_push(_pool, { id: 8,  weight: (_wn >= 7 && _combo >= 8) ? 15 : 0 });
            array_push(_pool, { id: 16, weight: (_wn >= 5 && _combo >= 15) ? 10 : 0 });
            array_push(_pool, { id: 20, weight: (_wn >= 6 && _energy > 0.7) ? 10 : 0 });
            array_push(_pool, { id: 21, weight: (_wn >= 8 && _energy > 0.8) ? 5 : 0 });
            array_push(_pool, { id: 17, weight: (_energy > 0.6) ? 10 : 0 });
            array_push(_pool, { id: 9,  weight: (_wn >= 4) ? 10 : 0 });
            array_push(_pool, { id: 15, weight: (_wn >= 6 && _combo >= 10) ? 5 : 0 });
            break;

        case "BREAK":
            array_push(_pool, { id: 10, weight: (_combo >= 3) ? 20 : 0 });
            array_push(_pool, { id: 11, weight: (_combo >= 10) ? 15 : 0 });
            array_push(_pool, { id: 13, weight: (_hp < 4) ? 15 : 0 });
            array_push(_pool, { id: 19, weight: (_hp < 3) ? 15 : 0 });
            array_push(_pool, { id: 12, weight: 15 });
            array_push(_pool, { id: 2,  weight: 10 });
            break;

        case "OUTRO":
            array_push(_pool, { id: 9,  weight: 15 });
            array_push(_pool, { id: 15, weight: (_wn >= 6 && _combo >= 10) ? 15 : 0 });
            array_push(_pool, { id: 3,  weight: 10 });
            array_push(_pool, { id: 0,  weight: 10 });
            array_push(_pool, { id: 14, weight: (_wn >= 3 && _combo >= 5) ? 10 : 0 });
            array_push(_pool, { id: 19, weight: (_hp < 3) ? 15 : 0 });
            break;

        default:
            array_push(_pool, { id: 0,  weight: 15 });
            array_push(_pool, { id: 2,  weight: 15 });
            array_push(_pool, { id: 3,  weight: 15 });
            array_push(_pool, { id: 12, weight: 15 });
            break;
    }

    var _total = 0;
    for (var i = 0; i < array_length(_pool); i++)
        _total += _pool[i].weight;

    if (_total <= 0) return 0;

    var _roll = random(_total);
    var _cum = 0;
    for (var i = 0; i < array_length(_pool); i++)
    {
        _cum += _pool[i].weight;
        if (_roll < _cum) return _pool[i].id;
    }

    return 0;
}
