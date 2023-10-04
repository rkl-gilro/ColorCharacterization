classdef GridVector
    %GridVector encapsulates a 2-D position vector and two int scalars that
    %define the grid spacing in x and y.
    %   
    %   properties
    %       origin          2 x 1 int array ([x; y])
    %       dxy             2 x 1 int array ([x; y] grid spacing)
    %    
    %   methods
    %       GridVector      Constructor
    %       dx              Returns int scalar (grid spacing in x)
    %       dy              Returns int scalar (grid spacing in y)
    %       xy              Returns 3 x 2 int ([x; y] start-, x- and y-dot)
    
    properties (GetAccess = public, SetAccess = private)
        origin
        dxy
    end
    
    methods
        function obj = GridVector(origin_, dxy_)
            %GridVector: Constructor. 
            %
            %   Input:  2 x 1 int ([x; y] of origin)
            %           Int scalar with 2 elements ([x y] grid spacing)
            %   Output: GridVector object
            
            if ~Misc.is(origin_, 'int', {'numel', 2})
                error('First parameter must be a 2 x 1 int array.');
            elseif ~Misc.is(dxy_, 'pos', 'int', {'numel', 2})
                error(['Second parameter must be a positive 2 x 1 ' ...
                    'int array.']);
            end
            
            obj.origin = origin_(:);
            obj.dxy = dxy_(:);
        end
        
        function x = dx(obj)
            %dx returns grid spacing in x.
            %   
            %   Output: int scalar

            x = obj.dxy(1);
        end
        
        function x = dy(obj)
            %dy returns grid spacing in y.
            %   
            %   Output: int scalar

            x = obj.dxy(2);
        end
        
        function x = xy(obj)
            %xy returns the coordinates of start-, x-, and y-dot.
            %
            %   Output: 2 x 3 int ([x; y])
            
            x = repmat(obj.origin, [1 3]) + [0, obj.dx, 0; 0, 0, obj.dy];
        end
    end
end

