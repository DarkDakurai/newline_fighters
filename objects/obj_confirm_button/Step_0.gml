visible = !obj_console_game_handler.action_happening && player == obj_console_game_handler.local_player;
image_index = tapped;
if obj_console_game_handler.action_happening tapped = 0;
if obj_console_game_handler.local_player != 0 && obj_console_game_handler.local_player != player instance_destroy();