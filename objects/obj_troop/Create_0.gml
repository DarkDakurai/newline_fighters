player = 1 + (x > room_width*.5);
is_tower = image_index > 1;

//mouse inputs
lmb_down = 0;
rmb_down = 0
lmb_pressed = 0;
rmb_pressed = 0;

dragging = 0;
draggable = 0;
action_stored = 0;

tile_id = noone
if !collision_point(x, y, obj_troop, 1, 1){
	tile_id = collision_point(x, y, tile, 1, 1);
	tile_id.troop = self;
}

selected_tiles = [];
near_tile = noone;
new_tileangle = 0;
prev_sel = 0;

resource_obj = noone;
if is_tower with resource_troops if player = other.player other.resource_obj = id;