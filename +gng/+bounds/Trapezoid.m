classdef Trapezoid < ptb.bounds.PolygonPrimitive
  
  properties (Access = public, Constant = true)
    Directions = { 'left', 'right' };
  end
  
  properties (Access = public)
    Window = ptb.Null;
    Stimulus = ptb.Null;
    Direction = 'left';
  end
  
  methods
    function obj = Trapezoid(window, stimulus)
      
      %   TRAPEZOID -- Create bounds that are a trapezoid aligned to the 
      %     left or right screen edge, and the edge of a
      %     rect-stimulus.
      %
      %     See also ptb.bounds.PolygonPrimitive, ptb.stimuli.Rect
      
      if ( nargin < 1 )
        window = ptb.Null;
      end
      
      if ( nargin < 2 )
        stimulus = ptb.Null;
      end
      
      obj.Window = window;
      obj.Stimulus = stimulus;
    end
    
    function set.Window(obj, v)
      validateattributes( v, {'ptb.Window', 'ptb.Null'}, {'scalar'} ...
        , mfilename, 'Window' );
      obj.Window = v;
    end
    
    function set.Stimulus(obj, v)
      validateattributes( v, {'ptb.Null', 'ptb.stimuli.Rect'}, {'scalar'} ...
        , mfilename, 'Stimulus' );
      obj.Stimulus = v;
    end
    
    function set.Direction(obj, v)
      obj.Direction = validatestring( v, obj.Directions, mfilename, 'Direction' );
    end
  end
  
  methods (Access = public)
    function vertices = get_vertices(obj)
      
      window = obj.Window;
      stim = obj.Stimulus;
      direction = obj.Direction;
      
      vertices = nan( 4, 2 );
      
      if ( ptb.isnull(window) || ptb.isnull(stim) )
        return        
      end
      
      screen_rect = get_rect( window );
      stim_rect = get_rect( stim );
      
      if ( isempty(screen_rect) || isempty(stim_rect) )
        return
      end
      
      switch ( direction )
        case 'left'
          vertices(1, 1) = screen_rect(1);
          vertices(1, 2) = screen_rect(2);

          vertices(2, 1) = screen_rect(1);
          vertices(2, 2) = screen_rect(4);

          vertices(3, 1) = stim_rect(1);
          vertices(3, 2) = stim_rect(4);

          vertices(4, 1) = stim_rect(1);
          vertices(4, 2) = stim_rect(2);
        case 'right'
          vertices(1, 1) = stim_rect(3);
          vertices(1, 2) = stim_rect(2);

          vertices(2, 1) = stim_rect(3);
          vertices(2, 2) = stim_rect(4);

          vertices(3, 1) = screen_rect(3);
          vertices(3, 2) = screen_rect(4);

          vertices(4, 1) = screen_rect(3);
          vertices(4, 2) = screen_rect(2);
        otherwise
          error( 'Unrecognized direction "%s".', direction );
      end   
    end
  end

end