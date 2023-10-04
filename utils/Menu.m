classdef Menu
    %Menu provides static methods for basic user interaction via command 
    %window.
    %
    %   static methods
    %       basic
    %       file
    %       folder
    
    methods (Static)
        function varargout = basic(varargin)
            %basic: Provides convenient functionality to collect user
            %input by single-item requests / questions or multi-item menus.
            %
            %Examples for single-item requests and questions
            %   >> Do you want to continue (default = y)?
            %   >> Number of measurements (default = 5):
            %   >> Filename of database (default = data/db.mat):
            %
            %Examples for a multi-item menus
            %   >> (1) Read (default)
            %   >> (2) Write
            %   >> (3) Append
            %
            %   >> (1) Camera (default)
            %   >> (2) Spectrometer (default)
            %   >> (3) Hyperspectral camera
            %
            %Input can be a char array or numeric. In case of multi-item
            %requests, only item indices are accepted as input.
            %
            %
            %INPUT
            %-----
            %The first input parameter is a char array (for a single item)
            %or a cell array of char arrays (for multiple menu items). The 
            %following optional parameter pairs are accepted:
            %
            %   default:    Specifies a default value for the response.
            %               If the user input is empty, the default value
            %               will be returned, and the default value will be
            %               auto-filled into the line of user input.
            %               For single-item requests, the default value
            %               will be automatically appended to the statement
            %               or question as '(default = ...)'.
            %               For multi-item menus, the postfix '(default)'
            %               will be appended to the default items
            %
            %   response    Specifies response properties. Value can be a
            %               (cell array of) char array(s):
            %                   empty       Empty input is accepted
            %                   yn          Only 'y' or 'n' is accepted
            %                               (or empty input, if a default
            %                               is defined). Valid user input
            %                               is 'y' / 'n' only. Default
            %                               values are 'y' / 'n', but can
            %                               be defined as true / false as
            %                               well
            %                   numeric     Only numeric input is accepted.
            %                               Automatically set if default is
            %                               numeric. Multi-item menus are
            %                               always numeric
            %                   positive    Only positive numeric input is
            %                               accepted. Single-item requests 
            %                               only
            %                   integer     Only int input is accepted
            %                   interval    Input must be in interval.
            %                               Two element interval must
            %                               follow 'interval' keyword.
            %                               Single-item requests only
            %                   dim         Only input with dimensions dim
            %                               is accepted. Dimension array
            %                               must follow 'dim' keyword.
            %                               Automatically set if default is
            %                               numeric. Single-item requests 
            %                               only
            %                   scalar      Equivalent to {'dim', [1 1]}.
            %                               Single-item requests only
            %                   multiple,
            %                   multi       Multiple selection is accepted
            %                               (multi-item menus only.
            %                               Automatically set if default
            %                               contains more than one value
            %                   redundant   Allows redundant selection in
            %                               multi-item menus (by default,
            %                               only unique values are
            %                               returned)
            %
            %   prompt      Specifies the prompt that prepends the user
            %               input. For both single and multi-item requests,
            %               the default prompt is '\n>> ' (the standard
            %               command window prompt)
            %
            %NOTE: Some response combinations are contradicting each other
            %and will throw errors, e.g. {'numeric' 'yn'}.
            %
            %
            %OUTPUT
            %------
            %Single-item request or question:
            %   The user input is returned. If a default was defined and
            %   and the input was empty, the default value will be
            %   returned. If 'numeric' was defined, the output will be
            %   numeric as well. If 'yn' was defined, the output will be
            %   logical. Otherwise the output is a char array.
            %
            %Multi-item menu:
            %   Two values are returned:
            %       - selected item (as a char array)
            %       - item index
            %   If multiple was selected, a cell with all selected items
            %   and an array of indices will be returned.
            %
            %
            %EXAMPLES
            %--------
            %Single-item requests and questions:
            %   x = Menu.basic('Do you want to continue', ...
            %           'default', 'y', 'response', 'yn', 'prompt', '? ');
            %   x = Menu.basic('Number of triggers', 'default', 5, ...
            %           'response', {'scalar' 'positive' 'integer'}, ...
            %           'prompt', ': ');
            %   x = Menu.basic('Filename', 'default', 'db.mat', ...
            %           'prompt', ': ');
            %
            %Multi-item requests and questions:
            %   [item, idx] = Menu.basic({'Read' 'Write'}, 'default', 1);
            %   [item, idx] = Menu.basic({'Camera' 'Spectrometer' ...
            %           'Hyperspectral camera'}, 'response', 'multi', ...
            %           'default', [1 2]);
            
            if nargin == 0
                error('No item(s) defined.');
            end
            if ~mod(nargin, 2)
                error(['Even number of items. First parameter must be ' ...
                    'a (cell array of) char array(s). Additional ' ...
                    'parameters must be defined in pairs (key, value).']);
            end
            
            c = varargin{1};
            if iscell(c)
                nitem = numel(c);
            elseif ischar(c)
                nitem = 1;
            else
                error(['First parameter must be a (cell array of) ' ...
                    'char array(s).']);
            end
            
            default = [];
            prompt = '\n>> ';
            
            if ischar(c)                                                    %single item
                if nargout > 1, error('Too many output parameters.'); end
                
                for i = 2 : 2 : nargin
                    if isequal(varargin{i}, 'default')
                        default = varargin{i + 1};
                        
                    elseif isequal(varargin{i}, 'response')
                        if ~(ischar(varargin{i + 1}) || ...
                                Misc.isCellOf(varargin{i + 1}, 'char'))
                            error(['Parameter response must be a ' ...
                                '(cell array of) char array(s).']);
                        end
                        
                        tmp = varargin{i + 1};
                        if ischar(tmp), tmp = {tmp}; end
                        
                        j = 1;
                        while j <= numel(tmp)
                            if isequal(tmp{j}, 'yn')
                                flag_yn = true;
                            elseif isequal(tmp{j}, 'empty')
                                flag_empty = true;
                            elseif Misc.isInCell(tmp{j}, {'numeric', ...
                                    'positive', 'integer', 'interval'})
                                flag_numeric = true;
                                if isequal(tmp{j}, 'positive')
                                    flag_positive = true;
                                end
                                if isequal(tmp{j}, 'integer')
                                    flag_integer = true;
                                end
                                if isequal(tmp{j}, 'interval')
                                    j = j + 1;
                                    if numel(tmp) < j
                                        error(['Interval parameter is ' ...
                                            'missing.']);
                                    end
                                    if ~Misc.is(tmp{j}, 'interval')
                                        error(['Invalid interval ' ...
                                            'parameter.']);
                                    end
                                    interval = tmp{j};
                                end
                            elseif Misc.isInCell(tmp{j}, {'dim', 'scalar'})
                                if isequal(tmp{j}, 'dim')
                                    j = j + 1;
                                    if numel(tmp) < j
                                        error(['Size parameter is ' ...
                                            'missing.']);
                                    end
                                    dim = tmp{j};
                                    if ~Misc.is(dim, 'int', 'pos', ...
                                            'multiple')
                                        error('Invalid size interval.')
                                    end
                                else
                                    flag_numeric = true;
                                    dim = [1 1];
                                end
                            else
                                error(['Unknown value %s for ' ...
                                    'parameter %s.'], tmp{j}, varargin{i});
                            end
                            j = j + 1;
                        end
                        
                    elseif isequal(varargin{i}, 'prompt')
                        if ~ischar(varargin{i + 1})
                            error('Prompt must be a char array.');
                        end
                        prompt = varargin{i + 1};
                        
                    else
                        error('Unknown parameter %s', varargin{i});
                    end
                end
                
                if ~isempty(default)
                    if exist('flag_numeric', 'var')
                        if isnumeric(default) ~= flag_numeric
                            error(['Data format of default and ' ...
                                'requested output format do not match.']);
                        end
                    else
                        flag_numeric = isnumeric(default);
                    end
                    if exist('flag_empty', 'var')
                        error(['Empty input allowed and default ' ...
                            'value defined.']);
                    else
                        flag_empty = false;
                    end
                    if exist('dim', 'var')
                        if ~isequal(size(default), dim)
                            error(['Dim does not match dimensions ' ...
                                'of default.']);
                        end
                    elseif isnumeric(default)
                        dim = size(default);
                    end
                    if exist('flag_yn', 'var')
                        if ~(numel(default) == 1 && ...
                                (islogical(default) || ...
                                any(default == [0, 1]) || ...
                                any(default == 'yn')))
                            error(['Yes/no format conflicts with ' ...
                                'default value.']);
                        elseif exist('dim', 'var')
                            error('Yes/no format conflicts with dim.');
                        elseif flag_numeric
                            error(['Yes/no format conflicts with ' ...
                                'numeric flag.']);
                        elseif islogical(default) || any(default == [0, 1])
                            if default, default = 'y';
                            else, default = 'n'; end
                        end
                    else
                        flag_yn = false;
                    end
                else
                    if ~exist('flag_numeric', 'var')
                        flag_numeric = false;
                    end
                    if ~exist('flag_empty', 'var')
                        flag_empty = false;
                    end
                    if ~exist('flag_yn', 'var')
                        flag_yn = false;
                    end
                end
                
                if flag_numeric
                    if ~exist('flag_positive', 'var')
                        flag_positive = false;
                    elseif flag_positive && exist('interval', 'var') && ...
                        any(interval <= 0)
                        error(['Positivity defined, but defined ' ...
                            'interval contains values <= 0.']);
                    end
                    if ~exist('flag_integer', 'var')
                        flag_integer = false;
                    end
                end
                
                if isempty(default)
                    request = sprintf('%s', sprintf(c));
                else
                    if flag_numeric
                        if numel(default) == 1
                            request = sprintf('%s (default = %d)', ...
                                sprintf(c), default);
                        else
                            request = sprintf(['%s (default = [%d' ...
                                repmat(' %d', [1 size(dim, 2) - 1]) ...
                                '])'], sprintf(c), default);
                        end
                    else
                        request = sprintf('%s (default = %s)', ...
                            sprintf(c), default);
                    end
                end
                if contains(prompt, '\n')
                    fprintf(request);
                else
                    prompt = [request prompt];
                end
                
                userInput = '';
                
                while isempty(userInput)
                    while KbCheck, end                                      %wait until keyboard buffer is empty to avoid unintentional selection / confirmation
                    if flag_numeric
                        userInput = Menu.numericInput(prompt);
                    else
                        userInput = input(sprintf('%s', prompt), 's');
                    end
                    
                    if isempty(userInput)
                        if ~isempty(default)
                            userInput = default;
                            if flag_numeric
                                fprintf('\b%d\n', default);
                            else
                                fprintf('\b%s\n', default);
                            end
                        elseif flag_empty
                            break;
                        end
                    end
                    
                    if flag_numeric
                        invalid = [flag_positive && any(userInput <= 0) ...
                            flag_integer && ~Misc.is(userInput, 'int') ...
                            exist('interval', 'var') && ...
                            ~Misc.is(userInput, interval)];
                        if any(invalid)
                            if invalid(1)
                                fprintf(['Input must be positive. ' ...
                                    'Try again.\n']);
                            elseif invalid(2)
                                fprintf(['Input must be integer. ' ...
                                    'Try again.\n']);
                            elseif invalid(3)
                                fprintf(['Input must be in [%d %d]. ' ...
                                    'Try again.\n'], interval);
                            end
                            userInput = [];
                            continue
                        end
                    end
                            
                    if exist('dim', 'var') && ...
                            ~isequal(size(userInput), dim)
                        fprintf(sprintf(['Input dimensions must be [%d' ...
                            repmat(' %d', [1 size(dim, 2) - 1]) ']. ' ...
                            'Try again.\n'], dim));
                        userInput = '';
                    end
                    
                    if flag_yn
                        if isequal(userInput, 'y')
                            userInput = true;
                        elseif isequal(userInput, 'n')
                            userInput = false;
                        else
                            userInput = '';
                            fprintf('Please enter y or n. Try again.\n');
                        end
                    end
                end
                varargout{1} = userInput;
                
            elseif iscell(c)                                                %one or multiple items
                if nargout > 2, error('Too many output parameters.'); end
                
                flag_empty = false;
                flag_unique = true;
                
                for i = 2 : 2 : nargin
                    if isequal(varargin{i}, 'response')
                        if ~(ischar(varargin{i + 1}) || ...
                                Misc.isCellOf(varargin{i + 1}, 'char'))
                            error(['Parameter response must be a ' ...
                                '(cell array of) char array(s).']);
                        end
                        tmp = varargin{i + 1};
                        if ischar(tmp), tmp = {tmp}; end
                        for j = 1 : numel(tmp)
                            if Misc.isInCell(tmp{j}, {'multiple', 'multi'})
                                flag_multiple = true;
                            elseif isequal(tmp{j}, 'empty')
                                flag_empty = true;
                            elseif isequal(tmp{j}, 'redundant')
                                flag_unique = false;
                            else
                                error(['Unknown value %s for ' ...
                                    'parameter %s.'], tmp{j}, varargin{i});
                            end
                        end
                        
                    elseif isequal(varargin{i}, 'default')
                        if ~isnumeric(varargin{i + 1})
                            error('Default value must be numeric.');
                        end
                        
                        default = varargin{i + 1};
                        
                        if ~Misc.is(default, 'int', [1, nitem])
                            error(['Default values must be an int ' ...
                                'array in [1 %d].'], nitem);
                        end
                        
                    elseif isequal(varargin{i}, 'prompt')
                        if ~ischar(varargin{i + 1})
                            error('Prompt must be a char array.');
                        end
                        prompt = varargin{i + 1};
                        
                    else
                        error('Unknown parameter %s.', varargin{i});
                    end
                end
                
                ndefault = numel(default);
                selection = [];
                item = {};
                
                if ~isempty(default)
                    if flag_empty
                        error(['Empty input accepted but default ' ...
                            'value defined.']);
                    elseif ndefault > 1
                        if exist('flag_multiple', 'var')
                            if ~flag_multiple
                                error(['Multiple input not accepted ' ...
                                    'but multiple default values ' ...
                                    'defined.']);
                            end
                        else
                            flag_multiple = true;
                        end
                    end
                end
                if ~exist('flag_multiple', 'var')
                    flag_multiple = false;
                end
                
                for i = 1 : nitem
                    if any(default == i)
                        fprintf('(%i) %s (default)\n', i, c{i});
                    else
                        fprintf('(%i) %s\n', i, c{i});
                    end
                end
                fprintf('\b');
                
                while isempty(selection)
                    selection = Menu.numericInput(prompt);
                    if flag_unique, selection = unique(selection); end
                    nselection = numel(selection);
                    
                    if isempty(selection)
                        if flag_empty, break; end
                        
                        if ndefault > 0
                            for i = 1 : ndefault
                                item{i} = c{default(i)};                    %#ok
                            end
                            selection = default;
                            
                            %fill command prompt with default value(s)
                            if ndefault > 1
                                if all(diff(default) == 1)
                                    strDefault = sprintf('%d:%d', ...
                                        default([1 end]));
                                else
                                    strDefault = sprintf('[%d', ...
                                        default(1));
                                    for i = 2 : numel(default)
                                        strDefault = sprintf('%s %d', ...
                                            strDefault, default(i));
                                    end
                                    strDefault = sprintf('%s]', ...
                                        strDefault);
                                end
                                fprintf('\b%s\n', strDefault);
                            else
                                fprintf('\b%d\n', default);
                            end
                        end
                    elseif ~Misc.is(selection, [1, nitem])
                        fprintf('Invalid selection index. Try again.\n');
                        selection = [];
                    elseif nselection > 1 && ~flag_multiple
                        fprintf(['Multiple selection is not accepted. ' ...
                            'Try again.\n']);
                        selection = [];
                    else
                        item = c(selection);
                    end
                end
                
                if numel(item) == 1, varargout{1} = cell2mat(item);
                else, varargout{1} = item;
                end
                varargout{2} = selection;
            end
        end
        
        function x = numericInput(prompt)
            invalid = true;
            while invalid
                strx = input(sprintf('%s', prompt), 's');
                x = str2num(strx);                                          %#ok
                invalid = isempty(x) && numel(strx) > 0 || ~isreal(x);
                if invalid
                    fprintf('Invalid input. Try again.\n');
                end
            end
        end
        
        function x = file(folder, type, flag_multiple)
            %file: Returns filename(s) (incl. full path) which the user
            %interactively selects via a console based menu.
            %
            %   Input:  char array (start folder; def: '.')
            %           char array (file type; def: '')
            %           logical scalar (true = multi-select; def = false)
            %   Output: (cell array of) of char array(s)
            
            if nargin > 0
                if ~ischar(folder)
                    error('Second parameter must be a char array.')
                end
                folder = Misc.minPath(folder);
            else
                folder = Misc.minPath('.');
            end
            
            if nargin > 1
                if ~ischar(type)
                    error('Second parameter must be a char array.')
                end
                if type(1) ~= '.'
                    type = ['.' type];
                end
            else
                type = '';
            end
            
            if nargin > 2
                if ~Misc.is(flag_multiple, 'logical', 'scalar')
                    error('Third parameter must be a logical scalar.')
                end
            else
                flag_multiple = false;
            end
            
            done = false;
            while ~done
                content = dir(folder);
                c = {};
                isdir = [];
                for h = [true false]                                        %directory / file
                    for i = 2 : numel(content)
                        if content(i).isdir == h && ...
                                (h || isempty(type) || isequal(...
                                content(i).name(end - 3 : end), type))
                            if h, c{end + 1} = ['<' content(i).name '>'];   %#ok
                            else c{end + 1} = content(i).name;              %#ok
                            end
                            isdir(end + 1) = h;                             %#ok
                        end
                    end
                end
                
                fprintf('%s\n', folder);
                if flag_multiple
                    [tmp, i] = Menu.basic(c, 'response', 'multi');
                    if numel(i) > 1 && any(isdir(i))
                        fprintf(['Multiple selection is not allowed ' ...
                            'for folders.\n\n']);
                        continue;
                    end
                else
                    [tmp, i] = Menu.basic(c);
                end
                
                if numel(i) == 1 && isdir(i)                                %directory was selected
                    folder = Misc.minPath(sprintf('%s/%s', folder, ...
                        tmp(2 : end - 1)));
                    if folder(end) == ':'
                        folder = sprintf('%s/', folder);
                    end
                    fprintf('\n');
                else
                    if numel(i) == 1
                        x = sprintf('%s/%s', folder, tmp);
                    else
                        x = cell(1, numel(i));
                        for i = 1 : numel(i)
                            x{i} = sprintf('%s/%s', folder, tmp{i});
                        end
                    end
                    done = true;
                end
            end
        end

        function x = folder(x)
            %folder: Returns directory name which the user interactively 
            %selects via a console based menu.
            %
            %   Input:  char array (start folder; def: '.')
            %   Output: char array 
            
            if nargin > 0, x = Misc.minPath(x);
            else, x = Misc.minPath('.');
            end
            
            done = false;
            while ~done
                c = {};
                content = dir(x);
                for i = 2 : numel(content)
                    if content(i).isdir
                        c{end + 1} = sprintf('<%s>', content(i).name);      %#ok
                    end
                end
                
                fprintf('%s\n', x);
                tmp = Menu.basic(c, 'response', 'empty');
                if ~isempty(tmp)
                    x = Misc.minPath(sprintf('%s/%s', x, ...
                        tmp(2 : end - 1)));
                    fprintf('\n');
                else
                    done = true;                                            %selection is completed when folder is reached and user selects nothing
                end
            end
        end
    end
end

