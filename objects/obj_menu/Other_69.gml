show_debug_message("EVENT TRIGGERED: " + async_load[?"event_type"])
switch(async_load[?"event_type"]){
	case "lobby_join_requested":
	
	with obj_client instance_destroy();
	global.is_host = 0;
	var e = instance_create_depth(0, 0, 0, obj_client);
	room_goto(Game);
		
	var lobby_id = async_load[?"lobby_id"]
	var friend_id = async_load[?"friend_id"]
	steam_lobby_join_id(lobby_id)
	e.online_steamuid = steam_lobby_get_owner_id();
	break;
}