classdef RectROI < ROI
    %RectROI encapsulates a rectangle shaped ROI with ROI as base class.
    %
    %   properties
    %       dim         1 x 2 int array ([height, width] in px)
    %
    %   methods
    %       RectROI     Constructor
    %       mask        Returns logical array (valid pixels)
    %       crop        Crops input image to ROI
    %       keyAction   Modifies properties
    %       plot        Plots boundaries

    properties (Hidden, Constant)
        height = 1;
        width = 2;
    end

    properties (GetAccess = private, SetAccess = private)
        flag
    end

    methods (Access = public)
        function obj = RectROI(pos_, dim_)
            %RectROI: Constructor. 
            %
            %   Input:  1 x 2 int ([x, y] position in px)
            %           1 x 2 int ([height, width] in px)
            %   Output: RectROI object
            
            obj = obj@ROI(pos_, dim_);
            obj.flag = obj.width;
        end

        function mask = mask(obj, dimI)
            %mask returns a logical array where valid pixels are true.
            %
            %   Input:  int array (image size)
            %   Output: logical array (mask, true = inside ROI)
            
            ROI.checkMaskParam(dimI);
            mask = false(dimI);
            rect = obj.rect(dimI(1 : 2));
            mask(rect.y1 : rect.y2, rect.x1 : rect.x2, :) = true;
        end

        function I = crop(obj, I)
            %crop crops given image to the ROI's dimensions.
            %
            %   Input:  numeric matrix (image)
            %   Output: numeric matrix (cropped image)
            
            ROI.checkCropParam(I);
            dimI = size(I);
            rect = obj.rect(dimI);
            if numel(dimI) == 2, dimCrop = rect.dim;
            else, dimCrop = [rect.dim, dimI(3 : end)];
            end
            I = reshape(I(obj.mask(dimI)), dimCrop);
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
                obj.modifyDim(obj.step, obj.flag);
                update = true;
            elseif key == 189                                               %'-'
                obj.modifyDim(-obj.step, obj.flag);
                update = true;
            elseif key == 87                                                %'w'
                obj.flag = obj.width;
            elseif key == 72                                                %'h'
                obj.flag = obj.height;
            end
        end
        
        function h = plot(obj, hax, h)
            %plot plots the boundaries. Line color can be set by
            %public property color.
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
            
            x = obj.pos([1, 1]) + [0, obj.dim(2)];
            y = obj.pos([2, 2]) + [0, obj.dim(1)];

            if nargin == 3, delete(h); end
            h = obj.plotBoundary(hax, x([1, 2, 2, 1, 1]), ...
                y([1, 1, 2, 2, 1]));
        end
    end
end

