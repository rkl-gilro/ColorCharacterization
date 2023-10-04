classdef (Abstract) ROI < matlab.mixin.Heterogeneous & ...
        matlab.mixin.Copyable
    %ROI is an abstract base class for RectROI, CircleROI and RingROI. It 
    %encapsulates properties and methods of a ROI (region of interest).
    %Base classes are matlab.mixin.Heterogeneous and matlab.mixin.Copyable.
    %
    %   properties
    %       pos         1 x 2 int array ([x, y])
    %       dim         1 x 2 int array ([height, width])
    %       line        Struct with line properties
    %
    %   public methods
    %       ROI         Constructor
    %       rect        Returns Rect object corresponding to the ROI
    %       crop        Crops input image to ROI
    %       center      Returns center of ROI
    %
    %   abstract methods
    %       mask        Returns logical array (valid pixels)
    %       keyAction   Modifies properties
    %       plot        Plots boundaries
    %
    %   static methods
    %       init        Returns object of ROI subclass. Asks user which
    %                       subclass to use, optionally calls ROI.adjust
    %       adjust      Interactive adjustment of ROI parameters
    
    properties (GetAccess = public, SetAccess = public)
        step = 1;
        pos
        dim
        line
    end
    
    methods
        function obj = ROI(pos_, dim_)
            %ROI: Constructor.
            %
            %   Input:  1 x 2 int ([x, y])
            %           1 x 2 int ([height, width])
            %   Output: ROI object
             
            obj.pos = pos_(:)';
            obj.dim = dim_(:)';
            obj.line = struct('Color', [1, 0, 0], 'LineStyle', '-', ...
                'LineWidth', 0.5000, 'Marker', 'none', ...
                'MarkerSize', 6, 'MarkerFaceColor', 'none');
        end
        
        function set.pos(obj, pos_)
            %set.pos sets property pos.
            %
            %   Input:  1 x 2 int array ([x, y])
            
            if ~Misc.is(pos_, 'int', {'numel', 2})
                error('Input must be a 1 x 2 int array.');
            end
            
            obj.pos = pos_(:)';
        end
        
        function set.dim(obj, dim_)
            %set.pos sets property dim.
            %
            %   Input:  1 x 2 int array ([height, width])
            
            if ~Misc.is(dim_, 'int', 'pos', {'numel', 2})
                error('Input must be a positive 1 x 2 int array.');
            end
            
            obj.dim = dim_;
        end
        
        function x = rect(obj, dimI)
            %rect returns an Rect object that defines the enclosing
            %rectangle of the ROI within the given image dimensions.
            %
            %   Input:  int array ([height width] of image)
            %   Output: Rect object
            
            x = Rect(obj.pos(1), obj.pos(2), obj.dim(2), obj.dim(1));
            x.crop(dimI(1 : 2));
        end        
        
        function I = crop(obj, I)
            %crop crops given image to the ROI dimensions.
            %
            %   Input:  numeric array (images)
            %   Output: numeric array (cropped images)
            
            dimI = size(I);
            ROI.checkCropParam(I);
            I(~obj.mask(dimI)) = NaN;
            rect = obj.rect(dimI(1 : 2));
            I = reshape(I(rect.y1 : rect.y2, rect.x1 : rect.x2, :), ...
                [rect.dim, dimI(3 : end)]);
        end
        
        function x = center(obj)
            %center returns center of ROI.
            %   
            %   Output: double array ([x y])
            
            x = obj.pos + round(obj.dim([2, 1]) / 2);
        end
    end
    
    methods (Access = protected)
        function translate(obj, dpos)
            %translate translates ROI position.
            %
            %   Input:  int array ([x, y] of shift)

            if ~Misc.is(dpos, 'int', {'numel', 2})
                error('Input must be a 1 x 2 int array.');
            end
            
            obj.pos = obj.pos + dpos(:)';
        end
        
        function modifyDim(obj, step_, idim)
            %modifiyDim modifies property dim by two times of a given step
            %size. 
            %
            %   Input:  int scalar (step size)
            %           int scalar (idx of dim.; 1 = y, 2 = x, def = [1 2])
            
            if nargin < 3, idim = [1 2]; end
            if ~Misc.is(step_, 'pos', 'int', 'scalar') 
                error('First parameter must be an int scalar.');
            elseif ~(isequal(idim, 1) || isequal(idim, 2) || ...
                    isequal(sort(idim), [1, 2]))
                error('Second parameter must be 1, 2, or [1 2].');
            end
                
            ipos = 3 - idim;
            
            tmp = obj.dim(idim) + 2 * step_;
            if tmp >= 2
                obj.dim(idim) = obj.dim(idim) + 2 * step_;
                obj.pos(ipos) = obj.pos(ipos) - step_;
            else
                center = obj.center;
                obj.pos(ipos) = center(ipos) - 1;
                obj.dim(idim) = 2;
            end
        end
        
        function h = plotBoundary(obj, hax, x, y)
            %plotBoundary plots ROI boundary on given axis handle.
            %
            %   Input:  matlab.graphics.axis.Axes object (axis handle)
            %           float array (x-values of boundary)
            %           float array (y-values of boundary)
            
            if ~Misc.is(hax, 'matlab.graphics.axis.Axes', 'scalar')
                error(['First parameter must be a ' ...
                    'matlab.graphics.axis.Axes object.']);
            elseif ~Misc.is(x, 'float', '~isempty')
                error('Second parameter must be a non-empty float array.');
            elseif ~Misc.is(y, 'float', '~isempty')
                error('Third parameter must be  a non-empty float array.');
            end
                
            subplot(hax), hold on
            h = plot(x, y);
            field = fieldnames(obj.line);
            for i = 1 : numel(field)
                h.(field{i}) = obj.line.(field{i});
            end
        end
    end
    
    methods (Abstract)
        mask(obj)
        keyAction(obj)
        plot(obj)
    end
    
    methods (Static, Access = public)
        function roi = init(dimI)
            %init lets user select type of ROI via command window and
            %parametrize the ROI on the input image via keyboard.
            %
            %   Input:  1 x 2 int array (dim. of image)
            %   Output: ROI subclass object

            if ~Misc.is(dimI, 'pos', 'int', {'numel', [2, 3]})
                error(['Input must be a positive 1 x 2 or 1 x 3 int ' ...
                    'array.']);
            end
            
            fprintf('Choose type of ROI:\n');
            [~, i] = Menu.basic({'Rect' 'Circle' 'Ring'});

            if i == 1
                dim_ = ceil(dimI / 4) * 2;
                pos_ = round((dimI([2, 1]) - dim_([2, 1])) / 2);              %center of ROI at center of image
                roi = RectROI(pos_, dim_);
                
            elseif i > 1
                radius = min(ceil(dimI / 8) * 2);
                pos_ = round((dimI([2, 1]) - 2 * radius) / 2);               %center of ROI at center of image

                if i == 2
                    roi = CircleROI(pos_, radius);
                elseif i == 3
                    roi = RingROI(pos_, ceil(radius * [1, 1 / 4]));         %3rd parameter: inner radius
                end
            end
        end
        
        function [roi, completed] = adjust(roi, I)
            %adjust interacts with the user to adjust the parameters of an
            %ROI subclass object.
            %
            %   Input:  ROI subclass object
            %           numeric matrix (image)
            
            if ~Misc.is(roi, 'ROI', 'scalar')
                error('First parameter muist be a ROI object.');
            elseif ~Misc.is(I, 'numeric', {'dim', [2, 3]})
                error(['Second parameter must be a 2- or 3-dim ' ...
                    'numeric matrix.']);
            end
            
            if isa(roi, 'RectROI')
                keyLegend = {'w:', 'select width'; ...
                    'h:', 'select height'; ...
                    '+:', 'increase width or height'; ...
                    '-:', 'decrease width or height'};
            elseif isa(roi, 'CircleROI')
                keyLegend = {'+:', 'increase radius'; ...
                    '-:', 'decrease radius'};
            elseif isa(roi, 'RingROI')
                keyLegend = {'i:', 'select inner radius'; ...
                    'o:', 'select outer radius'; ...
                    '+:', 'increase radius'; ...
                    '-:', 'decrease radius'};
            else
                error('Class %s is not supported.', class(roi));
            end
                
            try
                ListenChar(2);                                              %disable keyboard input
                while KbCheck, end                                          %wait until keyboard buffer is empty
                clc
                if nargout == 2
                    c = {'Return:', 'apply'; ...
                        'Escape:', 'quit and apply'};
                else
                    c = {'Return / Escape:', 'quit and apply'};
                end
                
                fprintf(['Key assignment', newline, ...
                    Misc.cellToTable({'Left:', 'shift leftwards'; ...
                    'Right:', 'shift rightwards'; ...
                    'Up:', 'shift upwards'; ...
                    'Down:', 'shift downwards'; ...
                    'c:', 'center'; keyLegend; ...
                    'f:', 'faster'; 's:', 'slower'; c})]);                  %print key assignment
                
                warning('Off', 'images:initSize:adjustingMag');
                warning('Off', ['images:imshow:magnificationMustBeFit' ...
                    'ForDockedFigure']);
                
                imshow(I);                                                  %show image
                hax = gca;
                hROI = roi.plot(hax);                                       %plot initial ROI
                ROI.setTitle(hax, roi);                                     %set title of plot
                drawnow
                
                dimI = size(I);
                dxy = [-1 0; 0 -1; 1 0; 0 1];
                
                completed = false;
                
                while ~completed
                    [keydown, ~, keycode] = KbCheck;
                    
                    if keydown
                        key = find(keycode, 1, 'first');
                        update = true;
                        
                        if key >= 37 && key <= 40
                            roi.translate(roi.step * ...
                                dxy(key - 36, :));
                        elseif key == 67
                            roi.pos = round((dimI([2, 1]) - ...
                                roi.dim([2, 1])) / 2);
                        elseif key == 70
                            roi.step = roi.step + 1;
                            while KbCheck, end
                        elseif key == 83
                            if roi.step > 1, roi.step = roi.step - 1; end
                            while KbCheck, end
                        elseif key == 13
                            if nargout == 2, return;
                            else, completed = true;
                            end
                        elseif key == 27
                            completed = true;
                        else
                            update = roi.keyAction(key);
                        end
                        
                        if update
                            hROI = roi.plot(hax, hROI);                     %plot updated ROI
                            ROI.setTitle(hax, roi);                         %set title of plot
                            pause(.02);
                        end
                    end
                end
                ListenChar(0);                                              %enable keyboard input
                
            catch ME
                ListenChar(0);                                              %enable keyboard input
                rethrow(ME);
            end
        end
    end    
      
    methods (Static, Access = protected)
        function checkMaskParam(dimI)
            %checkMaskParam does the error checking for the function 
            %crop in subclasses of ROI.
            %
            %   Input:  int array (image size)

            if ~Misc.is(dimI, 'pos', 'int', {'numel', '>=', 2})
                error(['Input must be a positive int array with >= 2 ' ...
                    'elements.']);
            end
        end
        
        function checkCropParam(I)
            %checkCropParam does the error checking for the function crop
            %in subclasses of ROI.
            %
            %   Input:  numeric array (image)
            
            if ~Misc.is(I, 'numeric', {'dim', 2 : 4})
                error('Input must be a numeric array.'); 
            end
        end
        
        function checkKeyActionParam(key)
            %checkKeyActionParam does the error checking for the function 
            %keyAction in subclasses of ROI.
            %
            %   Input:  uint8 scalar (as coded by KbCheck)
            
            if ~Misc.is(key, 'int', 'scalar', [0, 255])
                error('Input must be a uint8 scalar.');
            end
        end
        
        function checkPlotParam(hax, h)
            %checkPlotParam does the error checking for the function plot
            %in subclasses of ROI.
            %
            %   Input:  matlab.graphics.axis.Axes object
            %           matlab.graphics.chart.primitive.Line array

            if ~Misc.is(hax, 'matlab.graphics.axis.Axes', 'scalar')
                error(['First parameter must be a ' ...
                    'matlab.graphics.axis.Axes object.']);
            elseif nargin == 3 && ...
                    ~(isa(h, 'matlab.graphics.chart.primitive.Line'))
                error(['Second parameter must be a ' ...
                    'matlab.graphics.chart.primitive.Line array.']);
            end
        end       
    end
    
    methods (Static, Hidden)
        function setTitle(hax, roi)
            %setTitle sets the title for a ROI adjustment plot. Called by
            %ROI.adjust.
            %
            %   Input:  Handle of axis
            %           ROI subclass object
            
            if ~Misc.is(hax, 'matlab.graphics.axis.Axes', 'scalar')
                error(['First parameter must be a ' ...
                    'matlab.graphics.axis.Axes object.']);
            elseif ~Misc.is({'isa', 'ROI'}, 'scalar')
                error('Second parameter must be a ROI subclass object.');
            end
            
            if isa(roi, 'RectROI')
                strParam = sprintf('width = %d, height = %d', ...
                    roi.dim([2, 1]));
            elseif isa(roi, 'CircleROI')
                strParam = sprintf('radius = %.0f', roi.radius);
            elseif isa(roi, 'RingROI')
                strParam = sprintf('radius = [%.0f %.0f]', roi.radius);
            end
            
            title(hax, sprintf('x = %d, y = %d, %s, step = %d', ...
                roi.pos, strParam, roi.step), 'FontSize', 10);
        end
    end
end

