function log_event_time(data, name, time)

validateattributes( time, {'numeric'}, {'scalar'}, mfilename, 'time' );
validateattributes( data, {'ptb.Reference'}, {'scalar'}, mfilename, 'data' );

data.Value.current_trial_data.events.(name) = time;

end