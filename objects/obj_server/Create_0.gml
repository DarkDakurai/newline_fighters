//default server stuff
server_buffer = buffer_create(1024, buffer_grow, 1);
inbuf = buffer_create(1024, buffer_grow, 1);
if !global.is_steam_connection{ //the basic network set up server side
#macro PORT 41234
#macro MAX_CLIENTS 2

network_create_server(network_socket_tcp, PORT, MAX_CLIENTS);

socket_list = ds_list_create();

socket_to_instanceid = ds_map_create();
}else{
	

	steam_uid_list = ds_list_create();
	steam_uid_to_instanceid = ds_map_create();
	
	steam_lobby_create(steam_lobby_type_private, 2);
}

/* old networking code
#macro PORT 41234
#macro MAX_CLIENTS 2

server = network_create_server(network_socket_tcp, PORT, MAX_CLIENTS);
buffer = buffer_create(1024, buffer_grow, 1);

clients = ds_map_create();
socket = ds_list_create()

p1_pl = 0;
*/

confirm_phase_endlocal = 0;
confirm_phase_endonline = 0;

rematch_local = 0;
rematch_online = 0;
