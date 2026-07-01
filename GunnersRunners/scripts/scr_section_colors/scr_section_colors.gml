function get_section_color(_section)
{
    switch (_section)
    {
        case "INTRO":   return make_color_rgb(100, 150, 255);
        case "BUILDUP": return make_color_rgb(180, 80, 255);
        case "MAIN":    return make_color_rgb(200, 220, 255);
        case "DROP":    return make_color_rgb(255, 60, 60);
        case "BREAK":   return make_color_rgb(150, 100, 200);
        case "OUTRO":   return make_color_rgb(150, 160, 180);
    }
    return c_white;
}

function get_section_glow_color(_section)
{
    switch (_section)
    {
        case "INTRO":   return make_color_rgb(80, 120, 200);
        case "BUILDUP": return make_color_rgb(150, 50, 220);
        case "MAIN":    return make_color_rgb(180, 200, 240);
        case "DROP":    return make_color_rgb(220, 40, 40);
        case "BREAK":   return make_color_rgb(120, 80, 170);
        case "OUTRO":   return make_color_rgb(120, 130, 150);
    }
    return c_dkgray;
}

function get_section_bg_color(_section)
{
    switch (_section)
    {
        case "INTRO":   return make_color_rgb(15, 15, 35);
        case "BUILDUP": return make_color_rgb(25, 10, 40);
        case "MAIN":    return make_color_rgb(12, 12, 20);
        case "DROP":    return make_color_rgb(35, 8, 8);
        case "BREAK":   return make_color_rgb(20, 12, 30);
        case "OUTRO":   return make_color_rgb(15, 15, 18);
    }
    return c_black;
}

function get_section_flash_color(_section)
{
    switch (_section)
    {
        case "INTRO":   return make_color_rgb(100, 150, 255);
        case "BUILDUP": return make_color_rgb(180, 80, 255);
        case "MAIN":    return make_color_rgb(150, 180, 255);
        case "DROP":    return make_color_rgb(255, 80, 80);
        case "BREAK":   return make_color_rgb(150, 100, 200);
        case "OUTRO":   return make_color_rgb(130, 140, 160);
    }
    return c_white;
}

function enemy_apply_section_color(_type_col, _section, _beat_flash, _hit_timer)
{
    var _section_col = get_section_color(_section);
    var _final = merge_color(_type_col, _section_col, 0.3);

    if (_beat_flash > 0)
        _final = merge_color(_final, c_white, _beat_flash * 0.3);

    if (_hit_timer > 0)
        _final = merge_color(_final, c_red, _hit_timer / 4);

    return _final;
}
