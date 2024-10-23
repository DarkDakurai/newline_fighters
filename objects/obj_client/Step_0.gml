if confirm_phase_endlocal && !obj_console_game_handler.action_happening confirm_phase_endlocal = 0;

if !global.is_host && confirm_phase_endlocal && confirm_phase_endonline{
	confirm_phase_endonline = 0;
	confirm_phase_endlocal = 0;
	with action_object instance_destroy();
	with obj_troop action_stored = 0;
	obj_console_game_handler.local_actions = [];
	obj_console_game_handler.online_actions = [];
	obj_console_game_handler.action_happening = 0;
	obj_console_game_handler.phase = !obj_console_game_handler.phase;
}
if online_steamuid == 0 online_steamuid = steam_lobby_get_owner_id();
while(steam_net_packet_receive(10)){
	var sender = steam_net_packet_get_sender_id();
	if sender != steam_get_user_steam_id() show_debug_message("DIFF")
	if sender == steam_get_user_steam_id() show_debug_message("SAM")
	buffer_seek(inbuf, buffer_seek_start, 0);
	steam_net_packet_get_data(inbuf);
	if global.is_host received_packet_steam(inbuf, sender);
	else if sender != steam_get_user_steam_id() received_packet_steam_client(inbuf);
	
}