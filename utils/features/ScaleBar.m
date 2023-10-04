classdef ScaleBar < handle
    %ScaleBar represents a scale bar and provides methods for setting 
    %parameters and pasting it into images.
    %
    %   public properties
    %       length_mm       float scalar (length of scale bar in mm)
    %       unit            char array (displayed unit of scale bar length)
    %       bg              float scalar (bg intensity of scale bar)
    %       margin_px       int scalar (margin of bg in image)
    %
    %   read-only properties
    %       pxSize_mm       float scalar (size of px in mm)
    %       image           numeric matrix (scale bar image)
    %
    %   public methods
    %       ScaleBar        Constructor
    %       length_px       Returns float scalar (length scale bar in px)
    %       init            Sets properties length_mm and unit
    %       addToImage      Returns numerix matrix (adds scale bar)
    
    properties (Hidden, Constant)
        validUnit = {'m', 'cm', 'mm', 'µm', 'nm'};
        unitFactorToMm = 10 .^ [3, 1, 0, -3, -6];
    end
    
    properties (GetAccess = public, SetAccess = private)
        pxSize_mm
        image
    end
    
    properties (Access = public)
        length_mm
        unit
        bg
        margin_px
    end
    
    methods
        function obj = ScaleBar(sizeStd, I)
            %ScaleBar: Constructor.
            %   
            %   Input:  SizeStandard object
            %           numeric array (image)
            %   Output: ScaleBar object
            
            if ~Misc.is(sizeStd, 'SizeStandard', 'scalar')
                error('First parameetr must be a SizeStandard object.');
            elseif nargin == 2 && ~Misc.is(I, 'numeric', ...
                    {'dim', [2, 3]}, {'size', 3, [1, 3]})
                error(['Second parameter must be a numeric array with ' ...
                    '2 or 3 dimensions and 1 or 3 elements in the ' ...
                    'third dimension.']);
            end
            
            obj.pxSize_mm = sizeStd.pxSize_mm;
            obj.margin_px = 10;
            obj.bg = 0;
            
            if nargin == 2, obj.init(I); end
        end
        
        function set.length_mm(obj, x)
            %set.unit sets property length in mm.
            %   
            %   Input:  float scalar
            
            if ~Misc.is(x, 'float', 'pos', 'scalar')
                error('Input must be a positive float scalar.');
            end
            obj.length_mm = x;
            obj.update;
        end
        
        function set.unit(obj, x)
            %set.unit sets property unit.
            %   
            %   Input:  char array

            if ~Misc.isInCell(x, obj.validUnit)
                error('Input must be %s.', Misc.cellToList(obj.validUnit));
            end
            obj.unit = x;
            obj.update;
        end
        
        function set.bg(obj, x)
            %set.unit sets property bg.
            %   
            %   Input:  float scalar
            
            if ~Misc.is(x, 'float', 'scalar', [0, 1]) 
                error('Input must be a float scalar in [0 1].');
            end
            obj.bg = x;
            obj.update;
        end
        
        function set.margin_px(obj, value)
            %set.unit sets property margin_px.
            %
            %   Input:  int scalar

            if ~Misc.is(x, 'int', 'pos', 'scalar')
                error('Input must be a positive int scalar.');
            end
            obj.margin_px = value;
            obj.update;
        end
        
        function x = length_px(obj)
            %length_px returns length of scale bar in pixels.
            %
            %   Output:  float scalar
            
            if isempty(obj.length_mm)
                error('Property length_mm is not defined.');
            end
            x = round(obj.length_mm / obj.pxSize_mm);
        end
        
        function init(obj, I, h)
            %init initializes properties interactively.
            %
            %   Input:  numeric matrix (image)
            %           Axes handle (optional)
            
            if ~Misc.is(I, 'numeric', {'dim', [2, 3]}, {'size', 3, [1, 3]})
                error(['First parameter must be a numeric array with ' ...
                    '2 or 3 dimensions and 1 or 3 elements in the ' ...
                    'third dimension.']);
            end
            
            if nargin < 3
                Misc.dockedFigure;
            elseif ~Misc.is(h, 'matlab.graphics.axis.Axes', 'scalar')
                error(['Second parameter must be a ' ...
                    'matlab.graphics.axis.Axes object.']);
            else
                subplot(h);
            end
            
            completed = false;
            while ~completed
                fprintf('Select scale bar unit\n');
                obj.unit = Menu.basic(obj.validUnit, 'default', 3);
                obj.length_mm = obj.unitToMm(Menu.basic(sprintf( ...
                    '\nLength of scale bar [%s]: ', obj.unit), ...
                    'prompt', '', 'response', 'scalar'));

                imshow(obj.addToImage(I));                                  %show image with scale bar
                axis tight
                
                completed = Menu.basic('Keep scale bar settings', ...
                    'response', 'yn', 'default', 'y', 'prompt', '? ');
                if ~completed, fprintf('\n'); end
            end
        end
        
        function I = addToImage(obj, I)
            %addToImage adds scale bar to image.
            %
            %   Input:  numeric array (image)
            %   Output: numeric array (image)
            
            if isempty(obj.unit)
                error('Property unit is not defined.');
            elseif isempty(obj.length_mm)
                error('Property length_mm is not defined.');
            elseif ~Misc.is(I, 'numeric', {'dim', [2, 3]}, ...
                    {'size', 3, [1, 3]})
                error(['Input must be a numeric array with 2 or 3 ' ...
                    'dimensions and 1 or 3 elements in the third ' ...
                    'dimension.']);
            end
                
            dimI = size(I);
            if numel(dimI) == 2, dimI = [dimI, 1]; end
            dimBar = size(obj.image);
            
            if ~isa(I, 'uint8')
                type = class(I);
                dim = size(obj.image);
                if isinteger(I)
                    obj.image = typecast(obj.image(:) * ...
                        double(intmax(type)), type);
                elseif isa(I, 'single')
                    obj.image = single(obj.image(:)) / 255;
                elseif isa(I, 'double')
                    obj.image = double(obj.image(:)) / 255;
                else
                    error('Data format of input image is not supported.');
                end
                obj.image = reshape(obj.image, dim);
            end
            
            I((dimI(1) - dimBar(1) + 1) : end, ...
                (dimI(2) - dimBar(2) + 1) : end, :) = ...
                repmat(obj.image, [1 1 prod(dimI(3:end))]);
        end
    end  
    
    methods (Access = private)
        function x = unitToMm(obj, x)
            %unitToMm transforms to mm.
            %
            %   Input:  float array [unit]
            %   Output: float array [mm]

            [~, idx] = ismember(obj.unit, obj.validUnit);
            x = x * obj.unitFactorToMm(idx);
        end
        
        function x = mmToUnit(obj, x)
            %mmToUnit transforms to obj.unit.
            %
            %   Input:  float array [mm]
            %   Output: float array [unit]

            [~, idx] = ismember(obj.unit, obj.validUnit);
            x = x / obj.unitFactorToMm(idx);
        end
        
        function update(obj)
            %update updates property image.

            if isempty(obj.pxSize_mm) || isempty(obj.length_mm) || ...
                    isempty(obj.unit) || isempty(obj.bg) || ...
                    isempty(obj.margin_px)
                return;
            end 
            
            %create bar image
            minHeight = 21;
            
            height = round(obj.length_px * .2);
            if height < minHeight, height = minHeight; end
            if mod(height, 2) == 0, height = height + 1; end
            Ibar = obj.bg * ones(height, obj.length_px);
            if obj.bg > .5, bar = 0;
            else, bar = 1;
            end
            Ibar(ceil(height / 2), :) = bar;
            Ibar(:, [1 end]) = bar;
            
            %create text image
            Itext = [];
            c = num2str(obj.mmToUnit(obj.length_mm));
            c(c == '.') = ',';
            if ~isempty(c)
                for i = 1 : numel(c)
                    Itext = [Itext double(imread(sprintf(...
                        'font/14/number/%s.bmp', c(i)))) / 255];            %#ok
                end
            end
            Itext = [Itext ones(size(Itext,1), 5) double(imread( ...
                sprintf('font/14/unit/%s.bmp', obj.unit))) / 255];

            %adapt Itext to bg intensity
            white = Itext == 1;
            gray = Itext > 0 & Itext < 1;
            inverted = obj.bg <= .5;
            if inverted, this_bg = 1 - obj.bg; 
            else, this_bg = obj.bg;
            end
            Itext(gray) = Itext(gray) * this_bg;
            Itext(white) = this_bg;
            if inverted, Itext = 1 - Itext; end

            %combine text and bar image
            width = max(size(Itext,2), size(Ibar,2)) + 2 * obj.margin_px;
            dimText = size(Itext);
            dimBar = size(Ibar);
            
            obj.image = uint8(round(255 * ...
                [obj.bg * ones(obj.margin_px, width); ...
                obj.bg * ones(dimText(1), ...
                ceil((width - dimText(2)) / 2)) Itext ...
                obj.bg * ones(dimText(1), ...
                floor((width - dimText(2)) / 2)); 
                obj.bg * ones(10, width); ...
                obj.bg * ones(dimBar(1), ...
                ceil((width - dimBar(2)) / 2)) Ibar ...
                obj.bg * ones(dimBar(1), ...
                floor((width - dimBar(2)) / 2)); ...
                obj.bg * ones(obj.margin_px, width)]));
        end
    end
end

