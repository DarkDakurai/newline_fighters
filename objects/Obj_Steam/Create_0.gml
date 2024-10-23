/// @description Init global/steam
// You can write your code in this editor

is_game_restarting = false;
iam_steam = true;

if (steam_initialised()){ 
	steam_net_packet_set_type(steam_net_packet_type_reliable);
	room_goto(rm_main_menu);
}

handle = -1;