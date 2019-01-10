conf = gng.config.default();

conf.STRUCTURE.max_n_images = 3;
conf.STRUCTURE.p_go = 0.5;
conf.STRUCTURE.p_target_left = 0.5;

conf.TIMINGS.time_in.go_nogo = 2;

conf.INTERFACE.is_debug = true;
conf.INTERFACE.should_save = true;

conf.SCREEN.should_open_window = true;

gng.task.start( conf );