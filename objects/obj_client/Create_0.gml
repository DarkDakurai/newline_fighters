enum network{
	phase_change,
	move_data,
	timer,
	connection_found,
	confirm_next_phase,
	confirm_next_phase_override,
	confirm_phase_done,
	rematch,
	die
}
confirm_phase_endlocal = 0;
confirm_phase_endonline = 0;

rematch_local = 0;
rematch_online = 0;

inbuf = buffer_create(1024, buffer_grow, 1);
outbuf = buffer_create(1024, buffer_grow, 1);

local_player = 0;
online_player = 0;

if !global.is_steam_connection{ //the base socket setup on the client side, currently set up to function on local host
client = network_create_socket(network_socket_tcp);
connected = network_connect(client, "127.0.0.1", PORT);
disabled_networking = 0;

socket_to_instanceid = ds_map_create();
}else{
	steam_uid_list = ds_list_create();
	steam_uid_to_instanceid = ds_map_create();
	local_steamuid = 0;
	online_steamuid = 0;
	
	if global.is_host steam_lobby_create(steam_lobby_type_private, 2);
}



/* old networking code
socket = network_create_socket(network_socket_tcp);
global.socket = socket;

buffer = buffer_create(16384, buffer_grow, 1);
connect = network_connect(socket, "127.0.0.1", PORT);

send_move_dat = 0;

#macro PACKET_MOVES 0
#macro PACKET_TIMER 1
#macro PACKET_PLAYER 2
*/