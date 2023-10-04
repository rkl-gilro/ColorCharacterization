classdef DotNormal < DotGrid
    %DotNormal encapsulates methods and properties of a spatial calibration
    %normal that shows a rectangular grid of dots where three dots are 
    %bigger than the others to encode origin, x-axis, and y-axis (in 
    %decreasing dot size). Base class is DotGrid.
    %
    %   properties
    %       ipx             scatteredInterpolant object (px -> mm in x)
    %       ipy             scatteredInterpolant object (px -> mm in y)
    %       distance_mm     float scalar (distance between dots in mm)
    %
    %   inherited properties
    %       xy_grid         2 x n int (grid coordinates)
    %       spacing         2 x 1 int (grid spacing in [x y])
    %       dim             1 x 2 int ([height, width])
    %       ndot            int scalar (number of dots)
    %       dot             Struct with fields (data for all dots)
    %                           xy          2 x m float (px [x; y])
    %                           intensity   1 x m float (px intensity)
    %                           strength    1 x n float (av. intensity)
    %                           cog         2 x n float ([x; y])
    %                           npx         1 x n int (num. px per dot)
    %
    %   methods
    %       DotNormal       Constructor
    %       xy_mm           Dot positions in mm, or px -> mm conversion
    %       xy_px           Dot positions in px
    %       limx            Returns limits in x [mm]
    %       limy            Returns limits in y [mm]
    %
    %   inherited methods
    %       get_xy          Returns 2 x n float (px-coord. of req. dots)
    %       get_intensity   Returns 1 x n float (px intensity of req. dots)
    %       image           Returns float matrix (processed image)
    %       show            Shows image, dot centers and grid lines

    properties (GetAccess = public, SetAccess = private)
        ipx
        ipy
        distance_mm
    end
    
    methods
        function obj = DotNormal(I, hint, planeFit, distance_mm_)
            %DotNormal: Constructor.
            %
            %   Input:  float matrix (image)
            %           GridVector object
            %           logical scalar (true = plane fit to detect hint)
            %           float scalar (dot distance in mm)
            %   Output: DotNormal object
            
            obj = obj@DotGrid(I, hint, planeFit);
            
            if ~Misc.is(distance_mm_, 'float', 'pos', 'scalar')
                error('Fourth parameter must be a positive float scalar.');
            end
            obj.distance_mm = distance_mm_;
            
            xy_mm_ = obj.xy_mm';
            xy_px_ = obj.xy_px';
            obj.ipx = scatteredInterpolant(xy_px_(:, 1), xy_px_(:, 2), ...
                xy_mm_(:, 1), 'linear', 'none');                            %scatteredInterpolant object for x-component
            obj.ipy = scatteredInterpolant(xy_px_(:, 1), xy_px_(:, 2), ...
                xy_mm_(:, 2), 'linear', 'none');                            %scatteredInterpolant object for y-component
        end
        
        function x = xy_px(obj)
            %xy_px returns the coordinates of the calibration normal dots
            %in camera px.
            %
            %   Output: 2-row float matrix
                        
            x = obj.dot.cog;
        end
        
        function x = xy_mm(obj, xy_px_)
            %xy_mm turns camera px coordinates into coordinates in mm 
            %corresponding to the calibration normal coordinate system. If
            %no input is defined, the positions of all dots are returned.
            %
            %   Input:  2-row float array ([x; y] camera coord. [px])
            %   Output: 2-row float array ([x; y] real world coord. [mm])

            if nargin == 1
                x = obj.xy_grid * obj.distance_mm;
            else
                if ~Misc.is(xy_px_, 'float', {'size', 1, 2}, {'dim', 2})
                    error('Input must be a 2-row float matrix.');
                end
                
                x = nan(size(xy_px_));
                x(1, :) = obj.ipx(xy_px_(1, :), xy_px_(2, :));
                x(2, :) = obj.ipy(xy_px_(1, :), xy_px_(2, :));
            end
        end
        
        function x = limx(obj, i)
            %limx returns the real-world coordinate limits of normal dots 
            %in x.
            %
            %   Input:  int scalar (limit idx, 1 (low) or 2 (up); opt.)
            %   Output: int scalar
            
            if nargin == 2
                x = obj.lim('x', i);
            else
                x = obj.lim('x');
            end
        end
    
        function x = limy(obj, i)
            %limy returns the real-world coordinate limits of normal dots 
            %in y [mm].
            %
            %   Input:  int scalar (limit idx, 1 (low) or 2 (up); opt.)
            %   Output: int scalar
            
            if nargin == 2
                x = obj.lim('y', i);
            else
                x = obj.lim('y');
            end
        end
    end
    
    methods (Access = private)
        function x = lim(obj, xy_, ilu)
            %limx returns the real-world coordinate limits of normal dots 
            %in x.
            %
            %   Input:  char (dimension, 'x' or 'y')
            %           int scalar (limit idx, 1 (low) or 2 (up); opt.)
            %   Output: int scalar
            
            if nargin == 1, ilu = 1 : 2; end
            if ~(isequal(xy_, 'x') || isequal(xy_, 'y'))
                error('First input must be ''x'' or ''y''.');
            elseif ~all(ismember(ilu, [1, 2]))
                error('Second input must be 1 or 2.');
            end
            f = [-1, 1];
            x = (obj.dim(xy_ == 'yx') - 1) / 2 * obj.distance_mm * f(ilu);
        end
    end
end
