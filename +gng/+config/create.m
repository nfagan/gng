
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = gng.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( gng.util.get_project_folder() );

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'ptb_helpers', 'serial_comm' };

%	INTERFACE
INTERFACE = struct();
INTERFACE.use_mouse = true;
INTERFACE.use_reward = false;
INTERFACE.is_debug = true;
INTERFACE.should_save = true;

%	SCREEN
SCREEN = struct();
SCREEN.index = 0;
SCREEN.background_color = [ 0 0 0 ];
SCREEN.rect = [ 0, 0, 400, 400 ];
SCREEN.should_open_window = true;

%	TIMINGS
TIMINGS = struct();

time_in = struct();
time_in.new_trial = 0;
time_in.fixation = 1;
time_in.display_go_nogo_cue = 1;
time_in.go_nogo = 1;
time_in.error_go_nogo = 1;
time_in.error_broke_cue_fixation = 1;
time_in.reward = 1;
time_in.iti = 1;

TIMINGS.time_in = time_in;

% STRUCTURE
STRUCTURE = struct();
STRUCTURE.use_reward_cue = false;
STRUCTURE.p_go = 0.7;
STRUCTURE.p_target_left = 1;
STRUCTURE.max_n_images = inf;

%	STIMULI
STIMULI = struct();
STIMULI.setup = struct();

STIMULI.setup.fix_square =                make_stimulus( [255, 255, 255] );
STIMULI.setup.go_cue =                    make_stimulus( [0, 0, 255] );
STIMULI.setup.nogo_cue =                  make_stimulus( [0, 255, 0] );
STIMULI.setup.go_target =                 make_stimulus();
STIMULI.setup.reward_feedback =           make_stimulus( [255, 0, 0], [], false );
STIMULI.setup.error_broke_cue_fixation =  make_stimulus( [0, 255, 0], [100, 100], false );
STIMULI.setup.error_wrong_go_nogo =       make_stimulus( [0, 0, 255], [100, 100], false );

%	SERIAL
SERIAL = struct();
SERIAL.port = 'COM3';
SERIAL.channels = { 'A' };

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;
conf.TIMINGS = TIMINGS;
conf.STIMULI = STIMULI;
conf.SCREEN = SCREEN;
conf.INTERFACE = INTERFACE;
conf.STRUCTURE = STRUCTURE;
conf.SERIAL = SERIAL;

if ( do_save )
  gng.config.save( conf );
end

end

function stim = make_stimulus(color, sz, has_target)

if ( nargin < 1 || isempty(color) )
  color = [ 255, 0, 255 ];
end

if ( nargin < 2 || isempty(sz) )
  sz = [ 50, 50 ];
end

if ( nargin < 3 || isempty(has_target) )
  has_target = true;
end

non_editable_properties = {{ 'placement', 'has_target', 'image_matrix' }};

stim = struct( ...
    'size',               sz ...
  , 'color',              color ...
  , 'position',           [ 0.5, 0.5 ] ...
  , 'normalize_position', true ...
  , 'normalize_size',     false ...
  , 'has_target',         has_target ...
  , 'target_duration',    0.3 ...
  , 'target_padding',     0 ...
  , 'non_editable',       non_editable_properties ...
);

end