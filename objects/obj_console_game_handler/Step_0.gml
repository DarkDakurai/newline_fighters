//init players
if local_player = 0 || online_player = 0{
	local_player = obj_client.local_player;
	online_player = obj_client.online_player;
	if local_player = 0 || online_player = 0 exit;
}

//init towers
if init_towers && p1_tower = noone{
	with obj_troop if is_tower{
		if player = 1 other.p1_tower = self;
		if player = 2 other.p2_tower = self;
	}
	if p1_tower != noone init_towers = 0;
}

p2_win = !instance_exists(p1_tower);
p1_win = !instance_exists(p2_tower);

if (p1_win || p2_win) && action_timer = 0 && !game_over{
	audio_play_sound(sfx_applause, 10, 0);
	game_over = 1;
}

if game_over{
	game_over_timer++;
	if selected_menu && (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left)){
		audio_play_sound(menu_scroll, 10, 0);
		menu_option = !menu_option;
	}
	if keyboard_check_pressed(vk_escape){
		audio_play_sound(menu_cancel, 10, 0);
		selected_menu = 1;
		var buff = obj_client.inbuf;
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_write(buff, buffer_u8, network.rematch)
		buffer_write(buff, buffer_u8, 0);
		if !global.is_steam_connection{ //when a game over happens this one resets the rematch variable to 0 if the player decides to undo the chosen option
			network_send_packet(obj_client.client, buff, buffer_tell(buff));
		}else{
			steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
		}
	}
	if keyboard_check_pressed(vk_enter){
		audio_play_sound(troop_confirm, 10, 0);
		selected_menu = 0;
		var buff = obj_client.inbuf;
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_write(buff, buffer_u8, network.rematch)
		buffer_write(buff, buffer_u8, menu_option+1);
		if !global.is_steam_connection{ //when a game over happens this one confirms the choice, be it rematch or 
			network_send_packet(obj_client.client, buff, buffer_tell(buff));
		}else{
			steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
			
		}
	}
	exit;
}


//mouse input handling
lmb_down = mouse_button == mb_left;
rmb_down = mouse_button == mb_right;
if lmb_pressed lmb_pressed--;
if rmb_pressed rmb_pressed--;
if lmb_down && !lmb_down_old lmb_pressed = 1;
if rmb_down && !rmb_down_old rmb_pressed = 1;
lmb_down_old = lmb_down;
rmb_down_old = rmb_down;
persistent = 0;


if arrived_data = 1{
	if timer = -1 timer = 120*60;
	if timer timer--;
	if timer = 0 && obj_confirm_button.tapped{
		action_happening = 1;
		arrived_data = 0;
		timer = -1;
		var buff = obj_client.inbuf;
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_write(buff, buffer_u8, network.confirm_next_phase_override)
		if !global.is_steam_connection{ //when the timer to confirm an action runs out this trigger will make it so it gets notified on both 
			network_send_packet(obj_client.client, buff, buffer_tell(buff));
		}else{
			steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
			
		}
	}
}
if arrived_data = 2{
	action_happening = 1;
	arrived_data = 0;
	timer = -1;
	var buff = obj_client.inbuf;
	buffer_seek(buff, buffer_seek_start, 0);
	buffer_write(buff, buffer_u8, network.confirm_next_phase)
	if !global.is_steam_connection{ //when both players have submitted their actions the play out animation of said actions is triggered and this flag is sent to both ends to notify as such (also good for syncing)
		network_send_packet(obj_client.client, buff, buffer_tell(buff));
	}else{
		steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
		
	}
}


if online_string_list != ""{
	var arr = string_split(online_string_list, " ");
	online_string_list = "";
	var m = 1;
	var len = array_length(arr)/3;
	var dirs = ["E", "NE", "NW", "W", "SW", "SE"];
	if phase{
		repeat len{
			var pos1 = arr[m]
			var pos2 = arr[m+1]
			var tile1 = noone;
			var tile2 = noone;
			with tile{
				if map_val = pos1 tile1 = self;
				if map_val = pos2 tile2 = self;
			}
			var dist = point_distance(tile1.x, tile1.y, tile2.x, tile2.y);
			var steps = round(dist/56);
			array_push(online_actions, [tile1.troop, tile2, steps, point_direction(tile1.x, tile1.y, tile2.x, tile2.y)]);
			m += 3;
		}
	}else{
		m = 0;
		repeat len{
			var pos1 = arr[m+1];
			var pos2 = arr[m+2];
			var tile1 = noone;
			with tile if map_val = pos1 tile1 = self;
			var dir = findIndex(dirs, pos2);
			if arr[m] = "/" array_push(online_actions, [tile1.troop, dir]);
			else array_push(online_actions, [tile1, dir]);
			m += 3;
		}
	}
}

var old_len = array_length(local_actions);
if old_len != prev_len reformat_actions = 1;
if reformat_actions = 2{
	var num = 0;
	with action_object if player = other.local_player num++;
	var e = 0;
	var ar = [];
	repeat num{
		with action_object if x = 37 + (other.local_player-1)*1030 && y = 215 + 20*e array_push(ar, action_data);
		e++;
	}
	local_actions = ar;
	reformat_actions = 1;
}
if reformat_actions = 1{
	with action_object if player = other.local_player instance_destroy(self);
	var n = 0;
	action_string_list = "";
	repeat array_length(local_actions){
		var act = local_actions[n];
		var type = (array_length(act) == 2) + (act[0].object_index == tile);
		var p = instance_create_layer(37 + (local_player-1)*1030, 215 + 20*n, "UI_stuff", action_object);
		p.player = local_player;
		p.action_data = act;
		var dirs = ["E", "NE", "NW", "W", "SW", "SE"];
		switch type{
			case 0:
			p.action_string = act[0].tile_id.map_val + " move to " + act[1].map_val;
			action_string_list += "> " + act[0].tile_id.map_val + " " + act[1].map_val + " ";
			break;
			
			case 1:
			p.action_string = act[0].tile_id.map_val + " turn " + dirs[((act[1]%6) + 6)%6];
			action_string_list += "/ " + act[0].tile_id.map_val + " " + dirs[((act[1]%6) + 6)%6] + " ";
			break;
			
			case 2:
			p.action_string = "summon at " + act[0].map_val + " facing " + dirs[((act[1]%6) + 6)%6];
			action_string_list += "* " + act[0].map_val + " " + dirs[((act[1]%6) + 6)%6] + " ";
			break;
		}
		p.action_order_id = n;
		n++;
	}
	reformat_actions = 0;
}
if reformat_actions = 3{
	with action_object if player = other.online_player instance_destroy(self);
	var n = 0;
	online_string_list = "";
	repeat array_length(online_actions){
		var act = online_actions[n];
		var type = (array_length(act) == 2) + (act[0].object_index == tile);
		var p = instance_create_layer(37 + (online_player-1)*1030, 215 + 20*n, "UI_stuff", action_object);
		p.player = online_player;
		p.action_data = act;
		var dirs = ["E", "NE", "NW", "W", "SW", "SE"];
		switch type{
			case 0:
			p.action_string = act[0].tile_id.map_val + " move to " + act[1].map_val;
			break;
			
			case 1:
			p.action_string = act[0].tile_id.map_val + " turn " + dirs[((act[1]%6) + 6)%6];
			break;
			
			case 2:
			p.action_string = "summon at " + act[0].map_val + " facing " + dirs[((act[1]%6) + 6)%6];;
			break;
		}
		p.action_order_id = n;
		n++;
	}
	reformat_actions = 0;
}

prev_len = array_length(local_actions);

if action_happening && !obj_client.confirm_phase_endlocal{
	var first_loc = local_player = 1;
	var ar = (first_loc? [local_actions, online_actions]: [online_actions, local_actions]);
	var len1 = array_length(ar[0]);
	var len2 = array_length(ar[1]);
	var act_len = 0;
	var prev_invalid = invalid_action;
	var prev_stop = action_stop;
	if action_number >= max(len1, len2){
		obj_client.confirm_phase_endlocal = 1;
		var buff = obj_client.inbuf;
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_write(buff, buffer_u8, network.confirm_phase_done)
		if !global.is_steam_connection{ //when both sets of actions have finished running on one end the server will tell the other end that the actions ended on one side, when both animated actions end it goes to the next 
			network_send_packet(obj_client.client, buff, buffer_tell(buff));
		}else{
			steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
			
		}
	}
	
	if phase{
		var t1 = (action_number < len1? ar[0][action_number][2]*20: 0);
		var t2 = (action_number < len2? ar[1][action_number][2]*20: 0);
		act_len = t1 + t2;
		var pl = (action_timer >= min(t1, t2)*2? t1 < t2: action_timer%40 >= 20);
		t = action_timer%20;
		var len = (pl? len2: len1);
		var ar2 = (action_number < len? ar[pl][action_number]: -1);
		if ar2 != -1 && instance_exists(ar2[0]) var act_type = ar2[0].object_index = obj_troop;
		else invalid_action = pl+1;
		if invalid_action != pl+1 && action_stop != pl+1{
			if t = 0{
				tile_to = collision_point(ar2[0].x + dcos(ar2[3])*56, ar2[0].y - dsin(ar2[3])*56, tile, 1, 1);
				og_tile = ar2[0].tile_id;
				if tile_to.troop != noone{
					if ar2[0].is_tower && tile_to.troop.player = pl+1{
						tilehop = 0;
						while tile_to != noone && tile_to.troop != noone && tile_to.troop.player = pl+1{
							tilehop++;
							tile_to = collision_point(ar2[0].x + dcos(ar2[3])*56*tilehop, ar2[0].y - dsin(ar2[3])*56*tilehop, tile, 1, 1);
						}
						if tile_to = noone invalid_action = pl+1;
						else if !ar2[0].is_tower && tile_to.troop != noone && tile_to.troop.player != pl+1 && (!tile_to.troop.is_tower && angle_difference(tile_to.troop.image_angle, point_direction(tile_to.x, tile_to.y, ar2[0].x, ar2[0].y)) < 20 && !tile_to.red_tile) action_stop = pl+1;
					}else{
						if tile_to.troop.player = pl+1 action_stop = pl+1;
						else if (!ar2[0].is_tower && !tile_to.troop.is_tower && angle_difference(tile_to.troop.image_angle, point_direction(tile_to.x, tile_to.y, ar2[0].x, ar2[0].y)) < 20 && !tile_to.red_tile) action_stop = pl+1;
					}
				}
			}else{
				var trp = ar2[0];
				if t = 1 audio_play_sound((trp.is_tower && tilehop? tower_jump: troop_jump), 10, 0);
				trp.depth = (t = 19? 100: 30);
				trp.image_xscale = sign(trp.image_xscale)*(1 + clamp(dsin(t * 10), 0, 1));
				trp.image_yscale = sign(trp.image_yscale)*abs(trp.image_xscale);
				trp.x = lerp(og_tile.x, tile_to.x, clamp(t/17, 0, 1));
				trp.y = lerp(og_tile.y, tile_to.y, clamp(t/17, 0, 1));
				if t = 19{
					audio_play_sound(troop_land, 10, 0);
					if tile_to.troop != noone{
						audio_play_sound((tile_to.troop.is_tower? tower_die: troop_die), 10, 0);
						instance_destroy(tile_to.troop);
						with resource_troops if player = pl+1 troop_am++;
						action_stop = pl+1;
					}
					trp.tile_id.troop = noone;
					tile_to.troop = trp;
					trp.tile_id = tile_to;
					if trp.is_tower && tile_to.gold_tile{
						tile_to.gold_tile = 0;
						with resource_troops if player = pl+1 troop_am++;
					}
				}
			}
		}
		if invalid_action && !prev_invalid && ar2 != -1 audio_play_sound(troop_invalid, 10, 0);
		if action_stop && !prev_stop && ar2 != -1 audio_play_sound(troop_stopped, 10, 0);
	}else{
		act_len = 39;
		var pl = (action_timer >= 20);
		var t = action_timer%20;
		var len = (pl? len2: len1);
		var ar2 = (action_number < len? ar[pl][action_number]: -1);
		if ar2 != -1 && instance_exists(ar2[0]) var act_type = ar2[0].object_index = obj_troop;
		else invalid_action = pl+1;
		
		if invalid_action != pl+1{
			if act_type{
				if t = 0 && !instance_exists(ar2[0]) invalid_action = pl+1;
				else{
					if t = 1 audio_play_sound(troop_spin, 10, 0);
					if t = 0 og_angle = ar2[0].image_angle;
					ar2[0].image_angle = lerp(og_angle, ar2[1]*60, clamp(t/17, 0, 1));
					ar2[0].new_tileangle = 0;
				}
			}else{
				if t = 0{
					with obj_troop if is_tower && player = pl+1 other.createbase = self;
					
					if ar2[0].troop != noone && (!ar2[0].troop.is_tower && angle_difference(ar2[0].troop.image_angle, point_direction(ar2[0].x, ar2[0].y, createbase.x, createbase.y)) < 20 && !ar2[0].red_tile) invalid_action = pl+1;
					if invalid_action != pl+1{
						new_troop = instance_create_depth(createbase.x, createbase.y, createbase.depth-1, obj_troop);
						new_troop.image_angle = ar2[1]*60;
						new_troop.player = pl+1;
						new_troop.image_speed = 0;
						new_troop.image_index = pl;
						resource_troops.troop_am--;
					}
				}else{
					new_troop.x = lerp(createbase.x, ar2[0].x, clamp(t/17, 0, 1));
					new_troop.y = lerp(createbase.y, ar2[0].y, clamp(t/17, 0, 1));
					if t = 16{
						if ar2[0].troop != noone{
							audio_play_sound((ar2[0].troop.is_tower? tower_die: troop_die), 10, 0);
							instance_destroy(ar2[0].troop);
							with resource_troops if player = pl+1 troop_am++;
						}
						
						new_troop.tile_id = ar2[0];
						ar2[0].troop = new_troop;
					}
				}
			}
		}
		if invalid_action && !prev_invalid && ar2 != -1 audio_play_sound(troop_invalid, 10, 0);
	}
	action_timer++;
	if action_timer = act_len{
		action_timer = 0;
		invalid_action = 0;
		action_stop = 0;
		tilehop = 0;
		action_number++;
	}
}else{
	invalid_action = 0;
	action_timer = 0;
	action_number = 0;
}

if local_player != old_local_player {
	show_debug_message("NEW LOCAL PLAYER VALUE: {0}", local_player)
	old_local_player = local_player
}

if online_player != old_online_player {
	show_debug_message("NEW ONLINE PLAYER VALUE: {0}", online_player)
	old_online_player = online_player
}