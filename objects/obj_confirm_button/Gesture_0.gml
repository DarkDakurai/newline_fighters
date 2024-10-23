if player != obj_console_game_handler.local_player exit;
if obj_console_game_handler.game_over exit;

if !tapped && !obj_console_game_handler.action_happening{
	audio_play_sound(menu_select, 10, 0);
	obj_console_game_handler.selected_troop = noone;
	obj_console_game_handler.action_timer = 0;
	obj_console_game_handler.arrived_data++;
	var buff = obj_client.inbuf;
	buffer_seek(buff, buffer_seek_start, 0);
	buffer_write(buff, buffer_u8, network.move_data)
	buffer_write(buff, buffer_string, obj_console_game_handler.action_string_list);
	if !global.is_steam_connection{ //this one trigger sends over the actions data which got already compiled to a string
		network_send_packet(obj_client.client, buff, buffer_tell(buff));
	}else{
		var g = steam_net_packet_send((global.is_host? obj_client.local_steamuid: obj_client.online_steamuid), buff, buffer_tell(buff), steam_net_packet_type_reliable, 10);
		show_debug_message(g? "local successful": "local unsucc")
	}
	
}
tapped = 1;