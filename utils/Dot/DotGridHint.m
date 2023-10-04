classdef DotGridHint
    %DotGridHint is a helper class for DotGrid. It encapsulates the
    %position of a start dot and two further dots that define the x- and
    %y-axis of the DotGrid.
    %
    %   properties
    %       xy_grid          2 x 3 int ([x; y] of dots in grid coord.)
    %       xy_px            2 x 3 float ([x; y] of dots in image coord.)
    %
    %   methods
    %       DotGridHint     Constructor
    %       vxy             Returns x and y grid unit vec. in image coord.
    %       est_xy_px       Returns 2 x n float (image coordinates
    %                           estimated from grid coordinates)
    %
    %   static methods
    %       fromDotImage    Returns DotGridHint object (from DotImage obj.)
    
    properties (GetAccess = public, SetAccess = private)
        xy_grid
        xy_px
    end
    
    methods
        function obj = DotGridHint(xy_grid_, xy_px_)
            %DotGridHint: Constructor.
            %
            %   Input:  2 x 3 int ([x; y] in grid coord.)
            %           2 x 3 float ([x; y] in image coord.)
            %   Output: DotGridHint object
            
            if ~(Misc.is(xy_grid_, 'int', {'size', [2, 3]}) && ...
                    size(unique(xy_grid_', 'rows'), 1) == 3)
                error(['First parameter must be a 2 x 3 int array ' ...
                    'with unique column vectors.']);
            elseif ~Misc.is(xy_px_, 'float', 'pos', {'size', [2, 3]})
                error(['Second parameter must be a positive 2 x 3 ' ...
                    'float array.']);
            end
            
            obj.xy_grid = xy_grid_;
            obj.xy_px = xy_px_;
        end
        
        function x = vxy(obj)
            %vxy returns the x and y unit vector of the grid
            %coordinate system in image coordinates.
            %
            %   Input:  DotGridHint object
            %   Output: 2 x 2 float ([x y])
            
            l = [obj.xy_grid(1, 2) - obj.xy_grid(1, 1), ...
                obj.xy_grid(2, 3) - obj.xy_grid(2, 1)];
            dxy = obj.xy_px(:, 2 : 3) - repmat(obj.xy_px(:, 1), [1, 2]);
            x = dxy ./ repmat(l, [2, 1]);
        end
        
        function xy_px_ = est_xy_px(obj, xy_grid_)
            %est_xy_px returns image coordinates corresponding to grid
            %coordinates (which can be decimals).
            %
            %   Input:  2 x n float ([x; y] in grid coord.)
            %   Output: 2 x n float ([x; y] in image coord.)
            
            if ~Misc.is(xy_grid_, 'float', {'size', 1, 2})
                error('Input must be float and have two rows.');
            end
            
            n = size(xy_grid_, 2);                                          %number of points to estimate
            xy_px_ = repmat(obj.xy_px(:, 1), [1, n]) + ...
                obj.vxy * (xy_grid_ - repmat(obj.xy_grid(:, 1), [1, n]));
        end
    end
    
    methods (Static)
        function obj = fromDotImage(dotImage, v, planeFit)
            %fromDotImage returns a DotGridHint object from a DotImage
            %and a GridVector object.
            %
            %   Input:  DotImage object
            %           GridVector object (grid coordinates of hint dots)
            %           logical scalar (true = use plane fit for detection
            %               of hint dots; useful if embedded in numerous 
            %               non-hint dots, i.p. if pattern is tilted))
            %   Output: DotGridHint object
            
            if ~Misc.is(dotImage, {'isa', 'DotImage'}, 'scalar')
                error('First parameter must be a DotImage object.');
            elseif dotImage.ndot < 3
                error('First parameter must contain >= 3 dots.');           %three dots are required to mark origin, x-axis, and y-axis
            elseif ~Misc.is(v, 'GridVector', 'scalar')
                error('Second parameter must be a GridVector object.');
            elseif ~Misc.is(planeFit, 'logical', 'scalar')
                error('Third parameter must be a logical scalar.');
            end
            
            if planeFit                                                     %fit a plane into a point cloud, where x and y correspond to x and y of dots, and z corresponds to the number of px per dot. Three biggest points above the plane in z are selected as hint dots
                xyz = [dotImage.dot.cog; dotImage.dot.npx];
                optim = optimset('TolX', 1e-12, 'TolFun', 1e-12, ...
                    'MaxFunEvals', 1e7, 'Display', 'off');
                dz = xyz(3, :) - Math.planeZ(xyz(1 : 2, :), ...
                    Math.fitPlane(xyz, optim));                             %deviation from fitted plane in z (= deviation in dot size)
                [~, imax] = sort(dz, 'descend');                            %three most distant dots are origin, x-, and y-vector
                xy_px_ = xyz(1 : 2, imax(1 : 3));
            else                                                            %use no plane fit
                cog = [dotImage.dot.cog];
                [~, imax] = sort(dotImage.dot.npx, 'descend');
                xy_px_ = cog(:, imax(1 : 3));
            end
            
            xy_grid_ = repmat(v.origin, [1, 3]) + [0, v.dx, 0; 0, 0, v.dy];
            obj = DotGridHint(xy_grid_, xy_px_);
        end
    end
end
