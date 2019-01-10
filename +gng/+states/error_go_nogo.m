function state = error_go_nogo(opts, data)

state = ptb.State();
state.Name = 'error_go_nogo';

state.Duration = opts.Value.TIMINGS.time_in.error_go_nogo;

state.Entry = @(state) entry(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

window = opts.Value.WINDOW;
task = opts.Value.TASK;
stimuli = opts.Value.STIMULI;

gng.util.log_event_time( data, state.Name, elapsed(task) );

draw( stimuli.error_wrong_go_nogo, window );
flip( window );

gng.util.log_event_time( data, 'error_wrong_go_nogo_onset', elapsed(task) );

data.Value.current_trial_data.errors.wrong_go_nogo = true;

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('iti') );

end