// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function received_packet_steam_client(){

buffer = argument0
msgid = buffer_read(buffer, buffer_u8);
show_debug_message(["CLIENT: with message id = ", msgid, ", local steamuid = ", local_steamuid, ", online steamid = ", online_steamuid])

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
		
		with all if object_index != obj_server && object_index != obj_client && object_index != Obj_Steam instance_destroy(self);
		
		room_restart();
		
		local_player = p;
		online_player = (p = 1? 2: 1);
	}else{
		local_player = p;
		online_player = (p = 1? 2: 1);
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
	end_match_steam();
	break;
}
}