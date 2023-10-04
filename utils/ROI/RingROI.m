classdef RingROI < ROI
    %RingROI encapsulates a ring-shaped ROI with ROI as base class.
    %
    %   properties
    %       radius          1 x 2 int array ([outer, inner] radius in px)
    %
    %   methods
    %       RingROI         Constructor
    %       mask            Returns logical array (valid pixels)
    %       keyAction       Modifies properties
    %       plot            Plots boundaries
    
    properties (Hidden, Constant)
        inner = 1;
        outer = 2;
    end
    
    properties (GetAccess = private, SetAccess = private)
        flag
    end
    
    properties (GetAccess = public, SetAccess = private)
        radius
    end
    
    methods (Access = public)
        function obj = RingROI(pos_, radius_)
            %RingROI: Constructor.
            %
            %   Input:  1 x 2 int ([x, y] position in px)
            %           1 x 2 int ([inner, outer] radius in px)
            %   Output: RingROI object
            
            obj = obj@ROI(pos_, radius_(2) * [2, 2]);

            if ~Misc.is(radius_, 'interval', 'pos', 'int', {'numel', 2})
                error(['Second parameter must be a positive 1 x 2 int ' ...
                    'interval.']);
            end
            obj.radius = radius_;
            obj.flag = obj.outer;                                           %set flag to outer radius
        end
        
        function mask = mask(obj, dimI)
            %mask returns a logical array where valid pixels are true.
            %
            %   Input:  int array (image size)
            %   Output: logical array (mask, true = inside ROI)
            
            ROI.checkMaskParam(dimI);
            [y, x] = ndgrid(1 : dimI(1), 1 : dimI(2));
            center = obj.center;
            y = y - center(2) + .5;
            x = x - center(1) + .5;
            d = sqrt(x .^ 2 + y .^ 2);
            mask = d <= obj.radius(obj.outer) & d >= obj.radius(obj.inner);

            if numel(dimI > 2)
                mask = repmat(mask, [1, 1, dimI(3 : end)]);
            end
        end
        
        function update = keyAction(obj, key)
            %keyAction modifies properties for certain key identifiers. 
            %Called by ROI.adjust.
            %
            %   Input:  uint8 scalar (as coded by KbCheck)
            %   Output: logical scalar (true = ROI plot must be updated
            
            ROI.checkKeyActionParam(key);
            
            update = false;
            if key == 187                                                   %'+'
                update = true;
                if obj.flag == obj.outer
                    obj.modifyDim(obj.step);
                elseif obj.flag == obj.inner
                    if obj.radius(obj.inner) + obj.step < ...
                            obj.radius(obj.outer)
                        obj.radius(obj.inner) = obj.radius(obj.inner) + ...
                            obj.step;
                    else
                        obj.radius(obj.inner) = obj.radius(obj.outer) - 1;
                    end
                end
            elseif key == 189                                               %'-'
                update = true;
                if obj.flag == obj.outer
                    if obj.radius(obj.outer) - obj.step > ...
                            obj.radius(obj.inner)
                        obj.modifyDim(-obj.step);
                    else
                        obj.dim = 2 * (obj.radius(obj.inner) + 1) * [1, 1];
                    end
                elseif obj.flag == obj.inner
                    if obj.radius(obj.inner) - obj.step >= 1
                        obj.radius(obj.inner) = obj.radius(obj.inner) - ...
                            obj.step;
                    else
                        obj.radius(obj.inner) = 1;
                    end
                end
            elseif key == 79                                                %'o'
                obj.flag = obj.outer;
            elseif key == 73                                                %'i'
                obj.flag = obj.inner;
            end
        end
        
        function h = plot(obj, hax, h)
            %plot plots the boundary. Line color can be set by public 
            %property color.
            %
            %   Input:  matlab.graphics.axis.Axes object (axis handle)
            %           matlab.graphics.chart.primitive.Line array (line 
            %               handle of previously plotted ROI in order to
            %               delete it; optional)
            %   Output: matlab.graphics.chart.primitive.Line array (line 
            %               handle of boundaries)

            if exist('h', 'var'), ROI.checkPlotParam(hax, h);
            else, ROI.checkPlotParam(hax); 
            end

            if nargin == 3, delete(h); end
            
            for i = 1 : 2
                n = 2 * pi * obj.radius(i);                                 %circumference = number of lines
                if n < 4, n = 4; end

                alpha = linspace(0, 2 * pi, n);
                center = obj.center;
                x = center(1) + cos(alpha) * obj.radius(i);
                y = center(2) + sin(alpha) * obj.radius(i);

                h(i) = obj.plotBoundary(hax, x, y);
            end
        end
    end
end

