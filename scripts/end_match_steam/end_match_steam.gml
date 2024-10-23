// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function end_match_steam(){
	show_debug_message("MATCH ENDED, CLEANING AND GOING TO THE MENU");
	steam_lobby_leave();
	room_goto(rm_main_menu);
	with all {
		if object_index == Obj_Steam {
			continue;
		}
		instance_destroy(self);
	}
}