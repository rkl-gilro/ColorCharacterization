classdef xyY_Correction
    %xyY_Correction encapsulates rotation and scaling parameters to correct
    %xyY values corresponding to a white point xy.
    %
    %   properties
    %       rot_xy          Rotation of xy values
    %       fac_xy          Scaling factor of xy values
    %       fac_Y           Scaling factor of Y values
    %       
    %   public methods
    %       xyY_Correction  Constructor
    
    properties (GetAccess = public, SetAccess = private)
        rot_xy
        fac_xy
        fac_Y
        xy_wp
    end
    
    methods
        function obj = xyY_Correction(rot_xy_, fac_xy_, fac_Y_, xy_wp_)
            %xyY_Correction: Constructor.
            %
            %   Input:  xy rotation [rad]
            %           xy scaling factor
            %           Y scaling factor
            
            if ~(isfloat(rot_xy_) && numel(rot_xy_) == 1)
                error('First parameter must be a floating number scalar.');
            elseif ~(isfloat(fac_xy_) && ...
                    Math.isScalarInInterval(fac_xy_, [0 inf]))
                error(['Second parameter must be a floating number ' ...
                    'scalar >= 0.']);
            elseif ~(isfloat(fac_Y_) && ...
                    Math.isScalarInInterval(fac_Y_, [0 inf]))
                error(['Third parameter must be a floating number ' ...
                    'scalar >= 0.']);
            elseif ~(isfloat(xy_wp_) && numel(xy_wp_) == 2 && ...
                    all(xy_wp_ > 0))
                error(['Third parameter must be a positive floating ' ...
                    'number array with two elements.']);
            end
            
            obj.rot_xy = rot_xy_;
            obj.fac_xy = fac_xy_;
            obj.fac_Y = fac_Y_;
            obj.xy_wp = xy_wp_;
        end
        
        function xyY = apply(obj, xyY)
            %apply applies the correction on a set of xyY input values.
            %
            %   Input:  xyY values (3 rows)
            %   Output: xyY value(s)
            
            if ~(isfloat(xyY) && size(xyY, 1) == 3)
                error(['First parameter must be floating point array ' ...
                    'matrix with 3 rows.']);
            end
                
            wp = repmat(obj.xy_wp, [1 size(xyY, 2)]);
            xyY(1:2, :) = xyY(1:2, :) - wp;
            xyY(3, :) = xyY(3, :) * obj.fac_Y;                              %Y scaling
            
            R = [cos(obj.rot_xy) -sin(obj.rot_xy); ...
                sin(obj.rot_xy) cos(obj.rot_xy)];
            xyY(1:2, :) = R * xyY(1:2, :) * obj.fac_xy;                     %xy rotation and scaling
            
            xyY(1:2, :) = xyY(1:2, :) + wp;
        end        
    end
    
    methods (Static)
        function x = getCorrection(xyY, xyY_gt, xy_wp)
            %getCorrection computes an xyY_Correction object.
            %
            %   Input:  uncorrected xyY values (3 rows)
            %           mean xyY of target value
            %           xy of white point
            %   Output: xyY_Correction object
            
            
            if ~(isfloat(xyY) && size(xyY, 1) == 3)
                error(['First parameter must be floating point matrix ' ...
                    'with 3 rows.']);
            elseif ~(isfloat(xyY_gt) && numel(xyY_gt) == 3)
                error(['Second parameter must be floating point array ' ...
                    'with 3 elements.']);
            elseif ~(isfloat(xy_wp) && numel(xy_wp) == 2)
                error(['Third parameter must be floating point array ' ...
                    'with 2 elements.']);
            end
            
            fac_Y_ = xyY_gt(3) / nanmean(xyY(3,:));                         %Y scaling
            
            m = nanmean(xyY(1:2, :), 2);
            l = sqrt(sum((xyY_gt(1:2) - xy_wp) .^ 2));
            fac_xy_ = l / sqrt(sum((m - xy_wp) .^ 2));                      %xy scaling
            
            smwp = (m - xy_wp) * fac_xy_;                                   %scaled mean xy in wp centered coordinates
            gtwp = xyY_gt(1:2) - xy_wp;                                     %xy ground truth in wp centered coordinates
            if all(smwp == 0) || all(gtwp == 0)                             %same color as white point
                rot_xy_ = 0;
            else
                rot_xy_ = Math.angle(smwp, gtwp);
            end
            
            x = xyY_Correction(rot_xy_, fac_xy_, fac_Y_, xy_wp);
        end            
    end
end

