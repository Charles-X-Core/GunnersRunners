function achievements_init()
{
    global.achievements = [
        { id: "FIRST_BLOOD",    name: "FIRST BLOOD",     desc: "Complete your first song",               color: make_color_rgb(255, 100, 100), icon: "S", unlocked: false },
        { id: "COMBO_MASTER",   name: "COMBO MASTER",     desc: "Reach max combo of 80+",                 color: make_color_rgb(255, 200, 50),  icon: "C", unlocked: false },
        { id: "PERFECT_RUN",    name: "PERFECT RUN",      desc: "Win with HP never below 5",              color: make_color_rgb(100, 255, 200), icon: "P", unlocked: false },
        { id: "SPEEDRUNNER",    name: "SPEEDRUNNER",      desc: "Win in under 3 minutes",                 color: make_color_rgb(80, 200, 255),  icon: "T", unlocked: false },
        { id: "UNTOUCHABLE",    name: "UNTOUCHABLE",      desc: "Win without taking any damage",          color: make_color_rgb(255, 255, 100), icon: "U", unlocked: false },
        { id: "SCORE_KING",     name: "SCORE KING",       desc: "Score over 100,000 points",              color: make_color_rgb(255, 180, 50),  icon: "K", unlocked: false },
        { id: "S_RANK",         name: "S RANK",           desc: "Achieve S rank on any song",             color: make_color_rgb(255, 215, 0),   icon: "S", unlocked: false },
        { id: "ELITE_HUNTER",   name: "ELITE HUNTER",     desc: "Kill 20+ elite enemies (types 4-6)",     color: make_color_rgb(200, 100, 255), icon: "E", unlocked: false },
        { id: "WEAPON_MASTER",  name: "WEAPON MASTER",    desc: "Reach weapon level 5 (MEGA)",            color: make_color_rgb(255, 150, 0),   icon: "W", unlocked: false },
        { id: "SURVIVOR",       name: "SURVIVOR",         desc: "Win with 1 HP remaining",                color: make_color_rgb(255, 80, 80),   icon: "X", unlocked: false }
    ];

    global.achievements_this_run = [];
    global.stats_elites_killed = 0;
    global.stats_hp_min = 6;
    global.stats_weapon_max_level = 1;
}

function achievements_check(_is_victory)
{
    global.achievements_this_run = [];

    if (_is_victory)
        _achieve("FIRST_BLOOD");

    if (global.max_combo >= 80)
        _achieve("COMBO_MASTER");

    if (_is_victory && global.stats_hp_min >= 5)
        _achieve("PERFECT_RUN");

    if (_is_victory && global.game_time < 10800)
        _achieve("SPEEDRUNNER");

    if (_is_victory && global.stats_hp_min >= 6)
        _achieve("UNTOUCHABLE");

    if (global.score > 100000)
        _achieve("SCORE_KING");

    var _rank = highscores_get_rank(global.score, global.max_combo, _is_victory);
    if (_rank == "S")
        _achieve("S_RANK");

    if (global.stats_elites_killed >= 20)
        _achieve("ELITE_HUNTER");

    if (global.stats_weapon_max_level >= 5)
        _achieve("WEAPON_MASTER");

    if (_is_victory && instance_exists(obj_player) && obj_player.hp <= 1)
        _achieve("SURVIVOR");

    return global.achievements_this_run;
}

function _achieve(_id)
{
    for (var i = 0; i < array_length(global.achievements); i++)
    {
        if (global.achievements[i].id == _id && !global.achievements[i].unlocked)
        {
            global.achievements[i].unlocked = true;
            array_push(global.achievements_this_run, _id);
            break;
        }
    }
}

function achievements_save()
{
    var _data = [];
    for (var i = 0; i < array_length(global.achievements); i++)
    {
        array_push(_data, {
            id: global.achievements[i].id,
            unlocked: global.achievements[i].unlocked
        });
    }
    var _json = json_stringify(_data);
    var _path = game_save_id + "achievements.json";
    var _buff = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buff, buffer_string, _json);
    buffer_save(_buff, _path);
    buffer_delete(_buff);
}

function achievements_load()
{
    var _path = game_save_id + "achievements.json";
    if (!file_exists(_path)) return;

    var _buff = buffer_load(_path);
    if (_buff == -1) return;

    buffer_seek(_buff, buffer_seek_start, 0);
    var _json = buffer_read(_buff, buffer_string);
    buffer_delete(_buff);

    var _data = json_parse(_json);
    if (!is_array(_data)) return;

    for (var i = 0; i < array_length(_data); i++)
    {
        for (var j = 0; j < array_length(global.achievements); j++)
        {
            if (global.achievements[j].id == _data[i].id)
            {
                global.achievements[j].unlocked = _data[i].unlocked;
                break;
            }
        }
    }
}

function achievements_draw_badge(_x, _y, _ach, _size)
{
    var _unlocked = _ach.unlocked;
    var _col = _unlocked ? _ach.color : make_color_rgb(60, 60, 70);
    var _alpha = _unlocked ? 1 : 0.35;

    draw_set_alpha(_alpha * 0.3);
    draw_set_color(_col);
    draw_rectangle(_x - _size, _y - _size, _x + _size, _y + _size, false);

    draw_set_alpha(_alpha * 0.6);
    draw_set_color(_col);
    draw_rectangle(_x - _size, _y - _size, _x + _size, _y + _size, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_alpha);
    draw_set_color(_unlocked ? c_white : make_color_rgb(100, 100, 110));
    draw_text(_x, _y, _ach.icon);

    if (_unlocked)
    {
        draw_set_alpha(0.5);
        draw_set_color(c_white);
        draw_rectangle(_x - _size, _y - _size, _x + _size, _y + _size, true);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
