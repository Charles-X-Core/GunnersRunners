function scr_combo_update()
{
    if (instance_exists(obj_player))
    {
        if (obj_player.combo > 1)
        {
            global.combo_display = obj_player.combo;
            global.combo_alpha = 1;
            if (obj_player.combo > global.max_combo)
                global.max_combo = obj_player.combo;
        }
    }
    if (global.combo_alpha > 0)
    {
        global.combo_alpha -= 0.01;
    }
}
