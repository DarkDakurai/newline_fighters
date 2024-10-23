function received_packet(){

if !global.is_steam_connection{ //this logic handles packets server side, same deal with the first piece of the packet being an id plugged in a switch
buffer = argument0; //the buffer of the server
socket = argument1; //the socket the packet is coming from
local_sock = ds_list_find_value(socket_list, 0); //the socket of the server side client
online_sock = ds_list_find_value(socket_list, 1); //the socket of the online client
msgid = buffer_read(buffer, buffer_u8);

switch msgid{	
	case network.move_data: //this one handles the reception of move data encoded as script, if it's coming from the local socket it will redirect it towards the online socket
	var dat = buffer_read(buffer, buffer_string);
	if socket != local_sock{
		obj_console_game_handler.online_string_list = dat;
		obj_console_game_handler.arrived_data++;
	}else{
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.move_data);
		buffer_write(server_buffer, buffer_string, dat);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	}
	break;
	
	case network.connection_found: //when a connection is foung in the connect_menu room it will go to the game room
	room_goto_next();
	break;
	
	case network.confirm_next_phase: //when both players submitted their action the animations are triggered and the message is sent to the online socket
	obj_console_game_handler.action_happening = 1;
	obj_console_game_handler.reformat_actions = 3;
	obj_console_game_handler.arrived_data = 0;
	obj_console_game_handler.timer = -1;
	buffer_seek(server_buffer, buffer_seek_start, 0);
	buffer_write(server_buffer, buffer_u8, network.confirm_next_phase);
	network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	break;
	
	case network.confirm_next_phase_override: //if one player fails to submit their moves in time this will trigger, if the message comes from the local socket then it's redirected to the online client which does the reset instead
	if socket != local_sock{
		obj_console_game_handler.action_happening = 1;
		obj_console_game_handler.reformat_actions = 3;
		obj_console_game_handler.arrived_data = 0;
		obj_console_game_handler.timer = -1;
		obj_console_game_handler.local_actions = [];
		obj_console_game_handler.reformat_actions = 1;
	}else{
		obj_console_game_handler.action_happening = 1;
		obj_console_game_handler.reformat_actions = 3;
		obj_console_game_handler.arrived_data = 0;
		obj_console_game_handler.timer = -1;
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.confirm_next_phase_override);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	}
	break;
	
	case network.confirm_phase_done: //when one end has finished displaying the move animations this will trigger, if the message comes from the local socket it's redirected to the online socket
	if socket != local_sock confirm_phase_endonline = 1;
	else{
		confirm_phase_endlocal = 1;
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.confirm_phase_done);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	}
	
	if confirm_phase_endlocal && confirm_phase_endonline{ //if both have completed their actions then the state of the game returns to an actionable one
		obj_console_game_handler.action_happening = 0;
		obj_console_game_handler.phase = !obj_console_game_handler.phase;
		with action_object instance_destroy();
		obj_console_game_handler.local_actions = [];
		obj_console_game_handler.online_actions = [];
		with obj_troop action_stored = 0;
		confirm_phase_endonline = 0;
		confirm_phase_endlocal = 0;
		obj_client.confirm_phase_endlocal = 1;
	}
	break;
	
	case network.rematch: //if any rematch order is sent this will trigger, it can also include a "quit" message for index 2, if it comes from the local socket it's redirected to the online socket
	var dat = buffer_read(buffer, buffer_u8);
	if socket != local_sock rematch_online = dat; 
	else{
		rematch_local = dat;
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.rematch);
		buffer_write(server_buffer, buffer_u8, dat);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	}
	
	if rematch_local = 2 || rematch_online = 2{ //if either player chose to quit then the game ends and both are brought back to the main menu
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.die);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
		room_goto(rm_main_menu);
		with all{
			instance_destroy(self);
			exit;
		}
	}
	
	if rematch_local = 1 && rematch_online = 1{ //if both players decide to rematch then the game is reset and they can play again
		rematch_local = 0;
		rematch_online = 0;
		confirm_phase_endlocal = 0;
		confirm_phase_endonline = 0;
		
		with all if object_index != obj_server && object_index != obj_client instance_destroy(self);
		
		room_restart();
		var e = instance_create_depth(0, 0, depth, obj_console_game_handler);
	
		randomise();
		var pl = round(random_range(1, 2));
		e.local_player = pl;
		e.online_player = (pl = 1? 2: 1);
		
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.connection_found);
		buffer_write(server_buffer, buffer_u8, (pl = 1? 2: 1));
		buffer_write(server_buffer, buffer_u8, 1);
		network_send_packet(online_sock, server_buffer, buffer_tell(server_buffer));
	}
	break;
}
}//TODO: Steam


/*
switch msgid{
	case network.phase_change:
	var move_x = buffer_read(buffer, buffer_u16);
	var move_y = buffer_read(buffer, buffer_u16);
	
	var _player = ds_map_find_value(socket_to_instanceid, socket);
	_player.x = move_x;
	_player.y = move_y;
	
	var i = 0;
	repeat ds_list_size(socket_list){
		var _sock = ds_list_find_value(socket_list, i);
		
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.phase_change);
		buffer_write(server_buffer, buffer_u8, socket);
		buffer_write(server_buffer, buffer_u16, move_x);
		buffer_write(server_buffer, buffer_u16, move_y);
		network_send_packet(_sock, server_buffer, buffer_tell(server_buffer));
		
		i++;
	}
	break;
	
	case network.move_data:
	
	break;
	
	case network.timer:
	
	break;
}
*/


}