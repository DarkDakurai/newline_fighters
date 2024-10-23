var e = 0;
repeat troop_am{
	draw_sprite_ext(spr_troop_resource, player-1, x + e*27, y, 1, 1, 20*dsin(dangle*2.5 + 30*e), c_white, 1);
	e++;
}