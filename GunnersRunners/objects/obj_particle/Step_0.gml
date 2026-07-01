x += vx;
y += vy;
vx *= friction_val;
vy *= friction_val;
life--;
if (life <= 0)
    instance_destroy();
