function state = fixation(opts, data)

state = ptb.State();

state.Name = 'fixation';
state.Duration = opts.Value.TIMINGS.time_in.fixation;

state.UserData = struct();

state.Entry = @(state) entry(state, opts, data);
state.Loop = @(state) loop(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

task = opts.Value.TASK;
window = opts.Value.WINDOW;
interface = opts.Value.INTERFACE;

fix_square_target = opts.Value.TARGETS.fix_square;
fix_square_stimulus = opts.Value.STIMULI.fix_square;

is_debug = interface.is_debug;

% Reset target
reset( fix_square_target );

% Reset acquired fixation
state.UserData.acquired_fixation = false;

% Log entry time
gng.util.log_event_time( data, state.Name, elapsed(task) );

% Draw stimuli + targets
draw( fix_square_stimulus, window );

if ( is_debug )
  draw( fix_square_target.Bounds, window );
end

flip( window );

gng.util.log_event_time( data, 'fixation_onset', elapsed(task) );

end

function loop(state, opts, data)

fix_square_target = opts.Value.TARGETS.fix_square;

if ( fix_square_target.IsDurationMet )
  state.UserData.acquired_fixation = true;
  escape( state );
end

end

function exit(state, opts, data)

states = opts.Value.STATES;

if ( state.UserData.acquired_fixation )
  next_state_name = opts.Value.STRUCTURE.post_fixation_state_name;
else
  next_state_name = 'end_trial';
end

next( state, states(next_state_name) );

end

