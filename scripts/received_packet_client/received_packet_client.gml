function received_packet_client(){


if !global.is_steam_connection{ //this function handles the packet logic client side, the first piece of the packet is an id that is plugged in a switch to allow for different behaviours
buffer = argument0;
msgid = buffer_read(buffer, buffer_u8);

switch msgid{
	case network.move_data: //this case recieves the opponent move data in string form and plugs it into the game handler object
	var dat = buffer_read(buffer, buffer_string);
	obj_console_game_handler.online_string_list = dat;
	obj_console_game_handler.arrived_data++;
	break;	
	
	case network.connection_found: //this case triggers when the server establishes a connection, it initialises the game, it can also trigger if the game needs to be reset, essentially re-initialising it
	var p = buffer_read(buffer, buffer_u8);
	var reset_game = buffer_read(buffer, buffer_u8);
	if reset_game{
		rematch_local = 0;
		rematch_online = 0;
		confirm_phase_endlocal = 0;
		confirm_phase_endonline = 0;
		
		with all if object_index != obj_server && object_index != obj_client instance_destroy(self);
		
		room_restart();
		var e = instance_create_depth(0, 0, depth, obj_console_game_handler);
		
		e.local_player = p;
		e.online_player = (p = 1? 2: 1);
	}else{
		room_goto_next();
		var e = instance_create_depth(0, 0, depth, obj_console_game_handler);
		e.local_player = p;
		e.online_player = (p = 1? 2: 1);
	}
	break;
	
	case network.confirm_next_phase: //this one case happens when both players submit their moves, the moves animation will begin to run
	obj_console_game_handler.action_happening = 1;
	obj_console_game_handler.reformat_actions = 3;
	obj_console_game_handler.arrived_data = 0;
	obj_console_game_handler.timer = -1;
	break;
	
	case network.confirm_next_phase_override: //this case happens if the timer runs out before a move is submitted, it will reset most stuff in the game handler essentially running the moves animation without one player
	obj_console_game_handler.action_happening = 1;
	obj_console_game_handler.reformat_actions = 3;
	obj_console_game_handler.arrived_data = 0;
	obj_console_game_handler.timer = -1;
	obj_console_game_handler.local_actions = [];
	obj_console_game_handler.reformat_actions = 1;
	break;
	
	case network.confirm_phase_done: //this one case triggers when the server side has finished displaying the move animations
	confirm_phase_endonline = 1;
	break;
	
	case network.die: //this flag is an emergency shutdown of the game, essentially kills the game room and forces it to go back to the main menu
	room_goto(rm_main_menu);
	with all{
		instance_destroy(self);
		exit;
	}
	break;
}
}//TODO: Steam

/*
switch msgid{
	case network.phase_change:
	var _sock = buffer_read(buffer, buffer_u8);
	var move_x = buffer_read(buffer, buffer_u16);
	var move_y = buffer_read(buffer, buffer_u16);
	
	_player = ds_map_find_value(socket_to_instanceid, _sock);
	
	_player.x = move_x;
	_player.y = move_y;
	break;
	
	case network.move_data:
	var _socket = buffer_read(buffer, buffer_u8);
	var _x = buffer_read(buffer, buffer_u16);
	var _y = buffer_read(buffer, buffer_u16);
	
	var _player = instance_create_depth(_x, _y, depth, plr);
	_player.socket = _socket;
	show_message(_socket)
	ds_map_add(socket_to_instanceid, _socket, _player);
	break;
	
	case network.timer:
	var _socket = buffer_read(buffer, buffer_u8);
	var _x = buffer_read(buffer, buffer_u16);
	var _y = buffer_read(buffer, buffer_u16);
	
	var _slave = instance_create_depth(_x, _y, depth, slv);
	_slave.socket = _socket;
	show_message(_socket)
	ds_map_add(socket_to_instanceid, _socket, _slave);
	break;
}*/


}