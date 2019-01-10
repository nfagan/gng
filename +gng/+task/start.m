function start(conf)

if ( nargin < 1 || isempty(conf) )
  conf = gng.config.load(); 
end

opts = gng.task.setup( conf );
gng.task.run( opts );

end