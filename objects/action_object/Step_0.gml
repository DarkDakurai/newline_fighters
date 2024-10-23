if obj_console_game_handler.game_over exit;

if obj_console_game_handler.action_happening{
	if col != c_red col = (action_order_id = obj_console_game_handler.action_number? c_aqua: c_lime);
	if action_order_id = obj_console_game_handler.action_number && obj_console_game_handler.invalid_action = player col = c_red;
	exit;
}
col = c_lime;

lmb_down = obj_console_game_handler.lmb_down;
rmb_down = obj_console_game_handler.rmb_down;
lmb_pressed = obj_console_game_handler.lmb_pressed;
rmb_pressed = obj_console_game_handler.rmb_pressed;


if dragging == 0 && mouse_x = clamp(mouse_x, x, x + 296) && mouse_y = clamp(mouse_y, y, y + 15){
	if lmb_pressed{
		audio_play_sound(troop_grab, 10, 0);
		dragging = 1;
		og_y = y;
	}
	if rmb_pressed{
		audio_play_sound(troop_die, 10, 0);
		obj_console_game_handler.rmb_pressed = 0;
		with action_object if self != other && player = other.player && y > other.y y -= 20;
		obj_console_game_handler.reformat_actions = 2;
		
		//undo stored action
		if action_data[0].object_index == tile with resource_troops if player = other.player used_troops--;
		if action_data[0].object_index == obj_troop{
			action_data[0].action_stored = 0;
			action_data[0].new_tileangle = 0;
		}
		
		instance_destroy(self);
		exit;
	}
}else if dragging{
	y = max(215, mouse_y - 10);
	if !lmb_down{
		audio_play_sound(troop_land, 10, 0);
		dragging = 0;
		var num = -1;
		with action_object if player = other.player num++;
		y = min(215 + 20*num, 215 + floor((y - 215)/20)*20);
		if y != og_y with action_object if self != other && player = other.player{
			if y > other.og_y y -= 20;
			if y >= other.y y += 20;
		}
		if y != og_y obj_console_game_handler.reformat_actions = 2;
	}
}