// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function received_packet_steam(){

buffer = argument0
sender_uid = argument1
var from_host = sender_uid == steam_lobby_get_owner_id();

msgid = buffer_read(buffer, buffer_u8);
show_debug_message(["SERVER: with message id = ", msgid, ", local steamuid = ", local_steamuid, ", online steamid = ", online_steamuid])

switch msgid{	
	case network.move_data: //this one handles the reception of move data encoded as script, if it's coming from the local socket it will redirect it towards the online socket
	var dat = buffer_read(buffer, buffer_string);
	if !from_host{
		obj_console_game_handler.online_string_list = dat;
		obj_console_game_handler.arrived_data++;
	}else{
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.move_data);
		buffer_write(outbuf, buffer_string, dat);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10, steam_net_packet_type_reliable, 10);
	}
	break;
	
	case network.connection_found: //when a connection is foung in the connect_menu room it will go to the game room
	room_goto(Game);
	break;
	
	case network.confirm_next_phase: //when both players submitted their action the animations are triggered and the message is sent to the online socket
	obj_console_game_handler.action_happening = 1;
	obj_console_game_handler.reformat_actions = 3;
	obj_console_game_handler.arrived_data = 0;
	obj_console_game_handler.timer = -1;
	buffer_seek(outbuf, buffer_seek_start, 0);
	buffer_write(outbuf, buffer_u8, network.confirm_next_phase);
	steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
	break;
	
	case network.confirm_next_phase_override: //if one player fails to submit their moves in time this will trigger, if the message comes from the local socket then it's redirected to the online client which does the reset instead
	if !from_host{
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
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.confirm_next_phase_override);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
	}
	break;
	
	case network.confirm_phase_done: //when one end has finished displaying the move animations this will trigger, if the message comes from the local socket it's redirected to the online socket
	if !from_host confirm_phase_endonline = 1;
	else{
		confirm_phase_endlocal = 1;
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.confirm_phase_done);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
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
	if !from_host rematch_online = dat; 
	else{
		show_debug_message("FROM HOST, rematch? {0}", dat);
		rematch_local = dat;
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.rematch);
		buffer_write(outbuf, buffer_u8, dat);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
		
	}
	
	if rematch_local = 2 || rematch_online = 2{ //if either player chose to quit then the game ends and both are brought back to the main menu
		show_debug_message("YEAH IM OUT local: {0} online: {1}", rematch_local, rematch_online);
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.die);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
		end_match_steam()
		exit;
	}
	
	if rematch_local = 1 && rematch_online = 1{ //if both players decide to rematch then the game is reset and they can play again
		
		show_debug_message("WE ARE REMATCHING, REMATCHING I SAY")
		rematch_local = 0;
		rematch_online = 0;
		confirm_phase_endlocal = 0;
		confirm_phase_endonline = 0;
		
		with all if object_index != obj_server && object_index != obj_client && object_index != Obj_Steam instance_destroy(self);
		
		room_restart();
		
		randomise();
		var pl = round(random_range(1, 2));
		local_player = pl;
		online_player = (pl = 1? 2: 1);
		
		buffer_seek(outbuf, buffer_seek_start, 0);
		buffer_write(outbuf, buffer_u8, network.connection_found);
		buffer_write(outbuf, buffer_u8, (pl = 1? 2: 1));
		buffer_write(outbuf, buffer_u8, 1);
		steam_net_packet_send(online_steamuid, outbuf, buffer_tell(outbuf), steam_net_packet_type_reliable, 10);
		show_debug_message("REMATCH PACKET SENT WITH THE PLAYER {0}", pl);
	}
	break;
}
}