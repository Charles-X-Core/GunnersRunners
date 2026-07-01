function choreography_get_spawn(_section, _beat, _energy, _wave_progress)
{
    switch (_section)
    {
        case "INTRO":   return choreo_intro(_beat, _energy, _wave_progress);
        case "BUILDUP": return choreo_buildup(_beat, _energy, _wave_progress);
        case "MAIN":    return choreo_main(_beat, _energy, _wave_progress);
        case "DROP":    return choreo_drop(_beat, _energy, _wave_progress);
        case "BREAK":   return choreo_break(_beat, _energy, _wave_progress);
        case "OUTRO":   return choreo_outro(_beat, _energy, _wave_progress);
    }
    return { spawn: false, count: 0, positions: [], enemy_type: 0, shoot_chance: 0 };
}

function choreo_intro(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 0, shoot_chance: 0.3 };

    if (_beat == 0 || _beat == 4)
    {
        _result.spawn = true;
        _result.count = 1;
        var _zx = (_beat == 0) ? irandom_range(64, room_width * 0.33) : irandom_range(room_width * 0.66, room_width - 64);
        _result.positions = [{ x: _zx, y: irandom_range(-32, 40) }];
        _result.enemy_type = 0;
    }
    else if (_beat == 2 || _beat == 6)
    {
        if (_progress > 0.4)
        {
            _result.spawn = true;
            _result.count = 1;
            _result.positions = [{ x: room_width / 2 + irandom_range(-40, 40), y: irandom_range(-32, 40) }];
            _result.enemy_type = 0;
        }
    }

    return _result;
}

function choreo_buildup(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 1, shoot_chance: 0.6 };

    var _density = 0.5 + _progress * 0.5;

    if (_beat == 0)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: room_width / 2, y: irandom_range(-32, 20) }];
        _result.enemy_type = 1;
    }
    else if (_beat == 2 && _density > 0.6)
    {
        _result.spawn = true;
        _result.count = 2;
        _result.positions = choreo_formation_V(2, room_width / 2, 30);
        _result.enemy_type = 0;
    }
    else if (_beat == 4 && _density > 0.7)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: room_width / 2 + irandom_range(-60, 60), y: irandom_range(-32, 20) }];
        _result.enemy_type = 2;
        _result.shoot_chance = 0.5;
    }
    else if (_beat == 6)
    {
        _result.spawn = true;
        _result.count = (_density > 0.8) ? 3 : 2;
        if (_result.count == 3)
            _result.positions = choreo_formation_arc(3, room_width / 2, 30);
        else
            _result.positions = choreo_formation_V(2, room_width / 2, 30);
        _result.enemy_type = 1;
    }

    return _result;
}

function choreo_main(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 0, shoot_chance: 0.8 };

    var _phase = floor(_progress * 4) mod 3;
    var _wn = global.wave;

    if (_beat == 0)
    {
        _result.spawn = true;
        if (_phase == 0)
        {
            _result.count = 2;
            _result.positions = choreo_formation_V(2, room_width / 2, 20);
            _result.enemy_type = 1;
        }
        else if (_phase == 1)
        {
            _result.count = 2;
            _result.positions = choreo_formation_line(2, 30);
            _result.enemy_type = 0;
        }
        else
        {
            _result.count = 3;
            _result.positions = choreo_formation_arc(3, room_width / 2, 20);
            _result.enemy_type = 1;
        }
    }
    else if (_beat == 2)
    {
        _result.spawn = true;
        _result.count = 1;
        var _zones = [room_width * 0.25, room_width * 0.5, room_width * 0.75];
        _result.positions = [{ x: _zones[irandom(2)], y: irandom_range(-32, 20) }];
        _result.enemy_type = 2;
    }
    else if (_beat == 4)
    {
        _result.spawn = true;
        _result.count = 2;
        _result.positions = choreo_formation_line(2, 25);
        _result.enemy_type = 0;
    }
    else if (_beat == 6)
    {
        _result.spawn = true;
        if (_wn >= 4 && _energy > 0.5 && random(1) < 0.25)
        {
            _result.count = 1;
            _result.positions = [{ x: room_width / 2 + irandom_range(-60, 60), y: irandom_range(-48, -16) }];
            _result.enemy_type = (random(1) < 0.5) ? 4 : 5;
            _result.shoot_chance = 0.65;
        }
        else
        {
            _result.count = 1;
            _result.positions = [{ x: room_width / 2, y: irandom_range(-48, -16) }];
            _result.enemy_type = 3;
            _result.shoot_chance = 0.7;
        }
    }

    return _result;
}

function choreo_drop(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 2, shoot_chance: 1.0 };
    var _wn = global.wave;

    switch (_beat)
    {
        case 0:
            _result.spawn = true;
            _result.count = 4;
            _result.positions = choreo_formation_wall(4);
            _result.enemy_type = (_wn >= 5 && random(1) < 0.3) ? 5 : 1;
            break;
        case 1:
            _result.spawn = true;
            _result.count = 2;
            _result.positions = [
                { x: irandom_range(48, room_width * 0.3), y: irandom_range(-32, 10) },
                { x: irandom_range(room_width * 0.7, room_width - 48), y: irandom_range(-32, 10) }
            ];
            _result.enemy_type = 2;
            break;
        case 2:
            _result.spawn = true;
            _result.count = 3;
            _result.positions = choreo_formation_arc(3, room_width / 2, 20);
            _result.enemy_type = 1;
            break;
        case 3:
            _result.spawn = true;
            _result.count = 1;
            if (_wn >= 5 && random(1) < 0.35)
            {
                _result.positions = [{ x: room_width / 2, y: -32 }];
                _result.enemy_type = 6;
                _result.shoot_chance = 0;
            }
            else
            {
                _result.positions = [{ x: room_width / 2, y: -32 }];
                _result.enemy_type = 3;
            }
            break;
        case 4:
            _result.spawn = true;
            _result.count = 4;
            _result.positions = choreo_formation_wall(4);
            _result.enemy_type = 2;
            break;
        case 5:
            _result.spawn = true;
            _result.count = 2;
            _result.positions = [
                { x: irandom_range(48, room_width * 0.3), y: irandom_range(-32, 10) },
                { x: irandom_range(room_width * 0.7, room_width - 48), y: irandom_range(-32, 10) }
            ];
            _result.enemy_type = 1;
            break;
        case 6:
            _result.spawn = true;
            _result.count = 3;
            _result.positions = choreo_formation_cluster(3, room_width / 2, 20);
            _result.enemy_type = 2;
            break;
        case 7:
            _result.spawn = true;
            _result.count = 1;
            if (_wn >= 4 && _energy > 0.6 && random(1) < 0.4)
            {
                _result.positions = [{ x: room_width / 2 + irandom_range(-80, 80), y: -48 }];
                _result.enemy_type = 4;
                _result.shoot_chance = 0.7;
            }
            else
            {
                _result.positions = [{ x: room_width / 2 + irandom_range(-80, 80), y: -48 }];
                _result.enemy_type = 3;
            }
            break;
    }

    return _result;
}

function choreo_break(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 0, shoot_chance: 0.2 };

    if (_beat == 0)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: room_width / 2 + irandom_range(-40, 40), y: irandom_range(-32, 20) }];
        _result.enemy_type = 0;
    }
    else if (_beat == 4 && _progress > 0.5)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: room_width / 2 + irandom_range(-60, 60), y: irandom_range(-32, 20) }];
        _result.enemy_type = 0;
    }

    return _result;
}

function choreo_outro(_beat, _energy, _progress)
{
    var _result = { spawn: false, count: 0, positions: [], enemy_type: 0, shoot_chance: 0.3 };

    var _fade = max(0, 1 - _progress * 1.5);

    if (_beat == 0 && _fade > 0.3)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: irandom_range(64, room_width * 0.33), y: irandom_range(-32, 10) }];
        _result.enemy_type = 0;
    }
    else if (_beat == 4 && _fade > 0.5)
    {
        _result.spawn = true;
        _result.count = 1;
        _result.positions = [{ x: irandom_range(room_width * 0.66, room_width - 64), y: irandom_range(-32, 10) }];
        _result.enemy_type = 1;
    }

    return _result;
}

function choreo_formation_V(_count, _center_x, _y)
{
    var _positions = [];
    for (var _i = 0; _i < _count; _i++)
    {
        var _spread = 60 + _i * 50;
        var _offx = (_i mod 2 == 0) ? -_spread : _spread;
        array_push(_positions, { x: _center_x + _offx, y: _y - _i * 15 });
    }
    return _positions;
}

function choreo_formation_line(_count, _y)
{
    var _positions = [];
    var _line_w = room_width * 0.6;
    var _start_x = (room_width - _line_w) / 2;
    for (var _i = 0; _i < _count; _i++)
    {
        var _lx = (_count == 1) ? room_width / 2 : _start_x + (_line_w / (_count - 1)) * _i;
        array_push(_positions, { x: _lx, y: _y + irandom_range(-10, 10) });
    }
    return _positions;
}

function choreo_formation_arc(_count, _center_x, _y)
{
    var _positions = [];
    var _arc_r = 100;
    for (var _i = 0; _i < _count; _i++)
    {
        var _ang = 180 + (_i / max(1, _count - 1)) * 180;
        var _ax = _center_x + lengthdir_x(_arc_r, _ang);
        var _ay = _y + lengthdir_y(_arc_r * 0.3, _ang);
        array_push(_positions, { x: _ax, y: _ay });
    }
    return _positions;
}

function choreo_formation_wall(_count)
{
    var _positions = [];
    var _wall_w = room_width * 0.7;
    var _start_x = (room_width - _wall_w) / 2;
    for (var _i = 0; _i < _count; _i++)
    {
        var _wx = _start_x + (_wall_w / max(1, _count - 1)) * _i;
        array_push(_positions, { x: _wx, y: irandom_range(-48, -16) });
    }
    return _positions;
}

function choreo_formation_cluster(_count, _center_x, _y)
{
    var _positions = [];
    for (var _i = 0; _i < _count; _i++)
    {
        array_push(_positions, {
            x: _center_x + random_range(-80, 80),
            y: _y + random_range(-20, 20)
        });
    }
    return _positions;
}

function choreo_formation_spiral(_count, _center_x, _center_y)
{
    var _positions = [];
    for (var _i = 0; _i < _count; _i++)
    {
        var _ang = _i * 60;
        var _rad = 40 + _i * 25;
        array_push(_positions, {
            x: _center_x + lengthdir_x(_rad, _ang),
            y: _center_y + lengthdir_y(_rad, _ang)
        });
    }
    return _positions;
}
