function conf = default()

%   DEFAULT -- Get default config file.
%
%     conf = ... default() returns the config file `conf` that would have
%     been created with a call to gng.config.create(), but does not
%     overwrite the saved config file.
%
%     See also gng.config.create
%
%     OUT:
%       - `conf` (struct)

conf = gng.config.create( false );

end