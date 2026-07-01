function scr_score_popup(_x, _y, _score, _color)
{
    var _popup = instance_create_layer(_x, _y, "Instances", obj_score_popup);
    _popup.popup_score = _score;
    _popup.popup_color = _color;
}
