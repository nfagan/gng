function state = new_trial(opts, data)

state = ptb.State();
state.Name = 'new_trial';

state.Duration = 0;
% Handle special setup on first entering the state.
state.UserData = struct( 'is_first_entry', true );

state.Entry = @(state) entry(state, opts, data);
state.Exit = @(state) exit(state, opts, data);

end

function entry(state, opts, data)

% This is the very first trial
if ( state.UserData.is_first_entry )
  data.Value.trial_number = 1;
  state.UserData.is_first_entry = false;
end

data.Value.current_trial_data = make_current_trial_data( opts );

end

function exit(state, opts, data)

states = opts.Value.STATES;
next( state, states('fixation') );

end

function trial_data = make_current_trial_data(opts)

structure = opts.Value.STRUCTURE;
image_info = opts.Value.IMAGES;

trial_data = struct();
trial_data.events = struct();
trial_data.errors = get_default_errors();

% Determine go or nogo trial
is_go = rand() < structure.p_go;

if ( is_go )
  trial_data.trial_type = 'go';
else
  trial_data.trial_type = 'nogo';
end

% Determine whether target is on left or right
is_target_left = rand() < structure.p_target_left;

if ( is_target_left )
  trial_data.target_direction = 'left';
else
  trial_data.target_direction = 'right';
end

trial_data.is_go = is_go;
trial_data.is_target_left = is_target_left;

% Determine type of target (social vs. nonsocial)
target_type = 'social';

% Determine image category of target (threat, neutral, ...)
target_categories = image_info.target_image_categories;
target_category = get_target_image_category( target_categories );

% Determine image-to-be-shown
target_images = image_info.images.targets;

[target_image, target_image_filename] = ...
  get_target_image( target_images, target_type, target_category );

trial_data.target_category = target_category;
trial_data.target_type = target_type;
trial_data.target_image_filename = target_image_filename;
trial_data.target_image = target_image;

% Empty trial outcome ty default
trial_data.trial_outcome = '';

end

function errs = get_default_errors()

errs = struct();
errs.wrong_go_nogo = false;
errs.broke_cue_fixation = false;

end

function c = get_target_image_category(categories)

if ( isempty(categories) )
  warning( 'No social image categories specified.' );
  c = '';
  return
end

inds = randperm( numel(categories) );
c = categories{inds(1)};

end

function [image, filename] = get_target_image(images, target_type, target_category)

current_images = images.(target_type).(target_category);

I = randi( numel(current_images.objects) );

image = current_images.objects{I};
filename = current_images.filenames{I};

end