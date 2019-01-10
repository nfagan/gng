function state = iti(opts, data)

state = ptb.State();
state.Name = 'iti';

state.Duration = opts.Value.TIMINGS.time_in.reward;

state.Entry = @(state) entry(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

task = opts.Value.TASK;
window = opts.Value.WINDOW;

gng.util.log_event_time( data, state.Name, elapsed(task) );

flip( window );

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('end_trial') );

end

