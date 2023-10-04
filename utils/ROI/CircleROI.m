classdef CircleROI < ROI
    %CircleROI encapsulates a circular ROI with ROI as base class.
    %
    %   properties
    %       radius      int scalar
    %
    %   methods
    %       CircleROI   Constructor
    %       radius      Returns radius
    %       mask        Returns logical array (valid pixels)
    %       keyAction   Modifies properties
    %       plot        Plots boundaries

    properties (GetAccess = public, SetAccess = private)
        radius
    end
    
    methods (Access = public)
        function obj = CircleROI(pos_, radius_)
            %RectROI: Constructor. 
            %
            %   Input:  1 x 2 int (position [x, y] in px)
            %           int scalar (radius in px)
            %   Output: CircleROI object
            
            if ~Misc.is(pos_, 'int', {'numel', 2})
                error('First parameter must be a 1 x 2 int array.');
            elseif ~Misc.is(radius_, 'pos', 'int', 'scalar')
                error('Second parameter must be a positive int scalar.');
            end
            
            obj = obj@ROI(pos_, radius_ * [2, 2]);
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
            mask = d <= obj.radius;
            
            if numel(dimI > 2)
                mask = repmat(mask, [1 1 dimI(3 : end)]);
            end
        end
        
        function update = keyAction(obj, key)
            %keyAction modifies properties for certain key identifiers. 
            %Called by ROI.adjust.
            %
            %   Input:  uint8 scalar (as coded by KbCheck)
            %   Output: logical scalar (true = ROI plot must be updated)
            
            ROI.checkKeyActionParam(key);
            
            update = false;
            if key == 187                                                   %'+'
                obj.modifyDim(obj.step);
                obj.radius = obj.dim(1);
                update = true;
            elseif key == 189                                               %'-'
                obj.modifyDim(-obj.step);
                obj.radius = obj.dim(1);
                update = true;
            elseif key == 79                                                %'o'
                obj.flag = obj.OUTER;
            elseif key == 73                                                %'i'
                obj.flag = obj.INNER;
            end
        end
        
        function h = plot(obj, hax, h)
            %plot plots the boundary. Line color can be set by property
            %color.
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

            n = 2 * pi * obj.radius;                                        %circumference = number of lines
            if n < 4, n = 4; end
            
            alpha = linspace(0, 2 * pi, n);
            center = obj.center;
            x = center(1) + cos(alpha) * obj.radius;
            y = center(2) + sin(alpha) * obj.radius;
            
            if nargin == 3, delete(h); end
            h = obj.plotBoundary(hax, x, y);
        end
    end
end

