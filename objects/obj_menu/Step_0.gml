var confirm = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
var back =  keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_escape);

if menu_level{
	if back{
		audio_play_sound(menu_cancel, 10, 0);
		menu_level = 0;
	}
	
	if menu_level = 1 && (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right)){
		menu_opt2 = !menu_opt2;
		audio_play_sound(menu_scroll, 10, 0);
	}
	
	if menu_level = 1 && menu_opt2 && confirm{
		room_goto(connect_menu);
		global.is_host = 1;
		instance_create_depth(0, 0, 0, obj_client);
	}
}else{
	var pre_opt = menu_opt;
	menu_opt += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
	if menu_opt != pre_opt audio_play_sound(menu_scroll, 10, 0);
	menu_opt = clamp(menu_opt, 0, 2);
	
	if confirm switch menu_opt{
		case 0: //create
		audio_play_sound(menu_select, 10, 0);
		menu_level = 1;
		menu_opt2 = 0;
		break;
		case 1: //join
		menu_level = 2;
		menu_opt2 = 0;
		audio_play_sound(menu_select, 10, 0);
		break;
		case 2:
		game_end();
		break;
	}
}
