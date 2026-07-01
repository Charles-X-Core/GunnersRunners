function scr_rhythm_spawn_on_beat(_beat_in_measure, _spawn_zones, _enemy_type)
{
    var _zone = -1;

    switch (_beat_in_measure)
    {
        case 0: case 4:
            if (_spawn_zones[0]) _zone = 0;
            else if (_spawn_zones[1]) _zone = 1;
            break;
        case 1: case 5:
            if (_spawn_zones[1]) _zone = 1;
            else if (_spawn_zones[0]) _zone = 0;
            break;
        case 2: case 6:
            if (_spawn_zones[2]) _zone = 2;
            else if (_spawn_zones[1]) _zone = 1;
            break;
        case 3: case 7:
            if (_spawn_zones[1]) _zone = 1;
            else if (_spawn_zones[2]) _zone = 2;
            break;
    }

    if (_zone == -1) return noone;

    var _x, _y;
    var _margin = 48;

    switch (_zone)
    {
        case 0:
            _x = irandom_range(_margin, room_width * 0.33);
            _y = irandom_range(-_margin, room_height * 0.25);
            break;
        case 1:
            _x = irandom_range(room_width * 0.33, room_width * 0.66);
            _y = irandom_range(-_margin, room_height * 0.25);
            break;
        case 2:
            _x = irandom_range(room_width * 0.66, room_width - _margin);
            _y = irandom_range(-_margin, room_height * 0.25);
            break;
    }

    var _enemy = instance_create_layer(_x, _y, "Instances", obj_enemy);
    _enemy.enemy_type = _enemy_type;

    return _enemy;
}

function scr_rhythm_spawn_multiple(_beat_in_measure, _spawn_zones, _enemy_type, _count)
{
    var _spawned = [];
    for (var i = 0; i < _count; i++)
    {
        var _e = scr_rhythm_spawn_on_beat((_beat_in_measure + i) mod 8, _spawn_zones, _enemy_type);
        if (_e != noone)
            array_push(_spawned, _e);
    }
    return _spawned;
}
