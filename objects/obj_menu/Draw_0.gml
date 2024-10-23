var e = 0;
draw_set_halign(fa_center);
repeat 3{
	draw_set_color(e = menu_opt? c_green: c_white);
	draw_text(200, 200 + 92*e, menu[e]);
	e++;
}
if menu_level = 1{
	draw_set_color(!menu_opt2? c_green: c_white);
	draw_text(400, 200, "Public Lobby");
	draw_set_color(menu_opt2? c_green: c_white);
	draw_text(550, 200, "Friend Lobby");
}else if menu_level = 2{
	draw_line_width_color(400, 0, 400, room_height, 4, c_white, c_white);
	draw_text_transformed_color(room_width*2/3, room_height/2, "imagine...", 4, 4, -45, c_white, c_white, c_white, c_white, 1);
}
draw_set_halign(fa_left)