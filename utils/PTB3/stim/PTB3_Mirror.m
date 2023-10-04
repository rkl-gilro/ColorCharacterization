classdef PTB3_Mirror
    %PTB3_Mirror encapsulates properties and methods to mirror windows,
    %e.g. to draw mirrored content on a window.
    %
    %   properties
    %       h               logical scalar (horizontal mirroring)
    %       v               logical scalar (vertical mirroring)
    %
    %   methods
    %       PTB3_Mirror     Constructor
    %       apply           Applies mirroring
    
    properties (GetAccess = public, SetAccess = public)
        h
        v
    end
    
    methods
        function obj = PTB3_Mirror(h_, v_)
            %PTB3_Mirror: Constructor.
            %
            %   Input:  logical scalar (horizontal mirroring)
            %           logical scalar (vertical mirroring)
            %   Output: PTB3_Mirror object

            
            if nargin < 2, v_ = false; end
            if nargin < 1, h_ = false; end
            
            obj.h = h_;
            obj.v = v_;
        end
        
        function obj = set.h(obj, x)
            %set.h sets property h.
            %
            %   Input:  logical scalar
        
            if ~Misc.is(x, 'logical', 'scalar')
                error('Input must be a logical scalar.');
            end
            obj.h = x;
        end
            
        function obj = set.v(obj, x)
            %set.v sets property v.
            %
            %   Input:  logical scalar
        
            if ~Misc.is(x, 'logical', 'scalar')
                error('Input must be a logical scalar.');
            end
            obj.v = x;
        end
            
        function apply(obj, screen, x, y)
            %apply applies mirroring to the given window at pos. [x, y]. 
            %
            %   Usage:  Call apply and then your drawing operation. 
            %           To reset the mirroring after drawing, call
            %           Screen('glPushMatrix', window); before apply and
            %           Screen('glPopMatrix', window); after your drawing 
            %           operation.
            %
            %   Input:  int scalar (PTB3 screen index)
            %           int scalar (x)
            %           int scalar (y)

            if ~Misc.is(screen, 'int', 'scalar', {'>=', 0})
                error('First parameter must be an int scalar >= 0.');
            end
            
            winH = PTB3_Window.getHandle(screen);
            [width, height] = Screen('WindowSize', winH);
            if nargin < 4, y = height / 2; end
            if nargin < 3, x = width / 2; end
                
            if ~Misc.is(x, 'int', 'scalar')
                error('Second parameter must be an int scalar.');
            elseif ~Misc.is(y, 'int', 'scalar')
                error('Third parameter must be an int scalar.');
            end                
            
            if obj.h || obj.v
                Screen('glTranslate', winH, x, y, 0);                       %translate origin
                if obj.h, Screen('glScale', winH, -1, 1, 1); end            %apply a scaling transform which flips the direction of x-Axis, thereby mirroring horizontally
                if obj.v, Screen('glScale', winH, 1, -1, 1); end            %apply a scaling transform which flips the direction of y-Axis, thereby mirroring vertically
                Screen('glTranslate', winH, -x, -y, 0);                     %undo translations
            end
        end
    end
end

