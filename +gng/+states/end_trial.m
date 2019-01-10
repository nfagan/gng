function state = end_trial(opts, data)

state = ptb.State();
state.Name = 'end_trial';

state.Duration = 0;

state.Exit = @(state) exit(state, opts, data);

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('new_trial') );

trial_number = data.Value.trial_number;
data.Value.DATA(trial_number) = data.Value.current_trial_data;
data.Value.trial_number = trial_number + 1;

end