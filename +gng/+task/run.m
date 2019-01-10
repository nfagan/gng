function run(opts)

task = opts.Value.TASK;
states = opts.Value.STATES;

initial_state = states('new_trial');

run( task, initial_state );

end