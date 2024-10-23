phase = 0;

action_happening = 0;
action_number = 0;
action_timer = 0;
infra_action_timer = 0;
invalid_action = 0;
action_stop = 0;
og_angle = 0;
createbase = noone;
new_troop = noone;
act_type = -1;
tile_to = noone;
og_tile = noone;
tilehop = 0;

local_player = 0;
online_player = 0;
phase_draw = 0;
p1_tower = noone;
p2_tower = noone;
init_towers = 1;
game_over = 0;
game_over_timer = 0;
menu_option = 0;
selected_menu = 1;

p1_win = 0;
p2_win = 0;

local_actions = [];
online_actions = [];
// [piece id, tile id to move to, space amounts, dir]
// [piece id, angle]
// [tile id to spawn to, tile angle]
prev_len = 0;
reformat_actions = 0;
arrived_data = 0;
timer = -1;
button = noone;

action_string_list = "";
online_string_list = "";

col = make_color_rgb(255, 172, 0);

//mouse input
lmb_down = 0;
rmb_down = 0
lmb_pressed = 0;
rmb_pressed = 0;
lmb_down_old = 0;
rmb_down_old = 0;

//selected rotation troop
selected_troop = noone;

old_local_player = 0;
old_online_player = 0;