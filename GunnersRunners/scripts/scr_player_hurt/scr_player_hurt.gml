function scr_player_hurt()
{
    with (obj_player)
    {
        if (invincible || dead) return;

        hp--;
        combo = 0;
        combo_timer = 0;
        scr_screen_shake(6, 15);

        if (hp < global.stats_hp_min)
            global.stats_hp_min = hp;

        if (global.weapon_level > 1)
            global.weapon_level--;

        if (global.weapon_level < 2)
            global.weapon_branch = "";
        else if (global.weapon_branch == "A" && global.weapon_level < 3)
            global.weapon_branch = "";
        else if (global.weapon_branch == "B" && global.weapon_level < 3)
            global.weapon_branch = "";

        invincible = true;
        invincible_timer = invincible_duration;

        if (hp <= 0)
        {
            dead = true;
            global.game_over = true;
            global.game_state = "GAME_OVER";
            if (instance_exists(obj_rhythm))
                rhythm_stop_music(obj_rhythm);
            scr_screen_shake(10, 30);
        }
    }
}

function weapon_level_up()
{
    if (global.weapon_choosing) return;

    if (global.weapon_level < 2)
    {
        global.weapon_level++;
        if (global.weapon_level > global.stats_weapon_max_level)
            global.stats_weapon_max_level = global.weapon_level;
        weapon_level_up_fx();
        return;
    }

    if (global.weapon_level == 2 && global.weapon_branch == "")
    {
        global.weapon_choosing = true;
        return;
    }

    if (global.weapon_branch == "A" && global.weapon_level < 4)
    {
        global.weapon_level++;
        if (global.weapon_level > global.stats_weapon_max_level)
            global.stats_weapon_max_level = global.weapon_level;
        weapon_level_up_fx();
        return;
    }

    if (global.weapon_branch == "B" && global.weapon_level < 6)
    {
        global.weapon_level++;
        if (global.weapon_level > global.stats_weapon_max_level)
            global.stats_weapon_max_level = global.weapon_level;
        weapon_level_up_fx();
        return;
    }
}

function weapon_level_up_fx()
{
    scr_screen_shake(4, 12);
    if (instance_exists(obj_player))
    {
        for (var _pi = 0; _pi < 12; _pi++)
        {
            var _pt = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_particle);
            _pt.vx = random_range(-4, 4);
            _pt.vy = random_range(-4, 4);
            _pt.size = random_range(2, 5);
            _pt.color = weapon_get_level_color(global.weapon_level);
            _pt.life = irandom_range(20, 35);
            _pt.max_life = _pt.life;
        }
    }
}

function weapon_get_level_name(_level)
{
    switch (_level)
    {
        case 1: return "SINGLE";
        case 2: return "DUAL";
        case 3:
            if (global.weapon_branch == "A") return "SPREAD";
            if (global.weapon_branch == "B") return "HOMING";
            return "DUAL";
        case 4:
            if (global.weapon_branch == "A") return "SHOTGUN";
            if (global.weapon_branch == "B") return "CHAIN";
            return "DUAL";
        case 5:
            if (global.weapon_branch == "B") return "CHAIN";
            return "DUAL";
        case 6:
            if (global.weapon_branch == "B") return "CHAIN";
            return "DUAL";
        case 7: return "COMBO";
        case 8: return "ULTIMATE";
        default: return "SINGLE";
    }
}

function weapon_get_level_color(_level)
{
    switch (_level)
    {
        case 1: return make_color_rgb(180, 180, 180);
        case 2: return make_color_rgb(80, 180, 255);
        case 3:
            if (global.weapon_branch == "A") return make_color_rgb(180, 80, 255);
            if (global.weapon_branch == "B") return make_color_rgb(0, 200, 200);
            return make_color_rgb(80, 180, 255);
        case 4:
            if (global.weapon_branch == "A") return make_color_rgb(255, 140, 0);
            if (global.weapon_branch == "B") return make_color_rgb(0, 200, 100);
            return make_color_rgb(80, 180, 255);
        case 5:
            if (global.weapon_branch == "B") return make_color_rgb(0, 200, 100);
            return make_color_rgb(80, 180, 255);
        case 6:
            if (global.weapon_branch == "B") return make_color_rgb(0, 200, 100);
            return make_color_rgb(80, 180, 255);
        case 7: return make_color_rgb(255, 200, 50);
        case 8: return make_color_rgb(255, 100, 255);
        default: return make_color_rgb(180, 180, 180);
    }
}

function weapon_get_level_bonus(_level)
{
    switch (_level)
    {
        case 1: return 1.0;
        case 2: return 1.1;
        case 3: return 1.2;
        case 4: return 1.3;
        case 5: return 1.4;
        case 6: return 1.5;
        case 7: return 1.6;
        case 8: return 1.8;
        default: return 1.0;
    }
}

function weapon_get_effective_level()
{
    if (global.weapon_temp >= 0)
        return global.weapon_temp;
    return global.weapon_level;
}

function weapon_apply_temp(_temp_level)
{
    global.weapon_temp = _temp_level;
    global.weapon_temp_timer = 600;
}
