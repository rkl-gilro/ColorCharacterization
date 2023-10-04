classdef DotImage < matlab.mixin.Copyable
    %DotImage encapsulates methods and properties for a dot image.
    %
    %DEVELEOPER NOTE: property dot is a struct that contains the aggregated
    %data for all detected dots. A class design where each dot was a 
    %separated object would be more convenient for programming, but because
    %of the high number of dots per image that can occur, this can produce 
    %a lot of overhead and consequently is inconvenient to use with respect
    %to file size, and saving and loading performance.
    %
    %   properties 
    %       dim                 1 x 2 int ([height, width])
    %       ndot                int scalar (number of dots)
    %       dot                 Struct with fields (data for all dots)
    %                               xy          2 x m int (px [x; y])
    %                               intensity   1 x m float (px intensity)
    %                               strength    1 x n float (av. intensity)
    %                               cog         2 x n float ([x; y])
    %                               npx         1 x n int (num. px per dot)
    %
    %   methods
    %       DotImage            Constructor
    %       get_xy              Returns 2 x n float (px-coor. of req. dots)
    %       get_intensity       Returns 1 x n float (px in. of req. dots)
    %       image               Returns float matrix (processed image)
    %       show                Shows image and dot centers
    %
    %   static methods
    %       setBgNaN            Returns float array (sets background NaN)
    %       biggestDotOnly      Returns float matrix 
    
    properties (GetAccess = public, SetAccess = protected)
        dim
        ndot
        dot
    end
    
    methods
        function obj = DotImage(I)
            %DotImage: Constructor. 
            %
            %   Input:  float matrix (image)
            %   Output: DotImage object

            if ~(Misc.is(I, 'float', 'matrix') && any(isnan(I(:))))
                error(['First parameter must be a float matrix with ' ...
                    'NaN values (background).']);
            end
        
            valid = ~isnan(I);
            ntotal = sum(valid(:));
            if ntotal == 0, return; end

            pxleft = ntotal;
            nbmat = [0 1 0 -1; 1 0 -1 0];                                   %relative neighbor map for a single pixel
            w = size(valid, 2);
            h = size(valid, 1);
            xy_ = nan(2, pxleft);

            %allocate memory
            obj.dot.xy = nan(2, pxleft);
            obj.dot.intensity = nan(1, pxleft);
            obj.dot.strength = nan(1, pxleft);
            obj.dot.cog = nan(2, pxleft);
            obj.dot.npx = nan(1, pxleft);
            
            i = 0;                                                          %counter for number of dots
            j = 0;                                                          %counter for number of px
            iFirst = 0;                                                     %index in valid from where to search for the next px that is not NaN
            nValid = numel(valid);
            timeBar = TimeBar('Detecting dots: ');
            
            while pxleft >= 1
                %start px of next dot
                while iFirst <= nValid                                      %bad style, but faster
                    iFirst = iFirst + 1;
                    if valid(iFirst), break; end
                end
                xy_(1, 1) = ceil(iFirst / h);                               %coord. corresponding to iFirst
                xy_(2, 1) = iFirst - (xy_(1, 1) - 1) * h;
                valid(iFirst) = false;                                      %delete 1st pixel from image
                iPx = 1;
                nPx_ = 1;

                %look for connected pixels
                if pxleft > 0
                    completed = false;
                    while ~completed
                        nnewpx = (nPx_ - iPx + 1);
                        nb = unique((reshape(repmat( ...
                            xy_(:, iPx : nPx_), [4 1]), ...
                            [2 nnewpx * 4]) + ...
                            repmat(nbmat, [1 nnewpx]))', 'rows')';
                        nb = nb(:, nb(1, :) >= 1 & nb(1, :) <= w & ...
                            nb(2, :) >= 1 & nb(2, :) <= h);                 %exclude out-of-border neighbors
                        inb = (nb(1, :) - 1) * h + nb(2, :);                %1-dim index of nb
                        nbf = nb(:, valid(inb));                            %neighbors that are valid px
                        nnbf = size(nbf, 2);                                %number of valid neighbors found

                        if nnbf > 0
                            xy_(:, nPx_ + (1 : nnbf)) = nbf;                %add found neighbors to xy_
                            iPx = nPx_ + 1;
                            nPx_ = nPx_ + nnbf;
                            valid(inb) = false;                             %set all neighbors to zero
                        else
                            completed = true;
                        end
                    end

                    pxleft = pxleft - nPx_;                                 %while parameter: number of above threshold px left
                    idx = (xy_(1, 1 : nPx_) - 1) .* h + xy_(2, 1 : nPx_);
                    
                    i = i + 1;
                    j = j(end) + (1 : nPx_);
            
                    obj.dot.xy(:, j) = xy_(:, 1 : nPx_);
                    obj.dot.intensity(j) = I(idx);
                    obj.dot.npx(i) = nPx_;
                    obj.dot.strength(i) = sum(obj.dot.intensity(j)) ./ ...
                        obj.dot.npx(i);
                    obj.dot.cog(:, i) = sum(obj.dot.xy(:, j) .* ...
                        repmat(obj.dot.intensity(j), [2 1]), 2) / ...
                        sum(obj.dot.intensity(j));            
                end
                timeBar.update(1 - pxleft / ntotal);
            end
            
            obj.dim = size(I);
            obj.dot.xy = obj.dot.xy(:, 1 : j(end));
            obj.dot.intensity = obj.dot.intensity(1 : j(end));
            obj.dot.strength = obj.dot.strength(1 : i);
            obj.dot.cog = obj.dot.cog(:, 1 : i);
            obj.dot.npx = obj.dot.npx(1 : i);
            obj.ndot = numel(obj.dot.npx);    
        end
        
        function x = get_xy(obj, iDot)
            %get_xy returns property xy_px for the given dot indices.
            %
            %   Input:  1 x n int (dot indices, def = all)
            %   Output: 2 x m int (px. coord. of dot px [x; y])
            
            if nargin == 1, x = xy;
            else, x = obj.dot.xy(:, obj.getDotIdx(iDot));
            end
        end
        
        function x = get_intensity(obj, iDot)
            %get_intensity returns property intensity for the given dot 
            %indices.
            %
            %   Input:  1 x n int (dot indices)
            %   Output: 2 x m int (px. coord. of dot px [x; y])
            
            if nargin == 1, x = obj.dot.xy;
            else, x = obj.dot.intensity(:, obj.getDotIdx(iDot));
            end
        end
        
        function x = image(obj)
            %image returns the processed image, where the background is set
            %to NaN and rejected dots are deleted. 
            %
            %   Output: float matrix
            
            x = nan(obj.dim);
            x((obj.dot.xy(1, :) - 1) * obj.dim(1) + obj.dot.xy(2, :)) = ...
                obj.dot.intensity;
        end
        
        function show(obj, ax)
            %show shows I and dot centers.
            %   
            %   Input:  Axes object (optional)
            
            if nargin == 1
                Misc.dockedFigure; 
            elseif nargin == 2
                if ~Misc.is(ax, 'Axes', 'scalar')
                    error('Input must be an Axes object.');
                end
                axes(ax(1));
            end
                
            hold on
            imshow(obj.image);
            plot(obj.dot.cog(1, :), obj.dot.cog(2, :), 'xr');
        end
    end
    
    methods (Access = protected)
        function deleteDot(obj, invalid)
            %deleteDot deletes entries in properties xy_px, intensity,
            %strength, and npx corresponding to dots to be deleted.
            %
            %   Input:  logical array (true = invalid) OR 
            %               int array (invalid dot indices)

            if ~(islogical(invalid) || Misc.is(invalid, 'int'))
                error('Input must be int or logical.');
            elseif islogical(invalid) && ...
                    ~(numel(invalid) == obj.ndot && any(invalid))
                error(['Logical input must be have %d elements of ' ...
                    'which at least one must be true.'], obj.ndot);
            elseif Misc.is(invalid, 'int') && ...
                    ~Misc.is(invalid, [1, obj.ndot])
                error('Int input must be in [1 %d].', obj.ndot);
            end

            if islogical(invalid), invalid = find(invalid); end
            iPx = obj.getDotIdx(invalid);
            obj.dot.xy(:, iPx) = [];
            obj.dot.intensity(iPx) = [];
            obj.dot.strength(invalid) = [];
            obj.dot.cog(:, invalid) = [];
            obj.dot.npx(invalid) = [];            
            obj.ndot = numel(obj.dot.npx);
        end
    end

    methods (Access = private)
        function x = getDotIdx(obj, iDot)
            %getDotIdx returns the indices of property xy_px and intensity 
            %corresponding to given dot indices.
            %
            %   Input:  int array (dot indices)
            %   Output: int array (px indices)
            
            if ~Misc.is(iDot, 'int', [1, obj.ndot])
                error('Input must be an int array in [1 %d].', obj.ndot);
            end
            
            x = nan(1, numel(obj.dot.intensity));                           %allocate memory for output variable
            x0 = [1, cumsum(obj.dot.npx) + 1];                              %start indices for each dot
            j = 0;                                                          %counter for output variable
            for i = iDot(:)'
                x_ = x0(i) : x0(i + 1) - 1;
                n = numel(x_);
                x(j + (1 : n)) = x_;
                j = j + n;
            end
            x = x(1 : j);                                                   %crop unused memory
        end
    end
    
    methods (Static)
        function [I_, thr] = setBgNaN(I_, varargin)
            %setBgNaN sets the background of a matrix (image) to NaN, which
            %is the expected input for the DotImage constructor. The 
            %background is assumed to be darker, i.e., of lower intensity
            %than the signal. 
            %There are several ways to find the threshold between signal
            %and background. If no further parameter is defined, it will be
            %determined by searching a local minimum in the intensity 
            %histogram of the input matrix. This usually works only for 
            %white images where signal and background are clearly
            %separated.
            %If the ratio between signal and background is known, e.g.
            %based one a good estimate of the signal area relative to the
            %background area, this ratio can be used as the additional 
            %parameter 'signal2bg', which is particularly helpful for fine 
            %spatial structures.  
            %'signal2bg' usually requires that the image is corrected for 
            %luminance variation originating in the screen or the camera
            %beforhand. A 'white' and / or 'dark' image can be provided for
            %this purpose as additional parameters. 
            %If the threshold is already known it can be directly defined 
            %as 'thr'. In this case 'signal2bg' has no effect, but 'white' 
            %and 'dark' will be applied anyway. 
            %
            %   Input:  float matrix (image)
            %           Key / value pairs (optional):
            %               white       float matrix (white image)
            %               dark        float matrix (dark image)
            %               signal2bg   float scalar (signal to bg ratio)
            %               thr         float scalar (threshold)
            %   Output: float matrix (processed image)
            %           float scalar (threshold)
            
            if ~Misc.is(I_, 'float', 'matrix')
                error('Input must be a float matrix.');
            end
            dim = size(I_);

            if nargin > 1
                if mod(nargin, 2) == 0
                    error('Incomplete key / value pair.');
                end
                for i = 1 : 2 : numel(varargin)
                    if ~ischar(varargin{i})
                        error('%s parameter must be a char array.', ...
                            Misc.ordinalNumber(i + 1)); 
                    elseif Misc.isInCell(varargin{i}, {'white', 'dark'})
                        if ~Misc.is(varargin{i + 1}, 'float', 'matrix')
                            error(['%s parameter must be a numeric ' ...
                                '%d x %d matrix.'], ...
                                Misc.ordinalNumber(i + 2), dim(1), dim(2));
                        end
                        if isequal(varargin{i}, 'white')
                            white = Math.normalizeInt(varargin{i + 1});
                        else
                            dark = Math.normalizeInt(varargin{i + 1});
                        end
                    elseif isequal(varargin{i}, 'signal2bg')
                        if ~Misc.is(varargin{i + 1}, 'float', 'pos', ...
                                'scalar', {'<', 1})
                            error(['%s parameter must be a scalar in ' ...
                                ']0 1[.'], Misc.ordinalNumber(i + 2));
                        end
                        signal2bg = varargin{i + 1};
                    elseif isequal(varargin{i}, 'thr')
                        if ~Misc.is(varargin{i + 1}, 'float', 'scalar')
                            error(['%s parameter must be a float ' ...
                                'scalar.'], Misc.ordinalNumber(i + 2));
                        end
                        thr = varargin{i + 1};
                    else
                        error('Unknown key %s.', varargin{i});
                    end                            
                end
            end
            
            I_ = Math.normalizeInt(I_);                                     %convert image to double and normalize

            %subtract dark image
            if exist('dark', 'var')
                I_ = I_ - dark;
                I_(I_ < 0) = 0;
                if exist('white', 'var')
                    white = white - dark;
                    white(white < 0) = 0;
                end
            end
            
            %normalize by white image
            if exist('white', 'var')
                I_ = I_ ./ white;
            end
            
            if exist('thr', 'var')
                I_(I_ < thr) = NaN;
            elseif exist('signal2bg', 'var')                                %signal2bg is ignored if a threshold is defined
                thr = prctile(I_(:), (1 - signal2bg) * 100);
                I_(I_ < thr) = NaN;
            else
                thr = Misc.splitDistribution(I_);
                tmp = I_;
                tmp(tmp >= thr) = NaN;                                      %set anything but background to NaN
                bg = DotImage(tmp);                                         %search connected background areas
                [~, imax] = max(bg.dot.npx);                                %get index of dot with most pixels (= background)
                j = (bg(imax).dot.xy(1, :) - 1) * dim(1) + ...
                    bg(imax).dot.xy(2, :);                                  %1-dim indices of background pixels
                I_(j) = NaN;                                                %set background px to NaN
            end
        end
        
        function x = biggestDotOnly(I)
            %biggestDotOnly returns an image where all but the biggest 
            %dot are set to NaN.
            %
            %   Input:  float matrix
            %   Output: float matrix
            
            if ~Misc.is(I, 'float', 'matrix')
                error('Input must be a float matrix.');
            end
            
            dim = size(I);
            di = DotImage(DotImage.setBgNaN(I));                            %create dot image from input image
            [~, iMax] = max([di.dot.npx]);                                  %index of biggest dot
            xy = di.get_xy(iMax);                                           %px coord of biggest dot
            i = (xy(1, :) - 1) * dim(1) + xy(2, :);                         %1-dim indices of biggest dot

            x = nan(dim);
            x(i) = di.get_intensity(iMax);
        end
    end
end
