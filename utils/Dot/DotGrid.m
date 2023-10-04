classdef DotGrid < DotImage
    %DotGrid encapsulates a grid of Dots. Base class is DotImage.
    %
    %   properties
    %       xy_grid         2 x n int (grid coordinates)
    %       spacing         2 x 1 int (grid spacing in [x y])
    %
    %   inherited properties
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
    %       DotGrid         Constructor
    %       show            Shows image, dot centers and grid lines
    %
    %   inherited methods
    %       get_xy          Returns 2 x n float (px-coord. of req. dots)
    %       get_intensity   Returns 1 x n float (px intensity of req. dots)
    %       image           Returns float matrix (processed image)
    
    
    properties (GetAccess = public, SetAccess = private)
        xy_grid
        spacing
    end
    
    methods
        function obj = DotGrid(I, hint, varargin)
            %DotGrid: Constructor. If the hint is decoded in the image, the
            %second parameter must be a GridVector, otherwise a DotGridHint
            %object.
            %
            %   Input:  float matrix (image)
            %           GridVector (internal hint) 
            %               OR DotGridHint object (external hint) 
            %           logical scalar (ONLY if internal hint; true = use 
            %               plane fit to detect internal hint dots)
            %           key (char array) / value pairs (opt.)
            %               spacing     2 x 1 int ([x y] grid spacing, 
            %                               def = [1, 1])
            %               thrNpx      int scalar (min. num. of px per 
            %                               dot, def = 1)
            %               facNpx      pos. interval (max. size ratio of
            %                               neighbors in number of px, 
            %                               def = [1/3, 3])
            %               maxRot      pos. scalar (maximal vector
            %                               rotation [deg], def = 5)
            %               facLength   pos. interval (rel. distance btw.
            %                               neighbors, def = [2/3, 1.5])
            %   Output: DotGrid object

            obj = obj@DotImage(I);

            if ~ismember(class(hint), {'DotGridHint', 'GridVector'})
                error(['Second parameter must be a DotGridHint or ' ...
                    'GridVector object.']);
            end
            
            internalHint = isa(hint, 'GridVector');                         %true = hint (origin, x-, and y-axis) is encoded by dots inside of grid
            if internalHint
                if nargin < 3
                    error('Expected at least three parameters.');
                elseif ~Misc.is(varargin{1}, 'logical', 'scalar')
                    error('Third parameter must be a logical scalar.');
                end
                planeFit = varargin{1};
            end
            
            if nargin > 2 + internalHint
                for i = 1 + internalHint : 2 : numel(varargin)
                    key = varargin{i};
                    value = varargin{i + 1};
                    errStr = sprintf('%s parameter must be a ', ...
                        Misc.ordinalNumber(i + 2));
                    
                    if ~ischar(key)
                        error('%s char array.', errStr);
                    elseif isequal(key, 'spacing')
                        if ~Misc.is(value, 'pos', 'int', {'numel', 2})
                            error('%s positive 2 x 1 int array.', errStr);
                        end
                        obj.spacing = value(:);
                    elseif isequal(key, 'thrNpx')
                        if ~Misc.is(value, 'pos', 'int', 'scalar')
                            error('%s positive int scalar.', errStr);
                        end
                        thrNpx = value;
                    elseif isequal(key, 'facNpx')
                        if ~Misc.is(value, 'interval', 'pos')
                            error('%s positive interval.', errStr);
                        end
                        facNpx = value;
                    elseif isequal(key, 'facLen')
                        if ~Misc.is(value, 'interval', 'pos') 
                            error('%s positive interval.', errStr);
                        end
                        facSqLen = value .^ 2;
                    elseif isequal(key, 'maxRot')
                        if ~Misc.is(value, 'pos', 'scalar')
                            error('%s positive scalar.', errStr);
                        end
                        maxRot = value;
                    else
                        error('Unknown parameter key %s.', key);
                    end                        
                end
            end
            if isempty(obj.spacing), obj.spacing = [1, 1]'; end
            if ~exist('facNpx', 'var'), facNpx = [1/3, 3]; end
            if ~exist('facLen', 'var'), facSqLen = [4/5, 5/4] .^ 2; end
            if ~exist('maxRot', 'var'), maxRot = 10; end
            maxRot = Math.degToRad(maxRot);
            
            %discard noise dots with thrNpx
            if exist('thrNpx', 'var')
                obj.deleteDot(obj.dot.npx >= thrNpx);
            end
            

            %match hint dots with grid dots (all if internalHint = true)
            %--------------------------------------------------------------
            %if necessary, transform parameter hint into DotGridHint object
            if internalHint
                hint = DotGridHint.fromDotImage(obj, hint, planeFit); 
            end
            
            obj.xy_grid = nan(2, obj.ndot);
            idet = false(1, obj.ndot);                                      %index of dots detected as grid members
            itest = [];                                                     %indices of grid dots to search for neighboring dots
            imatch = nan(1, 3);                                             %indices of grid dots closesest to hint dots
            dxy = nan(2, 3);                                                %distance of closest grid dot from hint dot in grid coord. 

            for i = 1 : 3
                d = sum((obj.dot.cog - repmat(hint.xy_px(:, i), ...
                    [1, obj.ndot])) .^ 2);                                  %px distance between hint dot and all grid dots
                [~, imatch(i)] = min(d);
                dxy(:, i) = round(hint.vxy \ ...
                    (obj.dot.cog(:, imatch(i)) - hint.xy_px(:, i)));
                if isequal(dxy(:, i), [0, 0]')                              %closest grid dot is at same position as hint dot = direct match
                    idet(imatch(i)) = true;                                 %mark this grid dot as identified
                    obj.xy_grid(:, imatch(i)) = hint.xy_grid(:, i);         %set its grid coordinates
                    if i == 1, itest = imatch(i); end                       %save index as start for neighbor search
                end
            end
            
            %if no direct match was found, i.e., hint and grid dots are at 
            %different grid positions, select the grid dot closest to the 
            %first (biggest) hint dot to start the grid search. 
            if isempty(itest)                                               
                itest = imatch(1);
                idet(imatch(1)) = true;
                obj.xy_grid(:, imatch(1)) = hint.xy_grid(:, 1) + dxy(:, 1);
            end
            clear dxy imatch
            
            
            %search grid
            %--------------------------------------------------------------
            nbmat = [1, 0, -1, 0; 0, 1, 0, -1] .* ...
                repmat(obj.spacing, [1, 4]);                                %+x +y -x -y
            v = nan(2, 4, obj.ndot);
            v(:, :, itest) = [hint.vxy, -hint.vxy] .* ...
                repmat(obj.spacing', [2, 2]);
            timeBar = TimeBar('Detecting grid:');
            applySizeFilter = ~internalHint;                                %if an internal hint is used, the start dot is larger than all others -> do not apply size filter in first run (for start dot)
            missing = false(1, 4);
            
            while ~isempty(itest)
                %check which neighbors have not been detected yet
                xynb = [obj.xy_grid(1, itest(1)) + nbmat(1, :); ...
                    obj.xy_grid(2, itest(1)) + nbmat(2, :)];
                for i = 1 : 4
                    inb = obj.xy_grid(1, :) == xynb(1, i) & ...
                        obj.xy_grid(2, :) == xynb(2, i);
                    missing(i) = all(~inb);
                    if ~missing(i)
                        v(:, i, itest(1)) = obj.dot.cog(:, inb) - ...
                            obj.dot.cog(:, itest(1));                       %neighbor was already detected: save vector so it can be forwarded
                    end
                end
                
                imissing = find(missing);
                if ~isempty(imissing)
                    %search undetected neighbors. Filter by distance
                    irem = find(~idet);
                    sql = (obj.dot.cog(1, ~idet) - ...
                        obj.dot.cog(1, itest(1))) .^ 2 + ...
                        (obj.dot.cog(2, ~idet) - ...
                        obj.dot.cog(2, itest(1))) .^ 2;                     %squared distance of all not detected dots to current dot. Note: Long, explicit expression is faster than using repmat.
                    sql0 = sum(v(:, :, itest(1)) .^ 2);                     %squared length of all estimated vectors to neighbors
                    limL = [min(sql0), max(sql0)] .* facSqLen;
                    val = sql >= limL(1) & sql <= limL(2);                  %true = dot distance is in the expected interval
                    ntest = numel(itest);

                    if any(val)
                        irem = irem(val);
                        
                        for i = imissing
                            if isempty(irem)
                                break
                            elseif any(isnan(v(:, i, itest(1))))
                                continue
                            end
                            jrem = irem;
                            
                            %filter by angle
                            val = abs(Math.angle(obj.dot.cog(:, jrem) - ...
                                repmat(obj.dot.cog(:, itest(1)), ...
                                [1, numel(jrem)]), ...
                                v(:, i, itest(1)))) <= maxRot;              %true = angle to expected vector is less than maxRot degrees
                            if all(~val), continue, end
                            jrem = jrem(val);                               %again, reduce remaining indices

                            %filter by dot size (num. of px)
                            if applySizeFilter
                                limNpx = obj.dot.npx(itest(1)) * facNpx;
                                val = obj.dot.npx(jrem) >= limNpx(1) & ...
                                    obj.dot.npx(jrem) <= limNpx(2);         %true = number of dot pixels are within expected interval
                                if all(~val), continue, end
                                jrem = jrem(val);                           %again, reduce remaining indices
                            end
                            
                            %select dot with max. strength
                            if numel(jrem) > 1
                                [~, imax] = max(obj.dot.strength(jrem));
                                jrem = jrem(imax);
                            end
                            v(:, i, itest(1)) = obj.dot.cog(:, jrem) - ...
                                obj.dot.cog(:, itest(1));                   %update v of tested dot
                            obj.xy_grid(:, jrem) = ...
                                obj.xy_grid(:, itest(1)) + nbmat(:, i);     %assign coordinates to identified grid dot
                            idet(jrem) = true;                              %mark index as detected
                            irem = irem(irem ~= jrem);                      %remove from irem
                            itest(end + 1) = jrem;                          %#ok. Add found neighbor to index list of dots to be tested for neighbors
                        end
                        
                        if ntest < numel(itest)
                            v(:, :, itest(ntest + 1 : end)) = ...
                                repmat(v(:, :, itest(1)), ...
                                [1, 1, numel(itest) - ntest]);              %pass v of current dot to all neighboring dots. It will be overwritten where neighbors actually exist
                        end
                    end
                end
                
                itest(1) = [];                                              %remove index of tested dot
                if ~applySizeFilter, applySizeFilter = true; end            %apply size filter after the first run
                timeBar.update(sum(idet) / obj.ndot);
            end
            timeBar.update(1);
            
            %delete outlayers
            obj.xy_grid = obj.xy_grid(:, idet);
            if any(~idet), obj.deleteDot(~idet); end
        end
        
        function show(obj, h)
            %show displays image, dot centers, and grid lines.
            %
            %   Input:  matlab.graphics.axis.Axes object (optional)
            
            if nargin == 1
                Misc.dockedFigure;
            elseif ~isa(h, 'matlab.graphics.axis.Axes')
                error('Input must be a matlab.graphics.axis.Axes object.');
            end
            
            imshow(~isnan(obj.image));                                      %show grid dots
            hold on
            
            %draw grid lines
            for ixy = 1 : 2                                                 %go along x/y
                for xory = min(obj.xy_grid(ixy, :)) : ...
                        obj.spacing(ixy) : ...
                        max(obj.xy_grid(ixy, :))                            %pass all grid columns (x) / grid rows (y)
                    i = find(obj.xy_grid(ixy, :) == xory);                  %indices of all dots in the given column / row
                    [yorx, isort] = sort(obj.xy_grid(3 - ixy, i));          %sorted y/x grid coordinate for given column / row
                    cog = obj.dot.cog(:, i(isort));                         %sorted dot centers for given column / row
                    d = diff(yorx);                                         %distance of y/x-coordinate of dot position in given column / row
                    j = find(d ~= obj.spacing(3 - ixy));                    %indices of gaps (for drawing connection lines)
                    j = [1, j + 1; j, numel(i)];                            %#ok. Index array from start to end of column / row, with one additional column per gap
                    j = j(:, diff(j) > 0);                                  %clear columns for isolated dots (no line necessary)
                    
                    %plot grid lines in current column / row
                    for k = 1 : size(j, 2)                                  
                        l = j(1, k) : j(2, k);
                        plot(cog(1, l), cog(2, l), 'g');
                    end
                end
            end
        end
    end
end
