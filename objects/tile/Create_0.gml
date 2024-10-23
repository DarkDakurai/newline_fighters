maptilex = floor((x - 365)/56);
maptiley = floor((y - 177)/48);

map_val = string(maptilex) + chr(65 + maptiley);

gold_tile = !image_yscale;
red_tile = !image_xscale;

visible = gold_tile;
c1 = make_color_rgb(191, 161, 89);
c2 = make_color_rgb(88, 80, 73);
c3 = make_color_rgb(69, 86, 89);

troop = noone;