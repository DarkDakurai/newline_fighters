//action counter
var act = action_number >= 10;
draw_sprite(phase_numbers, action_number + action_happening, 878 + 9*act, 97);
if act draw_sprite(phase_numbers, action_number*.1, 878 - 9*act, 97);

//draw ghosts
var e = 0;
var p = noone;
var t = noone;
draw_set_color(c_red);
if phase = 1 && !action_happening repeat(array_length(local_actions)){
	p = local_actions[e][0];
	t = local_actions[e][1];
	draw_sprite_ext(p.sprite_index, p.image_index, t.x, t.y, 1, 1, p.image_angle, c_white, .4);
	draw_line_width(p.x, p.y, t.x, t.y, 2);
	draw_arrow(p.x, p.y, t.x, t.y, 10);
	e++;
}
e = 0;
if phase = 0 && !action_happening repeat(array_length(local_actions)){
	p = local_actions[e][0];
	if p.object_index = tile{
		t = local_actions[e][1];
		draw_sprite_ext(spr_troop, local_player-1, p.x, p.y, 1, 1, t*60, c_white, .4);
	}
	e++;
}

if !action_happening{
	var col = (timer != -1 && !obj_confirm_button.tapped? c_red: c_lime);
	draw_text_color(37 + (online_player-1)*1030, 215, (timer = -1? "Planning out actions...": "Orders confirmed" + chr(10) + "Time until " + string(obj_confirm_button.tapped? (local_player = 1? "Blue": "Red"): (local_player = 1? "Red": "Blue")) + "'s turn loss: " + string(floor(timer/60)) + "s"), col, col, col, col, 1);
}
if game_over{
	var dy = room_height/2 - sqr(50 - clamp(game_over_timer, 0, 50));
	draw_sprite(game_over_spr, menu_option + p2_win*2 + 4*!selected_menu, room_width*.5, dy);
}