function state = display_go_nogo_cue(opts, data)

state = ptb.State();
state_name = 'display_go_nogo_cue';

state.Name = state_name;
state.Duration = opts.Value.TIMINGS.time_in.(state_name);

state.UserData = struct();

state.Entry = @(state) entry(state, opts, data);
state.Loop = @(state) loop(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

task = opts.Value.TASK;
window = opts.Value.WINDOW;
stimuli = opts.Value.STIMULI;
targets = opts.Value.TARGETS;

trial_data = data.Value.current_trial_data;

% Log entry time
gng.util.log_event_time( data, state.Name, elapsed(task) );

if ( trial_data.is_go )
  % Go cue
  draw( stimuli.go_cue, window );
  state.UserData.cue_target = targets.go_cue;
else
  % Nogo cue
  draw( stimuli.nogo_cue, window );
  state.UserData.cue_target = targets.nogo_cue;
end

flip( window );

gng.util.log_event_time( data, 'cue_onset', elapsed(task) );

% Reset broke_cue
state.UserData.broke_cue_fixation = false;
state.UserData.next_state_name = 'go_nogo';

end

function loop(state, opts, data)

cue_target = state.UserData.cue_target;

if ( ~cue_target.IsInBounds )
  state.UserData.broke_cue_fixation = true;
  state.UserData.next_state_name = 'error_broke_cue_fixation';
  escape( state );
  return
end

end

function exit(state, opts, data)

next_state_name = state.UserData.next_state_name;

states = opts.Value.STATES;
next( state, states(next_state_name) );

end