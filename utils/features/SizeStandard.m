classdef SizeStandard
    %SizeStd encapsulates methods to measure the global pixel size
    %in an image of a size standard that shows three black equi-distant 
    %markers on white background.
    %
    %   properties
    %       image           numeric matrix (image of size standard)
    %       distance_mm     float scalar (marker distance in mm)
    %       xyMarker        2 x 3 float (px positions of markers in image)
    %       pxSize_mm       float scalar (px size in mm)
    %
    %   methods
    %       SizeStandard    Constructor
    %       plot            Plots xyMarker on image
    
    properties (GetAccess = public, SetAccess = private)
        image
        distance_mm
        xyMarker
        pxSize_mm
    end
    
    methods
        function obj = SizeStandard(I, distance_mm_, sd_px)
            %SizeStandard: Constructor.
            %
            %   Input:  numeric matrix (image of size standard)
            %           float scalar (marker distance in mm, def = 10)
            %           float scalar (sd of gaussian filter in px, def = 2)
            %   Output: SizeStandard object
            
            if ~Misc.is(I, 'numeric', {'dim', [2, 3]}, {'size', 3, [1, 3]})
                error(['Input must be a numeric array with 2 or 3 ' ...
                    'dimensions and 1 or 3 elements in the third ' ...
                    'dimension.']);
            end
            obj.image = mean(I, 3);
            
            if nargin < 2, distance_mm_ = 10; end
            if nargin < 3, sd_px = 2; end
            
            if ~Misc.is(distance_mm_, 'float', 'scalar', '~isnan')
                error('Second parameter must be a positive float scalar.');
            elseif ~Misc.is(sd_px, 'float', 'scalar', '~isnan')
                error('Third parameter must be a positive float scalar.');
            end
            obj.distance_mm = distance_mm_;
            
            %create gaussian filter
            dim = size(I);
            [y, x] = ndgrid(linspace(-.5, .5, dim(1)), ...
                linspace(-.5, .5, dim(2)) * dim(2) / dim(1));
            d = sqrt(x .^ 2 + y .^ 2);
            g = Math.gauss(d, sd_px / dim(1));
            
            %filter image with gauss and set background NaN
            I = mean(I, 3);                                                 %gray scale and double conversion
            I = 1 - I / max(I(:));                                          %invert and normalize image
            inval = isnan(I);
            I(inval) = 0;                                                   %NaNs to zeros
            I = fftshift(ifft2(fft2(I) .* fft2(g)));                        %filter
            I(inval) = NaN;                                                 %zeros to NaNs
            thr = Misc.splitDistribution(log(I(~inval) + 1));               %signal threshold
            I(log(I + 1) < thr) = NaN;                                      %set noise NaN
            
            %process filtered image
            di = DotImage(I);                                               %create DotImage object from image
            [~, isort] = sort(di.dot.npx);                                  %dot index sorted by number of px per dot
            obj.xyMarker = di.dot.cog(:, isort(1 : 3));                     %get coordinates of three biggest dots
            distance_px = sqrt(sum((obj.xyMarker(:,[2 3 1]) - ...
                obj.xyMarker) .^ 2));                                       %get distances between markers
            obj.pxSize_mm = obj.distance_mm / mean(distance_px);            %compute pixel size in mm
            
            %print and show results
            fprintf(['Marker distance in px (mean [min max]): ' ...
                '%.1f, [%1.f %.1f]\n'], mean(distance_px), ...
                min(distance_px), max(distance_px));
            fprintf('Pixel size: %.3f mm\n', obj.pxSize_mm);
        end
        
        function show(obj, h)
            %show displays property image and xyMarker.
            %
            %   Input:  Axes handle (optional)
            
            if nargin < 2
                Misc.dockedFigure;
            elseif ~Misc.is(h, 'matlab.graphics.axis.Axes', 'scalar')
                error('Input must be a matlab.graphics.axis.Axes object.');
            else
                subplot(h);
            end
            
            imshow(obj.image);
            axis tight
            hold on
            
            if ~isempty(obj.xyMarker)
                n = size(obj.xyMarker, 2);
                plot(obj.xyMarker(1, :), obj.xyMarker(2, :), '+', ...
                    'MarkerSize', 10);
                plot(obj.xyMarker(1, [1:n 1]), ...
                    obj.xyMarker(2, [1:n 1]));
            end
            drawnow
        end
    end
end

