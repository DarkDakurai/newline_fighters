if prev_phase != obj_console_game_handler.phase{
	phase_transition = 60;
	audio_play_sound(sfx_coin_flip, 10, 0);
	prev_phase = obj_console_game_handler.phase;
}

if phase_transition{
	phase_transition--;
	if phase_transition = 2 audio_play_sound(sfx_coin_land, 10, 0);
	image_yscale = 1 + dsin(phase_transition*3)*.5;
	image_xscale = abs(dcos(phase_transition*3))*image_yscale;
	if phase_transition = 30 image_index++;
}