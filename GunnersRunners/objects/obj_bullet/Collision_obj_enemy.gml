if (beam)
{
    other.hp -= damage;
    other.image_blend = c_red;
    if (variable_instance_exists(other, "hit_timer"))
        other.hit_timer = 4;
    other.alarm[0] = 4;
    scr_screen_shake(1, 3);
}
else
{
    var _shielded = false;
    if (other.enemy_type == 4 && variable_instance_exists(other, "shield_hp") && other.shield_hp > 0)
    {
        _shielded = true;
        other.shield_hp--;
        other.shield_regen_timer = 0;
        for (var _si = 0; _si < 2; _si++)
        {
            var _sp = instance_create_layer(x + random_range(-10, 10), y + random_range(-10, 10), "Instances", obj_particle);
            _sp.vx = random_range(-2, 2);
            _sp.vy = random_range(-3, -1);
            _sp.size = random_range(2, 4);
            _sp.color = make_color_rgb(120, 180, 255);
            _sp.life = irandom_range(8, 14);
            _sp.max_life = _sp.life;
        }
    }

    if (!_shielded)
    {
        other.hp -= damage;
        other.image_blend = c_red;
        if (variable_instance_exists(other, "hit_timer"))
            other.hit_timer = 4;
        other.alarm[0] = 4;
    }

    if (variable_instance_exists(id, "chain") && chain && variable_instance_exists(id, "chain_count") && chain_count > 0)
    {
        if (!variable_instance_exists(id, "chained_ids"))
            chained_ids = [];
        array_push(chained_ids, other.id);

        var _best = noone;
        var _best_dist = chain_range;

        with (obj_enemy)
        {
            var _already = false;
            for (var _ci = 0; _ci < array_length(other.chained_ids); _ci++)
            {
                if (id == other.chained_ids[_ci]) { _already = true; break; }
            }
            if (!_already)
            {
                var _d = point_distance(x, y, other.x, other.y);
                if (_d < _best_dist) { _best_dist = _d; _best = id; }
            }
        }
        if (_best != noone)
        {
            var _chain_dmg = max(1, floor(damage * 0.8));
            _best.hp -= _chain_dmg;
            _best.image_blend = make_color_rgb(0, 200, 255);
            if (variable_instance_exists(_best, "hit_timer"))
                _best.hit_timer = 4;
            _best.alarm[0] = 4;
            chain_count--;

            for (var _cpi = 0; _cpi < 5; _cpi++)
            {
                var _cp = instance_create_layer(
                    lerp(x, _best.x, _cpi / 5),
                    lerp(y, _best.y, _cpi / 5),
                    "Instances", obj_particle);
                _cp.vx = random_range(-1, 1);
                _cp.vy = random_range(-1, 1);
                _cp.size = random_range(1, 3);
                _cp.color = make_color_rgb(0, 200, 255);
                _cp.life = irandom_range(6, 12);
                _cp.max_life = _cp.life;
            }
        }
    }

    scr_screen_shake(2, 5);

    if (exploder)
    {
        var _ex = instance_create_layer(x, y, "Instances", obj_explosion);
        _ex.damage = damage;
    }

    if (!piercing)
    {
        instance_destroy();
    }
}
