function [opts, data] = setup(conf)

if ( nargin < 1 || isempty(conf) )
  conf = gng.config.load();
else
  gng.util.assertions.assert__is_config( conf );
end

conf = gng.config.reconcile( conf );

opts = ptb.Reference( conf );
data = ptb.Reference( struct() );

date_dir = get_data_date_folder();

make_opts( opts, date_dir );
make_data( opts, data, date_dir );

make_task( opts );
make_states( opts, data );

make_component_updater( opts );

make_sources( opts );
make_windows( opts );

make_stimuli_and_targets( opts );
make_images( opts );

make_structure( opts );

end

function make_component_updater(opts)

opts.Value.COMPONENT_UPDATER = ptb.ComponentUpdater();

end

function make_structure(opts)

structure = opts.Value.STRUCTURE;

if ( structure.use_reward_cue )
  error( 'Reward cue not yet implemented!' );
else
  structure.post_fixation_state_name = 'display_go_nogo_cue';
end

opts.Value.STRUCTURE = structure;

end

function make_sources(opts)

if ( opts.Value.INTERFACE.use_mouse )
  source = ptb.sources.Mouse();
else
  source = ptb.EyelinkSource();
end

sampler = ptb.samplers.Pass( source );
updater = opts.Value.COMPONENT_UPDATER;

add_components( updater, source, sampler );

opts.Value.XY_SAMPLER = sampler;

end

function make_opts(opts, folder_name)

if ( opts.Value.INTERFACE.should_save )
  opts.Destruct = @(opts) save_data( opts.Value, folder_name, 'options' );
end

end

function make_data(opts, data, folder_name)

if ( opts.Value.INTERFACE.should_save )
  data.Destruct = @(data) save_data( data.Value.DATA, folder_name, 'data' );
end

end

function make_task(opts)

task = ptb.Task();

task.Duration = Inf;
exit_on_key_down( task );

task.Loop = @(task) task_loop( task, opts );

opts.Value.TASK = task;

end

function task_loop(task, opts)

update( opts.Value.COMPONENT_UPDATER );

end

function make_windows(opts)

screen = opts.Value.SCREEN;

display_window = ptb.Window();

display_window.Index = screen.index;
display_window.Rect = screen.rect;
display_window.BackgroundColor = screen.background_color;

if ( screen.should_open_window )
  open( display_window );
end

opts.Value.WINDOW = display_window;

end

function make_states(opts, data)

import gng.states.*;
import shared_utils.general.map_fun;

states = containers.Map();

states('new_trial') =                 new_trial( opts, data );
states('fixation') =                  fixation( opts, data );
states('display_go_nogo_cue') =       display_go_nogo_cue( opts, data );
states('go_nogo') =                   go_nogo( opts, data );
states('error_broke_cue_fixation') =  error_broke_cue_fixation( opts, data );
states('error_go_nogo') =             error_go_nogo( opts, data );
states('reward') =                    reward( opts, data );
states('iti') =                       iti( opts, data );
states('end_trial') =                 end_trial( opts, data );

if ( opts.Value.INTERFACE.is_debug )
  % Enable logging of state entry and exit times.
  map_fun( @(x) set_logging(x, true), states );
end

opts.Value.STATES = states;

end

function make_stimuli_and_targets(opts)

window = opts.Value.WINDOW;
sampler = opts.Value.XY_SAMPLER;
updater = opts.Value.COMPONENT_UPDATER;

stim_setup = opts.Value.STIMULI.setup;

stim_names = fieldnames( stim_setup );

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  stim_schema = stim_setup.(stim_name);
  
  color = set( ptb.Color(), stim_schema.color );
  
  pos = ptb.Transform( stim_schema.position );
  
  if ( stim_schema.normalize_position )
    pos.Units = 'norm';
  end
  
  scl = ptb.Transform( stim_schema.size );
  
  if ( stim_schema.normalize_size )
    scl.Units = 'norm';
  end
  
  stimulus = ptb.stimuli.Rect();
  stimulus.Position = pos;
  stimulus.Scale = scl;
  stimulus.FaceColor = color;
  stimulus.Window = window;
  
  has_target = shared_utils.struct.field_or( stim_schema, 'has_target', false );
  
  % make target
  if ( has_target )
    bounds = ptb.bounds.Rect( ptb.rects.MatchRectangle(stimulus) );
    
    bounds.Padding = stim_schema.target_padding;
    
    target = ptb.XYTarget( sampler, bounds );
    target.Duration = stim_schema.target_duration;
    
    opts.Value.TARGETS.(stim_name) = target;
    add_component( updater, target );
  end
  
  opts.Value.STIMULI.(stim_name) = stimulus; 
end

% Add trapezoid target
trapezoid_target = ptb.XYTarget( sampler );
add_component( updater, trapezoid_target );
opts.Value.TARGETS.trapezoid = trapezoid_target;

position_indicator = ptb.stimuli.Rect();
position_indicator.FaceColor = [255, 255, 255];
position_indicator.Window = window;

opts.Value.STIMULI.position_indicator = position_indicator;

end

function make_images(opts)

window = opts.Value.WINDOW;
structure = opts.Value.STRUCTURE;

stim_p =      fullfile( gng.util.get_project_folder(), 'stimuli' );
targets_p =   fullfile( stim_p, 'targets' );
social_p =    fullfile( targets_p, 'social' );
nonsocial_p = fullfile( targets_p, 'nonsocial' );

images = struct();

img_exts = { '.png', '.jpg', '.jpeg', '.JPG' };
max_n_images = structure.max_n_images;
image_categories = shared_utils.io.dirnames( social_p, 'folders' );

fprintf( '\n Loading images ...' );

for i = 1:numel(image_categories)
  c = image_categories{i};
  
  soc_images = get_images( window, fullfile(social_p, c), img_exts, max_n_images );
  nonsoc_images = get_images( window, fullfile(nonsocial_p, c), img_exts, max_n_images );
  
  images.targets.social.(c) = soc_images;
  images.targets.nonsocial.(c) = nonsoc_images;
end

opts.Value.IMAGES.images = images;
opts.Value.IMAGES.target_image_categories = image_categories;

fprintf( ' Done.' );

end

function images = get_images(window, stim_path, extension, max_n)

if ( ischar(extension) ), extension = { extension }; end

image_names = cellfun( @(x) get_image_names_one_ext(stim_path, x), extension(:)', 'un', 0 );
image_names = horzcat( image_names{:} );

if ( ~isinf(max_n) && ~isnan(max_n) )
  use_n = min( numel(image_names), max_n );
  image_names = image_names(1:use_n);
end

image_objects = cell( numel(image_names), 1 );

should_create_images = ptb.Window.is_valid_window( window );

for i = 1:numel(image_names)
  if ( should_create_images )
    image_matrix = imread( fullfile(stim_path, image_names{i}) );
    image_object = ptb.Image( window, image_matrix );
  else
    image_object = set( ptb.Color(), [255, 255, 255] );
  end
  
  image_objects{i} = image_object;
end

images = struct();
images.objects = image_objects;
images.filenames = image_names;

end

function image_names = get_image_names_one_ext(stim_path, ext)

try
  image_names = shared_utils.io.dirstruct( stim_path, ext );
  image_names = { image_names(:).name };
catch err
  warning( err.message );
  image_names = {};
end

end

function save_data(data, folder_name, filename)

date_dir = datestr( now, 'mmddyy' );
data_dir = fullfile( gng.util.get_project_folder(), 'data' );

save_p = fullfile( data_dir, date_dir, folder_name );
shared_utils.io.require_dir( save_p );

save( fullfile(save_p, filename), 'data' );

end

function d = get_data_date_folder()

d = strrep( datestr(now), ':', '_' );

end