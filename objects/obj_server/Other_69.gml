
switch(async_load[?"event_type"])
{	
	case "lobby_created":
		
		show_debug_message("Lobby created: " + string(steam_lobby_get_lobby_id()))
		steam_lobby_join_id(steam_lobby_get_lobby_id())
		
	break
	
	case "lobby_joined":
	
		if(steam_lobby_is_owner())
		{
			steam_lobby_set_data("isGameMakerTest","true");
			steam_lobby_set_data("Creator",steam_get_persona_name());
			steam_lobby_activate_invite_overlay();
		}
		
		steam_uid = steam_get_user_steam_id();
		ds_list_add(steam_uid_list, steam_uid);
	
		if ds_list_size(steam_uid_list) = 1 exit; //if only 1 client is connected stop here, otherwise the room generation happens and the game starts
	
		room_goto(Game);
		var e = instance_create_depth(0, 0, depth, obj_console_game_handler);
	
		randomise();
		var pl = round(random_range(1, 2));
		e.local_player = pl;
		e.online_player = (pl = 1? 2: 1);
	
		buffer_seek(outbuf, buffer_seek_start, 0); //this one packet tells the other player's end that the game can start, it also assigns it its respective player number
		buffer_write(outbuf, buffer_u8, network.connection_found);
		buffer_write(outbuf, buffer_u8, (pl = 1? 2: 1));
		buffer_write(outbuf, buffer_u8, 0);
		steam_net_packet_send(steam_uid, outbuf, buffer_tell(outbuf));
		
	break
	
	case "lobby_join_requested":
		
		var lobby_id = async_load[?"lobby_id"]
		var friend_id = async_load[?"friend_id"]
		steam_lobby_join_id(lobby_id)
		
	break
	
	case "lobby_chat_update":
		
		var _lobby_id = async_load[?"lobby_id"];
		if(_lobby_id != steam_lobby_get_lobby_id()) exit;
		var _change_flags = async_load[?"change_flags"];
		var _user_id = async_load[?"user_id"];
		
		if _change_flags & 1 { // if new connection on lobby
			show_debug_message(["New connection: ", _user_id]);
			
			steam_uid = steam_get_user_steam_id();
			ds_list_add(steam_uid_list, steam_uid);
	
			if ds_list_size(steam_uid_list) = 1 exit; //if only 1 client is connected stop here, otherwise the room generation happens and the game starts
	
			room_goto(Game);
			var e = instance_create_depth(0, 0, depth, obj_console_game_handler);
	
			randomise();
			var pl = round(random_range(1, 2));
			e.local_player = pl;
			e.online_player = (pl = 1? 2: 1);
	
			buffer_seek(outbuf, buffer_seek_start, 0); //this one packet tells the other player's end that the game can start, it also assigns it its respective player number
			buffer_write(outbuf, buffer_u8, network.connection_found);
			buffer_write(outbuf, buffer_u8, (pl = 1? 2: 1));
			buffer_write(outbuf, buffer_u8, 0);
			steam_net_packet_send(steam_uid, outbuf, buffer_tell(outbuf));
		}
		if _change_flags & 2 { // if disconnect on lobby
			socket = ds_map_find_value(async_load, "socket");
			end_match_steam()
			exit;
		}
		
		
	break
}







