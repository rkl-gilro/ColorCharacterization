classdef (Abstract) Misc
    %Misc is an abstract class that contains miscellaneous static helper 
    %functions.
    %
    %   static methods
    %       alert               Returns float array (alert sound wave)
    %       autoLim             Sets axes limits of a 1-, 2- or 3-dim plot
    %       beep                Returns wave of beep sound
    %       capitalize          Returns char array
    %       cellToList          Returns char array
    %       cellToStruct        Returns struct
    %       cellToTable         Returns char array
    %       closeSerial         Closes serial connections for given port
    %       continueOrAbort     Returns logical scalar
    %       dockedFigure        Returns figure handle (opens docked figure)
    %       flat                Returns input as 1-dim array
    %       getPath             Returns char array (path for file)
    %       getSize             Returns the size of a variable in bytes
    %       headline            Prints headline on command window
    %       is                  Returns logical scalar
    %       isCellOf            Returns logical scalar
    %       isInCell            Returns logical scalar
    %       isValidFilename     Returns logical scalar
    %       isValidFoldername   Returns logical scalar
    %       load                Returns object of demanded tpye from file
    %       minPath             Returns char array
    %       ordinalNumber       Returns char array (ordinal number)
    %       repeatOnError       Executes command, asks to repeat on error
    %       splitDistribution   Returns antimode of bimodal distribution
    %       structToCell        Converts struct to cell array
    %       waitForEnter        Disables keyboard and waits for Enter
    %       waitForKey          Disables keyboard and waits for certain key
    
    methods (Static)
        function x = alert(freq, beepDur, dutyCycle, rep, amp)
            %alert returns a sound wave that consists of repeated beeps.
            %
            %   Input:  float scalar (sound frequency in Hz)
            %           float scalar (beep duration in sec)
            %           float scalar (duty cycle, interval [0, 1])
            %           int scalar (number of beeps)
            %           float scalar (amplitude, interval [0, 1])
            %   Output: float array (sound wave)
            
            if nargin < 5, amp = 1; end
            if ~Misc.is(freq, 'float', 'pos', 'scalar')
                error(['First parameter must be a positive, non-NaN ' ...
                    'float scalar.']);
            elseif ~Misc.is(beepDur, 'float', 'pos', 'scalar')
                error(['Second parameter must be a positive, non-NaN ' ...
                    'float scalar.']);
            elseif ~Misc.is(dutyCycle, 'float', 'scalar', [0, 1])
                error('Third parameter must be a float scalar in [0, 1].');
            elseif ~Misc.is(rep, 'pos', 'int', 'scalar')
                error('Fourth parameter must be a positive int scalar.');
            elseif  ~Misc.is(amp, 'float', 'scalar', [0, 1])
                error('Fifth parameter must be a float scalar in [0, 1].');
            end
            
            x = Misc.beep(freq, beepDur);
            x = amp * repmat([x, zeros(1, round(numel(x) * ...
                (1 - dutyCycle)))], [1, rep]);
        end
        
        function autoLim(x, fac)
            %autoLim sets axis limits of a 1-, 2-, or 3-dim plot corres-
            %ponding to the given value range and a factor. For 1-dim
            %data, the y-axis will be set as demanded, and the x-axis will 
            %be tight.
            %
            %   Input:  numeric array (1st dim: axes)
            %           float scalar (factor of displayed range:
            %               1 = fitting exactly, default = 1.2 (margin of 
            %               .1 times the value range on both sides))

            if nargin < 2, fac = 1.2; end
            if ~Misc.is(x, 'numeric', {'size', 1, 1 : 3})
                error(['First parameter must be a numeric array with ' ...
                    'max. 3 rows.'])
            elseif ~Misc.is(fac, 'pos', 'scalar')
                error('Second parameter must be a positive scalar.');
            end
                
            if size(x, 1) == 1
                axis tight
                c = {'ylim'};
            else
                c = {'xlim', 'ylim', 'zlim'};
            end
            
            for i = 1 : size(x, 1)
                set(gca, c{i}, min(x(i, :)) * [1 1] + ...
                     [(1 - fac) / 2, fac / 2 + .5] * range(x(i, :)));
            end
        end       
        
        function x = beep(freq, dur)
            %alert returns a sound wave of a beep.
            %
            %   Input:  float scalar (sound frequency in Hz)
            %           float scalar (beep duration in sec)
            %   Output: float array (sound wave)
            
            if ~Misc.is(freq, 'float', 'pos', 'scalar')
                error('First parameter must be a positive float scalar.')
            elseif ~Misc.is(dur, 'float', 'pos', 'scalar')
                error('Second parameter must be a positive float scalar.')
            end
            t = linspace(0, dur, round(8192 * dur));                        %wave is played with sound(...), which uses 8192 Hz sampling frequency
            x = sin(t * 2 * pi * freq) / 2 + .5;
        end
        
        function c = capitalize(c)
            %capitalize capitalizes a char array.
            %
            %   Input:  char array
            %   Output: char array
            
            if ~ischar(c)
                error('Input must be a char array.');
            elseif Misc.is(double(c(1)), [97, 122])
                c(1) = char(double(c(1)) - 32);
            end
        end
        
        function x = cellToList(c, conj)
            %cellToList turns a cell array of char arrays into a char array
            %that contains a human-friendly list.
            %
            %   Input:  cell array of char arrays
            %           char array ('and', 'or', 'and / or'; def = 'or')
            %   Output: char array
            
            validConj = {'and', 'or', 'and / or'};
            if nargin < 2, conj = 'or'; end
            if ~Misc.isCellOf(c, 'char') && numel(c) > 0 
                error(['First parameter must be a cell array of ' ...
                    'char arrays.']);
            elseif ~Misc.isInCell(conj, validConj)
                error('Second parameter must be %s.', ... 
                    Misc.cellToList(validConj));
            end
            x = c{1};
            n = numel(c);
            for i = 2 : n - 1, x = sprintf('%s, %s', x, c{i}); end
            if n > 1, x = sprintf('%s %s %s', x, conj, c{end}); end
        end
        
        function x = cellToStruct(var)
            %cellToStruct converts cell into struct. Odd cells are 
            %interpreted as field names and must be char arrays, even cells
            %are interpreted as value and thus can have arbitrary format.
            %
            %   Input:  cell array
            %   Output: struct
            
            if ~(iscell(var) && ~mod(numel(var), 2))
                error(['Input must be a cell array with an even ' ...
                    'number of elements.']);
            end
            for i = 1 : 2 : numel(var)
                if ~ischar(var{i})
                    error('%s cell must be a char array.', i);
                end
                x.(var{i}) = var{i + 1};
            end
        end
        
        function c = cellToTable(x)
            %cellToTable converts a cell matrix of char arrays into a 
            %table-formatted char array.
            %
            %   Input:  cell matrix (of char arrays)
            %   Output: char array
            
            dim = size(x);
            if ~(Misc.isCellOf(x, 'char') && numel(size(x)) == 2)
                error('Input must be a 2-dim cell array of char arrays.');
            end
            
            %get length of each entry
            l = nan(dim);
            for i = 1 : dim(1)
                for j = 1 : dim(2)
                    l(i, j) = numel(x{i, j});
                end
            end
            nBuffer = 2;                                                     %minimum distance between text in two columns in spaces
            cBuffer = repmat(' ', [1, nBuffer]);
            l = l + nBuffer;
            lCol = ceil(max(l, [], 1) / 4) * 4;                             %maximal text length in each column
             
            c = '';
            for i = 1 : dim(1)
                for j = 1 : dim(2)
                    nTab = ceil((lCol(j) - l(i, j)) / 4);
                    c = [c, x{i, j}, cBuffer, ...
                        sprintf(repmat('\t', [1, nTab]))];                  %#ok
                end
                c = [c, newline];                                           %#ok
            end
        end
       
        function closeSerial(port)
            %closeSerial closes open devices on given port.
            %
            %   Input:  char array (port, e.g. 'COM3')
            
            tmp = instrfind;
            if ~isempty(tmp)
                for i = 1 : tmp.length
                    if isequal(tmp(i).port, port) && ...
                            isequal(tmp(i).status, 'open')
                        fclose(tmp(i));
                    end
                end
            end
        end
        
        function x = continueOrAbort(continueKey, abortKey)
            %continueOrAbort waits for keyboard input and returns after
            %either a given continue or abort key was pressed. In the
            %first case, true is returned, otherwise false.
            %
            %   Input:  Keycode of continue key (default = Enter)
            %           Keycode of abort key (default = Escape)
            %   Output: logical scalar
            
            if nargin < 2, abortKey = 27; end
            if nargin < 1, continueKey = 13; end
            
            if ~(isempty(continueKey) || ...
                    Misc.is(continueKey, 'int', [1, 256]))
                error('First parameter is invalid.');
            elseif ~(isempty(abortKey) || ...
                    Misc.is(abortKey, 'int', [1, 256]))
                error('Second parameter is invalid.');
            end
            
            try
                ListenChar(2);
                while KbCheck, end
                
                done = false;
                while ~done
                    [keydown, ~, keycode] = KbCheck;
                    if keydown
                        key = find(keycode, 1, 'first');
                        if isempty(continueKey)
                            x = true;
                            done = true;
                        elseif any(key == [continueKey abortKey])
                            x = key == continueKey;
                            done = true;
                        end
                    end
                end
                
                ListenChar(0);
            catch ME
                ListenChar(0);
                throw(ME);
            end
        end
        
        function h = dockedFigure(varargin)
            %dockedFigure opens a docked figure with arbitrary parameters
            %and turns off scaling warning.
            %
            %   Input:  std. figure param. (def = 'Color', [1, 1, 1])
            %   Output: figure handle
            
            if mode(nargin, 2) == 1
                error('Number of parameters must be even.');
            elseif ~Misc.isCellOf(varargin(1 : 2 : end), 'char')
                error('Odd parameters must be char arrays.');
            end
            
            set(0, 'DefaultFigureWindowStyle', 'docked');
            h = figure('Color', [1, 1, 1]);
            for i = 1 : 2 : nargin
                set(h, varargin{i}, varargin{i + 1}); 
            end
            set(0, 'DefaultFigureWindowStyle', 'normal');
            warning('Off', ['images:imshow:magnificationMustBeFit' ...'
                'ForDockedFigure']);
        end
        
        function x = flat(x)
            %flat flattens a multi-dimensional array, i.e., reshapes it as
            %a column vector.
            %
            %   Input:  arbitrary (n-dim)
            %   Output: arbitrary (1-dim)
            
            x = x(:);
        end
        
        function x = getPath(file)
            %getPath returns the full path of a file in the Matlab path.
            %
            %   Input:  char array (filename)
            %   Output: char array (path)
            
            if ~Misc.is(file, 'char', '~isempty')
                error('Input must be a non-empty char array.');
            end
            tmp = which(file);
            if isempty(tmp), error('%s not found on path.', file); end
            x = Misc.minPath(which(file));
            x = x(1 : find(x == '/', 1, 'last'));
        end
        
        function s = getSize(x)
            %getSize returns the size of a variable in bytes. Works with
            %objects.
            %
            %   Output: int scalar (num. of bytes)
            
            s = 0;
            if iscell(x)
                for i = 1 : numel(x)
                    s = s + Misc.getSize(x{i});
                end
            elseif isobject(x)
                if isstruct(x), prop = fieldnames(x);
                else, prop = properties(x);
                end
                nObj = numel(x);
                nProp = numel(prop);
                for i = 1 : nObj
                    for j = 1 : nProp
                        if nObj == 1
                            s = s + Misc.getSize(x.(prop{j}));              %indexing/arrays do not work with some objects, e.g. scatteredInterpolant
                        else
                            s = s + Misc.getSize(x(i).(prop{j}));           %for array-compatible objects
                        end
                    end
                end
            else
                tmp = whos('x');
                s = s + tmp.bytes;
            end
        end
        
        function headline(c)
            %headline prints underlined text on command window.
            %
            %   Input: char array
            
            fprintf(sprintf('%s\n%s\n', c, repmat('-', [1 numel(c)])));
        end
        
        function b = is(x, varargin)
            %is returns true if the numeric or logical input has the 
            %defined properties. In Matlab style, NaN is interpreted as 
            %numeric.
            %
            %   Input:  variable of arbitrary data type
            %               OPTIONAL, IN ARBITRARY ORDER
            %           char array
            %               'isempty'       true if empty
            %               '~isempty'      true if not empty
            %               'isnan'         true if all NaN
            %               '~isnan'        true if no NaN contained
            %               'numeric'       true if numeric (incl. NaN)
            %               'int'           true if int value (not type)
            %               'pos'           true if all > 0
            %               'neg'           true if all < 0
            %               'scalar'        true if numel == 1
            %               'multiple'      true if numel > 1
            %               'matrix'        true if numel(size) == 2
            %               'unique'        true if non-redundant
            %               'interval'      true if interval ([lb, ub])
            %               'float'         true if double or single
            %               arbitrary       true if equal class name / type
            %           cell array
            %               char arrays (accepted class names)
            %               'isa' / '~isa' + (cell array of) char array(s)
            %               'numel' / 'dim' + op. (def '==') + int array
            %               'size' + int array (wildcard = NaN)
            %               'size' + int scalar (dim. idx) + int array
            %               operator + numeric scalar
            %           1 x 2 float (interval)
            %   Output: logical scalar
            %
            %   Note:   Multi-element statements are arranged in cells;
            %               mandatory for isa, numel, dim, size, and 
            %               operators ('>', '>=', '<', '<=', '==', '~=')
            %
            %   Usage:  Misc.is(x, 'CLASSNAME', '~isempty')
            %           Misc.is(x, 'int', 'scalar', [1, 4])
            %           Misc.is(x, 'int', {'numel', 4})
            %           Misc.is(x, 'float', {'numel', '>', 2})
            %           Misc.is(x, 'float', {'numel', [2, 3]})
            %           Misc.is(x, {'size', [4, NaN]})
            %           Misc.is(x, {'size', 3, [1, 3]}, {'dim', '<', 4})
            %           Misc.is(x, 'float', {'dim', 3}, '~isnan')
            %           Misc.is(x, 'logical', 'scalar')
            %           Misc.is(x, 'pos', 'int', 'scalar')
            %           Misc.is(x, 'float', {'>=', 0.5})

            n = numel(varargin);
            operator = {'>', '>=', '<', '<=', '==', '~='};
            func = {@gt, @ge, @lt, @le, @eq, @ne};                          %function handle corresponding to operators
            b = true;
            
            for i = 1 : n
                p = varargin{i};
                c = sprintf('%s parameter is invalid.', ...
                   Misc.ordinalNumber(i + 1)); 
               if iscell(p)                                                 %parameter is cell: numel or size
                   if isempty(p)
                       error(c);                                            %#ok
                   elseif isequal(p{1}, 'isa') && numel(p) == 2 && ...
                           ~isempty(p{2})
                       if ischar(p{2})
                           b_ = isa(x, p{2});
                       elseif ~isempty(p{2}) && Misc.isCellOf(p{2}, 'char')
                           b_ = false; 
                           n = numel(p{2});
                           for j = 1 : n, b_ = b_ || isa(x, p{2}{j}); end
                       else
                           error(c);                                        %#ok
                       end
                   elseif ismember(p{1}, {'numel', 'dim'})                  %numel / dim
                       if numel(p) == 2, p = [p(1), '==', p(2)]; end        %insert default operator ==
                       [valid, j] = ismember(p{2}, operator);
                       if numel(p) == 3 && valid && isnumeric(p{3}) && ...
                               numel(p{3}) >= 1 && all(~isnan(p{3})) && ...
                               all(round(p{3}) == p{3})
                            if isequal(p{1}, 'numel')
                                b_ = any(func{j}(numel(x), p{3}));
                            else
                                b_ = any(func{j}(numel(size(x)), p{3}));
                            end
                       else
                           error(c);                                        %#ok
                       end
                   elseif isequal(p{1}, 'size') && any(numel(p) == [2, 3])  %size
                       if numel(p) == 2 && isnumeric(p{2}) && ...
                               numel(p{2}) >= 2 && any(~isnan(p{2})) && ...
                               all(round(p{2}) == p{2} | isnan(p{2}))
                           inum = find(~isnan(p{2}));
                           if numel(inum) < numel(p{2})                     %wildcard is used: test only non-NaN values, do not test number of dimensions
                               b_ = true;
                               for k = inum(:)'
                                   b_ = b_ && size(x, k) == p{2}(k);
                               end
                           else
                               b_ = isequal(size(x), p{2}(:)');             %no wildcard: check if given size array is an exact match
                           end
                       elseif numel(p) == 3 && isnumeric(p{2}) && ...
                               p{2} > 0 && round(p{2}) == p{2} && ...
                               numel(p{2}) == 1 && ...
                               isnumeric(p{3}) && p{2} > 0 && ...
                               all(round(p{3}) == p{3}) && ...
                               numel(p{3}) >= 1                             %test if specified dimensions has (one of) given value(s)
                           b_ = any(size(x, p{2}) == p{3}(:));
                       else
                           error(c);                                        %#ok
                       end
                   elseif isnumeric(x) && ismember(p{1}, operator) && ...
                           numel(p) == 2 && isnumeric(p{2}) && ...
                           numel(p{2}) == 1                                 %operator
                       [~, j] = ismember(p{1}, operator);
                       b_ = all(func{j}(x(:), p{2}));
                   else
                       error(c);                                            %#ok
                   end
               elseif ischar(p)                                             %character array
                   if isequal(p, 'isempty')
                       b_ = isempty(x);
                   elseif isequal(p, '~isempty')
                       b_ = ~isempty(x);
                   elseif isequal(p, 'scalar')
                       b_ = numel(x) == 1;
                   elseif isequal(p, 'multiple')
                       b_ = numel(x) > 1;
                   elseif isequal(p, 'matrix')
                       b_ = numel(size(x)) == 2;
                   elseif isequal(p, 'isnan')
                       b_ = isnumeric(x) && all(isnan(x(:)));
                   elseif isequal(p, '~isnan')
                       b_ = isnumeric(x) && all(~isnan(x(:)));
                   elseif isequal(p, 'numeric')
                       b_ = isnumeric(x);
                   elseif isequal(p, 'int')
                       b_ = isnumeric(x) && all(round(x(:)) == x(:));
                   elseif isequal(p, 'float')
                       b_ = isfloat(x);
                   elseif isequal(p, 'unique')
                       b_ = (~iscell(x) || Misc.isCellOf(x, 'char')) && ...
                           numel(x(:)) == numel(unique(x(:)));
                   elseif isequal(p, 'interval')
                       b_ = isnumeric(x) && numel(x) == 2 && x(1) <= x(2);
                   elseif isequal(p, 'pos')
                       b_ = isnumeric(x) && all(x(:) > 0);
                   elseif isequal(p, 'neg')
                       b_ = isnumeric(x) && all(x(:) < 0);
                   else
                       b_ = isequal(class(x), p);
                   end
               elseif isnumeric(p) && numel(p) == 2 && p(1) <= p(2) && ...
                       all(~isnan(p))                                       %interval
                   b_ = isnumeric(x) && all(x(:) >= p(1) & x(:) <= p(2));
               else 
                   error(c);                                                %#ok
               end
               b = b && b_;
            end
        end
        
        function [b, i] = isCellOf(x, type)
            %isCellOf retuns true if input is a cell that contains the 
            %specified data type(s) only.
            %
            %   Input:  Input of arbitrary format
            %           (cell array of) char array (accepted data type(s))
            %   Output: logical scalar
            %           int scalar (index of first invalid cell)

            if ~(ischar(type) || Misc.isCellOf(type, 'char'))
                error(['Second parameter must be a (cell array of) ' ...
                    'char array(s).']);
            end
            
            b = false;
            if ischar(type), type = {type}; end
            if ~iscell(x)
                return
            end
            for i = 1 : numel(x)
                valid = false;
                for j = 1 : numel(type)
                    valid = valid | isa(x{i}, type{j});
                end
                if ~valid, return; end
            end
            b = true;
            if nargout == 2 && b, i = []; end
        end
        
        function [b, idx] = isInCell(x, c)
            %isInCell returns true if the first parameter is contained in 
            %the second parameter.
            %
            %   Input:  arbitrary data type (to be checked)
            %           cell array (accepted values)
            %   Output: logical scalar
            %           int array (indices of equal cell elements)
        
            if ~Misc.isCellOf(c, 'char')
                error('Second parameter must be a cell array.');
            end
            
            b = false;
            idx = [];
            for i = 1 : numel(c)
                if isequal(x, c{i})
                    b = true;
                    if nargout == 2, idx(end + 1) = i;                      %#ok
                    else, return;
                    end
                end
            end
        end
            
        function l = isValidFilename(x)
            %isValidFilename returns true if a char array is a valid 
            %filename (without type specifier), i.e. does not contain
            %forbidden characters.
            %
            %   Input:  char array
            %   Output: logical scalar
            
            l = ischar(x) && ~isempty(x) && ...
                ~any(ismember('/\?%*:|"<> ', x));
        end

        function l = isValidFoldername(x)
            %isValidFoldername returns true if a char array is a valid 
            %foldername (can be a relative or absoulte path). It is not 
            %checked whether the folder or a part of it exists. However, if
            %a root disk is contained, the existence of that disk is 
            %checked.
            %
            %   Input:  char array
            %   Output: logical scalar
            
            l = ischar(x) && ~isempty(x) && ~any(ismember('?%*|"<> ', x));
            if ~l, return; end
            
            %check slashes
            iSlash = find(ismember(x, '/') | ismember(x, '\'));
            if ~isempty(iSlash)
                l = iSlash(1) ~= 1 && all(diff(iSlash) > 1);                %no first slash, no double slashes allowed
                if ~l, return; end
            end
            
            %check colon
            [isColon, iColon] = ismember(':', x);
            if isColon
                if ~isequal(iColon, 2), l = false;                          %colon at wrong position
                else, l = exist(x(1 : 3), 'dir') == 7;                      %check disk
                end
            end
        end
        
        function x = load(filename, type, suppressOutput, ...
                singleObj, memFriendly)
            %load loads a file and returns the object / array of the
            %demanded type. Throws error if no or multiple variable
            %matching the type are contained.
            %
            %   Input:  char array (filename)
            %           (cell array of) char array(s) (valid type(s))
            %           logical scalar (true = suppress output on command 
            %               line, def = false)
            %           logical scalar (true = single obj.; def = true)
            %           logical scalar (true = load memory friendly (slow),
            %               false = tmp. load file (fast); def = false)
            %   Output: object of demanded type
            
            if nargin < 3, suppressOutput = false; end
            if nargin < 4, singleObj = true; end
            if nargin < 5, memFriendly = false; end
            if ~Misc.is(filename, 'char', '~isempty')
                error('First parameter must be a non-empty char array.');
            elseif ~Misc.is(type, 'char', '~isempty')
                error('Second parameter must be a non-empty char array.');
            elseif ~Misc.is(suppressOutput, 'logical', 'scalar')
                error('Third parameter must be a logical scalar.');
            elseif ~Misc.is(singleObj, 'logical', 'scalar')
                error('Fourth parameter must be a logical scalar.');
            elseif ~Misc.is(memFriendly, 'logical', 'scalar')
                error('Fifth parameter must be a logical scalar.');
            end
            
            x = [];
            if ischar(type), type = {type}; end
            if ~suppressOutput, fprintf('Loading %s... ', filename); end
            strNo = 'No type matching variable found.';
            strAmb = 'Multiple type matching variables found.';
            strArr = 'Type matching variable has multiple elements.';
            if memFriendly
                tmp = whos(matfile(filename));                              %read properties of file variables without actually loading them into memory
                valid = ismember(tmp.class, type);                          %true = variable matches type
                n = sum(valid);
                if n == 0, error(strNo);
                elseif n > 1, error(strAmb);
                elseif singleObj && prod(x.size(valid)) > 1, error(strArr);
                end
                x = load(filename, x.name(valid));                          %load the matching variable
            else
                tmp = load(filename);
                for field = fieldnames(tmp)'
                    valid = false;
                    for i = 1 : numel(type)
                        if isa(tmp.(field{1}), type{i})
                            valid = true; 
                            break; 
                        end
                    end
                    if valid
                        if isempty(x), x = tmp.(field{1});
                        else, error(strAmb);
                        end
                    end
                end
                if isempty(x), error(strNo);
                elseif singleObj && numel(x) > 1, error(strArr); 
                end
            end
            if ~suppressOutput, fprintf('done.\n'); end
        end           
        
        function x = minPath(x)
            %minPath returns minimal folder path (cleans up '..') and
            %replaces single or mutliple '\' by '/'.
            %
            %   Input:  char array (relative path)
            %   Output  char array (full path)
            
            if ~ischar(x), error('Input must be a char array.'); end
            
            x(x == '\') = '/';
            i = strfind(x, '..');
            for k = 1 : numel(i)
                j = find(x == '/') - i(k);
                j = j(j < 0) + i(k);
                x(j(end - 1) : (j(end) + 2)) = [];                          %remove '..' and previous folder
            end
        end

        function c = ordinalNumber(x, format)
            %ordinalNumber returns a char array with the ordinal number
            %corresponding to a given int scalar. Values below 20 will be
            %expressed as a letter-only, upper-case word unless the second 
            %parameter defines another format, values >= 20 as numeric with
            %suffix.
            %
            %   Input:  int scalar
            %           char aray (lower, upper, or numeric, def = upper) 
            %   Output: char array
            
            validFormat = {'lower', 'upper', 'numeric'};
            if nargin == 1, format = validFormat{2}; end
            if ~(isscalar(x) && x > 0 && round(x) == x)                     %do not use Misc.is here, otherwise infinite loop
                error('First parameter must be a positive int scalar.');
            elseif ~(ischar(format) && Misc.isInCell(format, validFormat))
                error('Second parameter must be %s.', ...
                    Misc.cellToList(validFormat));
            end
            
            if x < 20 && ~isequal(format, 'numeric')
                c = {'First', 'Second', 'Third', 'Fourth', 'Fifth', ...
                    'Sixth', 'Seventh', 'Eighth', 'Ninth', 'Tenth', ...
                    'Eleventh', 'Twelfth', 'Thirteenth', 'Fourteenth', ...
                    'Fifteenth', 'Sixteenth', 'Seventeenth', ...
                    'Eighteenth', 'Nineteenth'};
                c = c{x};
                if isequal(format, 'lower'), c(1) = c(1) + 32; end
            else
                if mod(x, 10) == 1, c = 'st';
                elseif mod(x, 10) == 2, c = 'nd';
                elseif mod(x, 10) == 3, c = 'rd';
                else, c = 'th';
                end
                c = sprintf('%d%s', x, c);
            end
        end
        
        function varargout = repeatOnError(command, varargin)
            %repeatOnError executes an one-line command. If an error occurs
            %the user will be asked to repeat the execution. 
            %
            %   Input:  char array (command)
            %   Output: arbitrary (multiple output possible)
            %
            %   For convenience, you can call your input parameters 'x'
            %   instead of 'varargin', and drop the terminal semicolon.
            %
            %       Misc.repeatOnError('disp(''Test'')')
            %
            %       myOutput = Misc.repeatOnError('1 + 1');
            %
            %       myInput = 2;
            %       myOutput = Misc.repeatOnError('x{1} ^ 2', myInput);
            %
            %       [myOutput1, myOutput2] = Misc.repeatOnError(...
            %           'find([1 0 0 1])');
            
            x = varargin;                                                   %#ok
            if command(end) ~= ';', command(end + 1) = ';'; end
            
            completed = false;
            while ~completed
                try
                    if nargout == 0
                        eval(command);
                    else
                        outStr = '[';
                        for i = 1 : nargout
                            outStr = sprintf('%stmp{%d}', outStr, i);
                            if i < nargout
                                outStr = sprintf('%s, ', outStr);
                            end
                        end
                        eval(sprintf('%s] = %s', outStr, command));
                        varargout = tmp;
                    end
                    completed = true;
                catch ME
                    fprintf('%s\n', ME.message);
                    if ~Menu.basic('Try again', 'response', 'yn', ...
                            'prompt', '? ', 'default', 'y')
                        throw(ME);
                    end
                end
            end
        end
        
        function b = splitDistribution(x, nband)
            %splitDistribution returns the value which splits a
            %bimodally distributed array into two unimodally distributed
            %arrays.
            %
            %   Input:  Floating point array
            %           Scalar (max. number of bands; optional)
            %   Output: Scalar
            
            if nargin < 2, nband = 256; end
            
            if ~isnumeric(x)
                error('First parameter must be numeric.');
            elseif ~(Misc.is(nband, 'pos', 'int', 'scalar', ...
                    {'>=', 4}) && mod(nband, 2) == 0)
                error(['Second parameter must be a positive ' ...
                    'even scalar >= 4.']);
            end
            
            x = double(x(:));
            [count, center] = hist(x, nband);
            nx = numel(x);
            nthr = nx * .01;                                                %a distribution segment must contain at least 1% of values
            
            completed = false;
            while ~completed
                d = diff(count);
                se = find(d(1 : end - 1) < 0 & d(2 : end) >= 0);            %index of slope end
                ss = find(d(1 : end - 1) <= 0 & d(2 : end) > 0);            %index of slope start
                imin = [];                                                  %index of minimum
                nmin = 0;                                                   %number of minima found
                for i = 1 : numel(se)                                       %pass slope ends. Minima are between slop ends and starts
                    j = find(ss >= se(i), 1, 'first');                      %index of next slope start index
                    if isempty(j)
                        break;
                    elseif i == numel(se) || se(i + 1) >= ss(j)             %if there is not a slope end before the next slope start (e.g. steps downward)
                        nmin = nmin + 1;
                        imin(nmin) = round((se(i) + ss(j)) / 2);            %#ok. Minimum is between slope end and slope start.
                    end
                end

                %filter out too small distribution segments. Useful to get
                %rid of irrelevant bounces, e.g. hot pixels.
                itmp = [1, imin, numel(count)];                             %indices of segment boundaries
                i = 1;
                while i <= nmin + 1
                    nsegment = sum(count(itmp(i) : itmp(i + 1)));           %number of values in size of segment
                    if nsegment < nthr                                      %if too small
                        if i > nmin
                            i = i - 1;                                      %if this is the final segment boundary, appply changes to the previous segment
                        end
                        itmp(i + 1) = [];                                   %remove segment upper boundary
                        imin(i) = [];                                       %#ok, Remove minimum
                        nmin = nmin - 1;                                    %count down minima
                    else
                        i = i + 1;
                    end
                end
                
                if nmin <= 1
                    completed = true;
                else
                    count = sum(count([1 : 2 : end; 2 : 2 : end]));
                    center = mean(center([1 : 2 : end; 2 : 2 : end]));
                end
            end
            
            if nmin == 1
                b = center(imin);
            elseif nmin == 0
                error('No local minimum found.');
            elseif nmin > 1
                error('Multiple minima found.');
            end
        end
       
        function x = structToCell(s)
            %structToCell converts a struct into a cell according to the
            %outline {fieldname, value, fieldname, value, ...}.
            %
            %   Input:  struct
            %   Output: cell array
            
            if ~Misc.is(s, 'struct', 'scalar')
                error('Input must be a struct.');
            end
            field = fieldnames(s);
            n = numel(field);
            x = cell(1, n * 2);
            x(1 : 2 : n * 2) = field;
            for i = 1 : n, x(i * 2) = {s.(field{i})}; end
        end
        
        function dim = subplotDim(n, nMaxSingleRow)
            %sublotDim returns visually pleasant subplot dimensions for a
            %given number of plots. 
            %
            %   Input:  int scalar (number of plots)
            %           int scalar (max. number of plots to be shown in a
            %               single row if input is prime, def = 5)
            %   Output: 1 x 2 int (subplot dimensions, dim: rows, cols)
        
            if nargin < 2, nMaxSingleRow = 5; end
            if ~Misc.is(n, 'int', 'scalar', 'pos')
                error('First parameter must be a positive int scalar.');
            elseif ~Misc.is(nMaxSingleRow, 'int', 'scalar', 'pos')
                error('Second parameter must be a positive int scalar.');
            end
                
            f = factor(n);                                                  %get prime factors of n
            nf = numel(f);                                                  %number of prime factors
            if nf == 1
                if n <= nMaxSingleRow, dim = [1, n];
                else, dim = Misc.subplotDim(n + 1);
                end
            elseif nf == 2
                dim = sort(f);
            else
                p = unique(f(perms(1 : nf)), 'rows');                       %all unique permutations of factors
                ne = floor(nf / 2);                                         %number of elements in a row of p which corresponding prime factors are to be multiplied
                d = inf;
                for j = 1 : ne
                    tmp = sort([prod(p(:, 1 : j), 2), ...
                        prod(p(:, j + 1 : end), 2)], 2);                    %split up factors in two groups and multiply factors in each group, then sort them result
                    dtmp = tmp(:, 2) - tmp(:, 1);                           %difference between both subplot dimensions
                    [dtmp, imin] = min(dtmp);
                    if dtmp < d
                        dim = tmp(imin, :);
                        d = dtmp;
                    end
                end
            end
        end
       
        function waitForEnter(c)
            %waitForEnter disables the keyboard and waits until the user 
            %pressed Enter.
            %
            %   Input:  char array (to be printed on command window; opt.)
            
            if nargin == 0, c = ''; end
            if ~ischar(c), error('Input must be a char array.'); end
            
            try
                ListenChar(2);
                while KbCheck, end                                          %wait until keyboard buffer is empty
                input(c, 's');
                ListenChar(0);
            catch ME
                ListenChar(0);
                throw(ME);
            end
        end
        
        function [key, rt] = waitForKey(keys)
            %waitForKey disables keyboard and waits until user presses one
            %of a set of keys. Returned is the key code and the reaction 
            %time.
            %
            %   Input:  uint8 array (key code of the accepted keys; opt.)
            %   Output: uint8 scalar (key code of the key pressed)
            %           float scalar (reaction time in sec)
            
            if nargin == 1
                if ~Misc.is(keys, 'int', [0, 255])
                    error('Input must be a uint8 array.');
                end
                keys = keys(:);
            end
            
            %clear buffer
            while KbCheck, end
            done = false;
            
            ListenChar(2);
            rt(1) = GetSecs;
            while ~done
                [keydown, rt(2), keycode] = KbCheck;
                if keydown
                    key = find(keycode, 1, 'first');
                    if nargin == 1
                        done = any(key == keys(:));
                    else
                        done = true;
                    end
                end
            end
            ListenChar(0);
            
            rt = diff(rt);
        end
    end
end

