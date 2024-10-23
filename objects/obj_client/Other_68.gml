if !global.is_steam_connection{ //this is the data reception logic on the client side, if the client is the host client then this logic is practically disabled

type_event = ds_map_find_value(async_load, "type");

switch type_event{
	case network_type_data:
	if global.is_host break;
	buffer = ds_map_find_value(async_load, "buffer");
	buffer_seek(buffer, buffer_seek_start, 0);
	received_packet_client(buffer);
	break;
}
}//TODO: Steam







/* old networking code
var event_id = async_load[? "id"];

if socket = event_id{
	var buff = async_load[? "buffer"];
	buffer_seek(buff, buffer_seek_start, 0);
	
	var cmd = buffer_read(buff, buffer_u8);
	
	switch cmd{
		case PACKET_PLAYER:
		var k = buffer_read(buff, buffer_u8);
		console_game_handler.local_player = k;
		break;
	}
}
*/