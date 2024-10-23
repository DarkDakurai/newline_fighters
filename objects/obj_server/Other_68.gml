if !global.is_steam_connection{ //this is the networking logic of the server
type_event = ds_map_find_value(async_load, "type");

switch type_event{
	case network_type_connect: //this happens when a client connects, it happens for both the local spoofing client and the online client owned by player 2
	socket = ds_map_find_value(async_load, "socket");
	ds_list_add(socket_list, socket);
	
	if ds_list_size(socket_list) = 1 exit; //if only 1 client is connected stop here, otherwise the room generation happens and the game starts
	
	room_goto(Game);
	
	randomise();
	var pl = round(random_range(1, 2));
	obj_console_game_handler.local_player = pl;
	obj_console_game_handler.online_player = (pl = 1? 2: 1);
	
	buffer_seek(server_buffer, buffer_seek_start, 0); //this one packet tells the other player's end that the game can start, it also assigns it its respective player number
	buffer_write(server_buffer, buffer_u8, network.connection_found);
	buffer_write(server_buffer, buffer_u8, (pl = 1? 2: 1));
	buffer_write(server_buffer, buffer_u8, 0);
	network_send_packet(socket, server_buffer, buffer_tell(server_buffer));
	
	break;
	
	case network_type_disconnect: //this runs when any client disconnects, here I made it reset the game
	socket = ds_map_find_value(async_load, "socket");
	
	end_match_steam()
	break;
	
	case network_type_data: //this one triggers when data is recieved through packets
	buffer = ds_map_find_value(async_load, "buffer");
	socket = ds_map_find_value(async_load, "id");
	buffer_seek(buffer, buffer_seek_start, 0);
	if ds_list_find_index(socket_list, socket)+1 received_packet(buffer, socket); //this function handles packet logic, it's not triggered if the packet comes from the server itself to prevent recursion between the local client and server
	break;
}
}//TODO: Steam


/* old networking code
var event_id = async_load[? "id"];

if server = event_id{
	var type = async_load[? "type"];
	var sock = async_load[? "socket"];
	
	//connect
	if type = network_type_connect{
		
		//define players on one side
		ds_list_add(socket, sock);

		randomize()
		if console_game_handler.local_player = 0{
			p1_pl = round(random_range(1, 2));
			console_game_handler.local_player = p1_pl;
		}
		ds_map_add(clients, sock, 0);
		
		//send info to the other end
		if console_game_handler.local_player != 0 send_data_back(sock, PACKET_PLAYER, (console_game_handler.local_player = 1? 2: 1), buffer_u8);
		
	}
	
	
	//disconnect
	if type = network_type_disconnect{
		var p = clients[? sock];
		ds_list_delete(sockets, ds_list_find_index(sockets, sock));
		ds_map_delete(clients, sock);
	}
	
	if type = network_type_data{
		buffer_seek(buff, buffer_seek_start, 0);
		var cmd = buffer_read(buff, buffer_u8);
		
		var p = clients[? "sock"];
		switch cmd{
			case PACKET_MOVES:
			var k = buffer_read(buff, buffer_string);
			send_data_back(sock, PACKET_MOVES, console_game_handler.action_string_list, buffer_u8);
			show_debug_message(buffer_string);
			break;
		}
	}
}else if event_id != global.socket {
	var sock = async_load[? "id"];
	var buff = async_load[? "buffer"];
	
	buffer_seek(buff, buffer_seek_start, 0);
	var cmd = buffer_read(buff, buffer_u8);
	
	var p = clients[? "sock"];
	switch cmd{
		case PACKET_MOVES:
		var k = buffer_read(buff, buffer_string);
		console_game_handler.online_string_list = k;
		break;
	}
}
*/