popup_timer++;
y -= popup_speed;
popup_alpha -= 0.02;
if (popup_alpha <= 0) instance_destroy();
