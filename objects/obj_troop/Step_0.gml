if obj_console_game_handler.game_over exit;

//lift mouse inputs
lmb_down = obj_console_game_handler.lmb_down;
rmb_down = obj_console_game_handler.rmb_down;
lmb_pressed = obj_console_game_handler.lmb_pressed;
rmb_pressed = obj_console_game_handler.rmb_pressed;


//drag logic
if obj_console_game_handler.action_happening new_tileangle = 0;
draggable = !obj_console_game_handler.action_happening && !obj_confirm_button.tapped && player == obj_console_game_handler.local_player && !action_stored;
if !draggable && obj_console_game_handler.selected_troop = self obj_console_game_handler.selected_troop = noone;

image_blend = (action_stored && !obj_console_game_handler.action_happening? c_gray: c_white);

if draggable && obj_console_game_handler.phase = 1{
	if dragging{
		x = mouse_x;
		y = mouse_y;
		
		near_tile = instance_nearest(x, y, tile);
		
		if !lmb_down{
			if array_contains(other.selected_tiles, near_tile) && (near_tile != tile_id || keyboard_check(vk_space)){
				action_stored = 1;
				var dist = point_distance(tile_id.x, tile_id.y, near_tile.x, near_tile.y);
				var steps = round(dist/56);
				array_push(obj_console_game_handler.local_actions, [self, near_tile, steps, point_direction(tile_id.x, tile_id.y, near_tile.x, near_tile.y)]);
				audio_play_sound(troop_land, 10, 0);
			}
			selected_tiles = [];
			dragging = 0;
			x = tile_id.x;
			y = tile_id.y;
		}
		
		if rmb_pressed{
			audio_play_sound(menu_cancel, 10, 0);
			selected_tiles = [];
			dragging = 0;
			x = tile_id.x;
			y = tile_id.y;
		}
		
	}else if position_meeting(mouse_x, mouse_y, self) && lmb_pressed{
		dragging = 1;
		audio_play_sound(troop_grab, 10, 0);
		with tile if (other.is_tower? distance_to_object(other) < 28: abs(point_direction(x, y, other.x, other.y)%60 - 30) > 29) array_push(other.selected_tiles, id);
	}
}else if draggable && obj_console_game_handler.phase = 0 && !obj_confirm_button.tapped{
	if obj_console_game_handler.selected_troop != self && position_meeting(mouse_x, mouse_y, self) && lmb_pressed{
		audio_play_sound(menu_select, 10, 0);
		obj_console_game_handler.selected_troop = self;
		if is_tower && resource_obj.used_troops < resource_obj.troop_am with tile if self != other.tile_id && point_distance(other.x, other.y, x, y) < 60 && (troop = noone || troop.player != other.player) array_push(other.selected_tiles, id);
	}
	var newsel = obj_console_game_handler.selected_troop == self;
	if obj_console_game_handler.selected_troop = self{
		if is_tower && resource_obj.troop_am > 0{
			near_tile = instance_nearest(mouse_x, mouse_y, tile);
			var tilean = new_tileangle;
			new_tileangle += mouse_wheel_up() - mouse_wheel_down();
			if new_tileangle != tilean audio_play_sound(troop_rotate, 10, 0);
			
			if lmb_pressed && array_contains(other.selected_tiles, near_tile){
				array_push(obj_console_game_handler.local_actions, [near_tile, new_tileangle + 3*(obj_console_game_handler.local_player = 2)]);
				audio_play_sound(troop_confirm, 10, 0);
				obj_console_game_handler.selected_troop = noone;
				resource_obj.used_troops++;
				new_tileangle = 0;
				selected_tiles = [];
			}
		}else{
			var tilean = new_tileangle;
			new_tileangle += mouse_wheel_up() - mouse_wheel_down();
			if new_tileangle != tilean audio_play_sound(troop_rotate, 10, 0);
		}
		
		if rmb_pressed || lmb_pressed || (!newsel && prev_sel != newsel){
			if is_tower && !lmb_pressed new_tileangle = 0;
			if !lmb_pressed selected_tiles = [];
			if rmb_pressed{
				audio_play_sound(menu_cancel, 10, 0);
				obj_console_game_handler.selected_troop = noone;
				new_tileangle = 0;
			}
			if new_tileangle != 0 && !is_tower{
				if lmb_pressed obj_console_game_handler.selected_troop = noone;
				array_push(obj_console_game_handler.local_actions, [self, image_angle/60 + new_tileangle]);
				audio_play_sound(troop_confirm, 10, 0);
				if !is_tower action_stored = 1;
			}
		}
	}
	prev_sel = obj_console_game_handler.selected_troop == self;
}else dragging = 0;
