show_debug_message("EVENT TRIGGERED: " + async_load[?"event_type"])
switch(async_load[?"event_type"])
{	
	case "lobby_created":
		show_debug_message("Lobby created: " + string(steam_lobby_get_lobby_id()))
		steam_lobby_join_id(steam_lobby_get_lobby_id())
	break
	
	case "lobby_joined":
		steam_uid = steam_get_user_steam_id();
		local_steamuid = steam_uid;
		ds_list_add(steam_uid_list, steam_uid);
		if(steam_lobby_is_owner())
		{
			steam_lobby_set_data("isGameMakerTest","true");
			steam_lobby_set_data("Creator",steam_get_persona_name());
			steam_lobby_activate_invite_overlay();
		}
	break
	
	case "lobby_join_requested":
	room_goto(Game);
	
	var lobby_id = async_load[?"lobby_id"]
	var friend_id = async_load[?"friend_id"]
	steam_lobby_join_id(lobby_id)
	online_steamuid = steam_lobby_get_owner_id();
	break
	
	case "lobby_chat_update":
		
		var _lobby_id = async_load[?"lobby_id"];
		if(_lobby_id != steam_lobby_get_lobby_id()) exit;
		var _change_flags = async_load[?"change_flags"];
		var _user_id = async_load[?"user_id"];
		online_steamuid = _user_id;
		
		if _change_flags & 1 { // if new connection on lobby
			show_debug_message(["New connection: ", _user_id]);
			
			steam_uid = _user_id;
			ds_list_add(steam_uid_list, steam_uid);
			
			randomise();
			var pl = round(random_range(1, 2));
			local_player = pl;
			online_player = (pl = 1? 2: 1);
			
			room_goto(Game);
	
			buffer_seek(inbuf, buffer_seek_start, 0); //this one packet tells the other player's end that the game can start, it also assigns it its respective player number
			buffer_write(inbuf, buffer_u8, network.connection_found);
			buffer_write(inbuf, buffer_u8, (pl = 1? 2: 1));
			buffer_write(inbuf, buffer_u8, 0);
			steam_net_packet_send(_user_id, inbuf, buffer_tell(inbuf), steam_net_packet_type_reliable, 10);
		}
		if _change_flags & 2 { // if disconnect on lobby
			end_match_steam()
			exit;
		}
		
		
	break
}







