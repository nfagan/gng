function state = go_nogo(opts, data)

state = ptb.State();
state_name = 'go_nogo';

state.Name = state_name;
state.Duration = opts.Value.TIMINGS.time_in.(state_name);

state.UserData = struct();

state.Entry = @(state) entry(state, opts, data);
state.Loop = @(state) loop(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

task = opts.Value.TASK;
interface = opts.Value.INTERFACE;
stimuli = opts.Value.STIMULI;
window = opts.Value.WINDOW;
targets = opts.Value.TARGETS;
trial_data = data.Value.current_trial_data;

is_go = trial_data.is_go;
target_direction = trial_data.target_direction;
is_debug = interface.is_debug;

% Log entry time
gng.util.log_event_time( data, state.Name, elapsed(task) );

go_stimulus = stimuli.go_target;
go_stimulus.FaceColor = trial_data.target_image;

cue_stimulus = ternary( is_go, stimuli.go_cue, stimuli.nogo_cue );

if ( trial_data.is_target_left )
  go_stimulus.Position = [1/3, 1/2];
else
  go_stimulus.Position = [2/3, 1/2];
end

draw( cue_stimulus, window );
draw( go_stimulus, window );

% Make trapezoid bounds
trap_bounds = make_trapezoid_bounds( window, cue_stimulus, target_direction );

if ( is_debug )
  draw( trap_bounds, window );
end

flip( window );

gng.util.log_event_time( data, 'go_target_onset', elapsed(task) );

% Reset targets
go_target = targets.go_target;
cue_target = ternary( is_go, targets.go_cue, targets.nogo_cue );
trap_target = targets.trapezoid;
trap_target.Bounds = trap_bounds;

reset( go_target );
reset( cue_target );
reset( trap_target );

% Log entry into target
go_target.Entry = ...
  @(targ) gng.util.log_event_time( data, 'go_target_acquired', elapsed(task) );

state.UserData.go_target = go_target;
state.UserData.trap_target = trap_target;
state.UserData.is_go = is_go;
state.UserData.outcome = 'nogo';

end

function loop(state, opts, data)

go_target = state.UserData.go_target;
trap_target = state.UserData.trap_target;
is_go = state.UserData.is_go;

if ( is_go )
  if ( go_target.IsDurationMet )
    state.UserData.outcome = 'go';
    escape( state );
    return
  end
else
  if ( trap_target.IsInBounds )
    state.UserData.outcome = 'go';
    escape( state );
    return
  end
end

end

function exit(state, opts, data)

is_go = state.UserData.is_go;
outcome = state.UserData.outcome;
next_state_name = 'error_go_nogo';

is_correct_go = is_go && strcmp( outcome, 'go' );
is_correct_nogo = ~is_go && strcmp( outcome, 'nogo' );

if ( is_correct_go || is_correct_nogo )
  next_state_name = 'reward';
end

data.Value.current_trial_data.trial_outcome = outcome;

states = opts.Value.STATES;
next( state, states(next_state_name) );

end

function bounds = make_trapezoid_bounds(window, cue, direction)

bounds = gng.bounds.Trapezoid( window, cue );
bounds.Direction = direction;

end