radius += grow_speed;

var _enemies = ds_list_create();
var _count = instance_place_list(x, y, obj_enemy, _enemies, false);
for (var i = 0; i < _count; i++)
{
    var _e = _enemies[| i];
    var _already = false;
    for (var j = 0; j < array_length(hit_enemies); j++)
    {
        if (hit_enemies[j] == _e.id) { _already = true; break; }
    }
    if (!_already)
    {
        _e.hp -= damage;
        _e.image_blend = c_red;
        _e.alarm[0] = 4;
        array_push(hit_enemies, _e.id);
        scr_screen_shake(1, 3);
    }
}
ds_list_destroy(_enemies);

if (radius >= max_radius)
{
    instance_destroy();
}
