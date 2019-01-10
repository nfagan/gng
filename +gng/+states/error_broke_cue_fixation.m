function state = error_broke_cue_fixation(opts, data)

state = ptb.State();
state.Name = 'error_broke_cue_fixation';

state.Duration = opts.Value.TIMINGS.time_in.error_broke_cue_fixation;

state.Entry = @(state) entry(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

window = opts.Value.WINDOW;
task = opts.Value.TASK;
stimuli = opts.Value.STIMULI;

gng.util.log_event_time( data, state.Name, elapsed(task) );

draw( stimuli.error_broke_cue_fixation, window );
flip( window );

gng.util.log_event_time( data, 'error_broke_cue_fixation_onset', elapsed(task) );

data.Value.current_trial_data.errors.broke_cue_fixation = true;

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('iti') );

end