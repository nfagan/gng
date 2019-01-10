function state = reward(opts, data)

state = ptb.State();
state.Name = 'reward';

state.Duration = opts.Value.TIMINGS.time_in.reward;

state.Entry = @(state) entry(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

window = opts.Value.WINDOW;
task = opts.Value.TASK;
stimuli = opts.Value.STIMULI;

gng.util.log_event_time( data, state.Name, elapsed(task) );

draw( stimuli.reward_feedback, window );
flip( window );

gng.util.log_event_time( data, 'reward_cue_onset', elapsed(task) );

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('iti') );

end