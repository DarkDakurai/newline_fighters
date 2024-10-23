if dragging{
	with tile if array_contains(other.selected_tiles, id){
		if other.near_tile = self draw_sprite_ext(spr_tile_highlight, 0, x, y, 1, 1, 0, c_lime, 1);
		else draw_sprite_ext(spr_tile_highlight, 0, x, y, 1, 1, 0, (troop != noone? (troop.player = other.player? c_aqua: c_fuchsia): c_white), 1);
	}
	draw_self();
}

if obj_console_game_handler.selected_troop = self{
	draw_sprite_ext(spr_tile_highlight, 0, x, y, 1, 1, 0, c_lime, 1);
	if is_tower with tile if array_contains(other.selected_tiles, id){
		if other.near_tile = id{
			draw_sprite_ext(spr_troop, other.player-1, x, y, 1, 1, (other.new_tileangle + 3*(obj_console_game_handler.local_player = 2))*60, c_white, 1);
			draw_sprite_ext(spr_tile_highlight, 0, x, y, 1, 1, 0, (troop != noone? c_red: c_lime), 1);
		}
		else draw_sprite_ext(spr_tile_highlight, 0, x, y, 1, 1, 0, (troop != noone? (troop.player = other.player? c_aqua: c_fuchsia): c_white), 1);
	}
}