classdef (Abstract) FileBase < matlab.mixin.Heterogeneous & handle
    %FileBase is an abstract base class for classes which instances are 
    %supposed to be saved. Base classes are matlab.mixin.Heterogeneous and 
    %handle.
    %
    %   properties
    %       time                    DateTime object
    %       folder                  char array
    %       filename                char array
    %       reducible               cell array (reducible property names)
    %
    %   methods
    %       FileBase                Constructor
    %       getRelPath              Returns (cell array of) char array(s) e
    %                                   (path rel. to MATLAB directory)
    %       getAbsPath              Returns char array array (abs. path)
    %       getUnreduced            Returns FileBase array
    %       reduce                  Replaces properties listed in property 
    %                                   reducible with their relative path
    %       isReducible             Returns log. sc. (true = in reducible)
    %       load                    Loads properties listed in reducible
    %       save                    Replaces properties listed in reducible
    %                                   with rel. paths and saves object
    %
    %   abstract methods
    %       toggle                  Toggles property listed in reducible
    %
    %   static methods
    %       getRoot                 Returns char array (path to MATLAB dir)
    %       removeRoot              Returns char array (path without root)
    %       appendToRoot            Returns char array
    
    properties (GetAccess = public, SetAccess = private)
        time
        folder
        filename
        reducible
    end
    
    methods (Access = public)
        function obj = FileBase(filename_, folder_)
            %FileBase: Constructor.
            %
            %   Input:  char array (filename, opt.)
            %           char array (folder, opt.)
            %   Output: FileBase object

            obj.time = DateTime(now);                                       %set property time
            if nargin < 2
                folder_ = sprintf('%sdata/', FileBase.removeRoot( ...
                    Misc.getPath(class(obj)))); 
            end
            if nargin < 1
                filename_ = sprintf('%s_%s.mat', class(obj), ...
                    obj.time.toFilename);
            end
            
            %set filename and folder
            obj.setFilename(filename_);
            obj.setFolder(folder_); 
            obj.reducible = {};
        end
        
        function x = getAbsPath(obj)
            %getAbsPath returns the full path to the object's file. Works
            %with arrays.
            %
            %   Output: (cell array of) char array(s)
            
            n = numel(obj);
            if n == 1
                x = sprintf('%s%s', FileBase.getRoot, obj.getRelPath);
            else
                x = cell(1, n);
                for i = 1 : n
                    x{i} = sprintf('%s%s', FileBase.getRoot, ...
                        obj(i).getRelPath);
                end
            end
        end

        function x = isReducible(obj, name)
            %isReducible returns true if input is contained in property
            %reducible.
            %
            %   Input:  (cell of) char array(s)   
            %   Output: logical scalar
        
            x = (Misc.isCellOf(name, 'char') || ischar(name)) && ...
                all(ismember(name, obj.reducible));
        end
        
        function reduce(obj, name)
            %reduce replaces properties listed in property reducible with 
            %their relative path.
            %
            %   Input:  (cell of) char array(s)  (def = all properties 
            %               listed in property reducible)
            
            if nargin == 1, name = obj.reducible; end
            if ~isempty(obj.reducible)
                if ~obj.isReducible(name)
                    error('Input is not contained in property reducible.');
                end
                if ischar(name), name = {name}; end

                for i = 1 : numel(name)
                    if isa(obj.(name{i}), 'FileBase')
                        obj.toggle(name{i}); 
                    end
                end
            end
        end
        
        function save(obj)
            %save calls reduce and saves the object under the path returned
            %by getPath.
            
            %save all properties (if file doesn't already exist) listed in 
            %property reducible and replace them with their relative paths
            obj.reduce;                                                     

            %determine size of object in bytes
            if Misc.getSize(obj) < 2 * 1024 ^ 3, tag = '-v6';               %< 2GB: save uncompressed (larger file, but faster saving and loading)
            else, tag = '-v7.3';                                            %>= 2GB: save compressed (only option, otherwise error)
            end

            fprintf('Saving %s... ', obj.getAbsPath);
            obj.createFolder;
            save(obj.getAbsPath, 'obj', tag);
            fprintf('done.\n');
        end
    end
    
    methods (Sealed)
        function x = getRelPath(obj)
            %getRelPath returns the path to the object's file relative
            %to folder MATLAB. Works with arrays.
            %
            %   Output: (cell array of) char array(s)
           
            n = numel(obj);
            if n == 1
                x = sprintf('%s%s', obj.folder, obj.filename);
            else
                x = cell(1, n);
                for i = 1 : n
                    x{i} = sprintf('%s%s', obj(i).folder, obj(i).filename);
                end
            end
        end

        function x = getUnreduced(obj, x)
            %getUnreduced returns all unique FileBase subclass objects that
            %are found in properties listed in property reducible. Works 
            %recursively, i.e., also objects from sub-(...)-properties will
            %be returned. Called by load.
            %
            %   Input:  FileBase subclass array (optional)
            %   Output: FileBase subclass array
            
            if nargin < 2, x = FileBase.empty; end
            if ~isa(x, 'FileBase')
                error('Input must be a FileBase subclass array.');
            end
            
            x = x(:);
            name = obj.reducible;
            for i = 1 : numel(name)
                if isa(obj.(name{i}), 'FileBase')
                    x_ = obj.(name{i});
                    x = [x(:); x_(:)];
                    relPath = x.getRelPath;
                    if ~iscell(relPath), relPath = {relPath}; end
                    [~, iuq] = unique(relPath);                             %unique csannot be directly applied on x because it can be an hetereogeneous array
                    x = x(iuq);
                    for j = 1 : numel(x_), x = x_(j).getUnreduced(x); end    %recursive call(s)
                end
            end
        end    
        
        function unreduced = load(obj, varargin)
            %load loads properties listed in property reducible. Works with
            %arrays.
            %
            %Features:
            %   - selective loading of reducible properties
            %   - recursive loading (i.e., also sub-(...)-properties)
            %   - selective recursive loading
            %   - copy-by-reference of pre-defined redundant objects
            %   - automatic copy-by-reference of redundant objects in 
            %       recursive loading
            %
            %   Input:      OPTIONAL, IN ARBITRARY ORDER
            %           (cell array of) char array(s) (names of properties 
            %               to load; def = all listed in prop. reducible)
            %           logical scalar (true = recursive loading, i.e.,
            %               subproperties will be loaded as well, if prop.
            %               names are defined, only those will be loaded 
            %               recursively; def = true)
            %           FileBase array (unreduced objects to be copied by 
            %               reference instead of loading redundant objects,
            %               used for recursive loading only)
            %   Output: FileBase array (unreduced objects, if demanded)
            
            if numel(obj) > 1
                unreduced = FileBase.empty;
                for i = 1 : numel(obj)
                    unreduced = obj(i).load(varargin{:}, unreduced);
                end
                return;
            end

            for i = 1 : numel(varargin)
                errMsg = sprintf('%s parameter is invalid.', ...
                    Misc.ordinalNumber(i));
                if (ischar(varargin{i}) || ...
                        Misc.isCellOf(varargin{i}, 'char'))
                    name = varargin{i};                                     %no error check here; when property name does not exist, no error is thrown. Allows to define property names that exist in subproperties only
                    if ischar(name), name = {name}; end
                elseif Misc.is(varargin{i}, 'logical', 'scalar')
                    if exist('recursive', 'var'), error(errMsg); end        %#ok
                    recursive = varargin{i};
                elseif isa(varargin{i}, 'FileBase')
                    if exist('unreduced', 'var'), error(errMsg); end        %#ok
                    unreduced = varargin{i}(:);
                else
                    error(errMsg);                                          %#ok
                end
            end

            loadAll = ~exist('name', 'var');
            if loadAll, name = obj.reducible; end
            if ~exist('recursive', 'var'), recursive = true; end
            if ~exist('unreduced', 'var'), unreduced = obj.getUnreduced;    %unreduced Filebase subclass objects are those recursively found in object
            else, unreduced = obj.getUnreduced(unreduced);                  %... plus those defined as input parameter
            end
            
            for i = 1 : numel(name)
                if isprop(obj, name{i}) && (ischar(obj.(name{i})) || ...
                        Misc.isCellOf(obj.(name{i}), 'char'))
                    if isempty(unreduced)                                   %no unreduced obects found
                       obj.toggle(name{i});                                 %call toggle to set (= to load) property
                       if recursive
                           unreduced = [unreduced; obj.(name{i})(:)];       %#ok. Append loaded property to unreduced array
                       end
                    else                                                    %unreduced FileBase objects were defined as input parameter
                        relPath = obj.(name{i});
                        if ischar(relPath), relPath = {relPath}; end
                        
                        [isInUnreduced, iUnreduced] = ismember(relPath, ...
                            unreduced.getRelPath);                          %isInUnreduced: logical array, true if FileBase object to be loaded already exists in unreduced; iUnreduced: corresponding indices in unreduced
                        iUnreduced = iUnreduced(iUnreduced > 0);
                        iLoad = find(~isInUnreduced);                       %indices of elements in value to be loaded (do not exist in unreduced)
                        
                        %load elements of value not contained in unreduced
                        value = FileBase.empty;
                        for j = 1 : numel(iLoad)
                            value(j) = Misc.load(FileBase.appendToRoot( ...
                                relPath{iLoad(j)}), 'FileBase');
                        end
                        if recursive
                            unreduced = [unreduced; value(:)];              %#ok. Append loaded elements of value to unreduced array
                        end
                        
                        value = [value(:); unreduced(iUnreduced)];          %append elements which already existed in unreduced
                        value([iLoad(:); ...
                            Misc.flat(find(isInUnreduced))]) = value;       %#ok. sort value into correct order
                        obj.toggle(name{i}, value);                         %call toggle to set property to value
                    end
                end
            end
            
            if recursive
                for i = 1 : numel(name)
                    if isprop(obj, name{i})
                        for j = 1 : numel(obj.(name{i}))
                            if loadAll
                                unreduced = ...
                                    obj.(name{i})(j).load(unreduced);       %load all subproperties (or copy them by reference from unreduced)
                            else
                                unreduced = ...
                                    obj.(name{i})(j).load(name, unreduced); %load only specified subproperties (or copy them by reference from unreduced)
                            end
                        end
                    end
                end
            end
            
            if nargout == 0, clear unreduced, end                           %clear unreduced to avoid unwanted output on command window
        end
    end
    
    methods (Access = protected)
        function setFolder(obj, folder_)
            %setFolder sets property folder (relative to the directory of
            %the object's class).
            %
            %   Input:  char array

            if ~Misc.isValidFoldername(folder_)
                error(['Input must be a non-empty, folder name ' ...
                    'compatible char array.']);
            end
            if folder_(end) ~= '/', folder_(end + 1) = '/'; end
            obj.folder = FileBase.removeRoot(folder_);
        end
        
        function setFilename(obj, filename_)
            %setFilename sets property filename.
            %
            %   Input:  char array

            if ~Misc.isValidFilename(filename_)
                error(['First parameter must be a non-empty, filename ' ...
                    'compatible char array.']);
            end
            
            if numel(filename_) < 4 || ...
                    ~isequal(filename_(end - 3 : end), '.mat')
                filename_ = [filename_, '.mat'];
            end
            
            obj.filename = filename_;
        end

        function setTime(obj, time_)
            %setTime sets property time. Consider using
            %updateTimeAndFilename instead.
            %
            %   Input:  DateTime object
            
            if ~Misc.is(time_, 'DateTime', 'scalar')
                error('Input must be a DateTime object.');
            end
            obj.time = time_;
        end
        
        function setReducible(obj, x)
            %setReducible sets or adds elements to property reducible. Call
            %this function from the constructor of the subclass after all 
            %FileBase properties supposed to be reducible have been set.
            %
            %   Input:  (cell array of) char array(s)
            
            if ~(ischar(x) || Misc.isCellOf(x, 'char'))
                error('Input must be a (cell array of) char array(s).'); 
            end
            
            %get all valid property names (i.e., of FileBase properties)
            validName = {};
            prop = properties(obj);
            for i = 1 : numel(prop)
                if isa(obj.(prop{i}), 'FileBase')
                    validName{end + 1} = prop{i};                           %#ok
                end
            end

            %set property reducible
            if ischar(x), x = {x}; end
            if any(~ismember(x, validName))
                error('Invalid property name.');
            end
            obj.reducible = unique([obj.reducible, x]);
        end

        function value = getToggled(obj, name, value)
            %getToggled returns the toggled value of a property listed in 
            %property reducible. Toggled means that if the property is a
            %FileBase object / array, a char array / cell of char arrays
            %will be returned, and vice versa. getToggled is called from 
            %subclass function toggle, which has the required permissions 
            %to actually toggle the corresponding property's value.
            %
            %   Input:  char array (property name)
            %           FileBase subclass array (property value, opt.)
            %   Output: FileBase subclass array (if property is a path)
            %               OR (cell of) char array(s) (relative path(s), 
            %               if property is a FileBase array)
            
            if ~(ischar(name) && obj.isReducible(name))
                error('Input is not element of property reducible.');
            end
            
            if isa(obj.(name), 'FileBase')                                  %FileBase -> char array
                if nargin == 3
                    warning('Second parameter is ignored.');
                end
                
                value = cell(size(obj.(name)));
                for i = 1 : numel(obj.(name))
                    if ~exist(obj.(name)(i).getAbsPath, 'file')
                        obj.(name)(i).save;                                 %save elements of property to disk
                    end
                    value{i} = obj.(name)(i).getRelPath;
                end
                if numel(value) == 1, value = value{1}; end
            else                                                            %char array -> FileBase
                if nargin == 3                                              
                    if ~(isa(value, 'FileBase') && ...
                            isequal(obj.(name)(:), ...
                            Misc.flat(value.getRelPath)))
                        error('Second parameter is invalid.');
                    end
                else
                    value = FileBase.empty;
                    relPath = obj.(name);
                    if ischar(relPath), relPath = {relPath}; end
                    for i = 1 : numel(relPath)
                        value(i) = Misc.load( ...
                            FileBase.appendToRoot(relPath{i}), 'FileBase');
                    end
                end
            end
        end        
        
        function updateTimeAndFilename(obj, time_)
            %updateTimeAndFilename sets properties time and filename.
            %
            %   Input:  DateTime object (optional, def = now)

            if nargin < 2, time_ = DateTime(now); end
            if ~Misc.is(time_, 'DateTime', 'scalar')
                error('Input must be a DateTime object.');
            end
            
            obj.time = time_;
            obj.setFilename(sprintf('%s_%s.mat', class(obj), ...
                    obj.time.toFilename))
        end
        
        function createFolder(obj)
            %createFolder creates the folder defined in property folder.
            
            folder_ = FileBase.appendToRoot(obj.folder);
            if ~exist(folder_, 'dir'), mkdir(folder_); end
        end
    end
    
    methods (Abstract)
        toggle(obj)
    end
    
    methods (Static)
        function x = getRoot
            %getRoot returns the path to folder MATLAB.
            %
            %   Output: char array
            
            x = Misc.getPath('FileBase.m');
            root = 'MATLAB/';
            i = strfind(x, root);
            x = x(1 : i + numel(root) - 1);
        end
        
        function x = removeRoot(x)
            %removeRoot deletes the root from a path.
            %
            %   Input:  char array (path)
            
            root = FileBase.getRoot;
            x = Misc.minPath(x);
            i = strfind(x, root);
            if isempty(i), return;
            elseif i == 1, x = x(numel(root) + 1 : end);
            else, error('Invalid path %s.', x);
            end
        end
        
        function x = appendToRoot(x)
            %appendToRoot append a char array to the MATLABT root. 
            %
            %   Input:  char array (path relative to root)
            %   Output: char array (full path)
            
            if ~Misc.isValidFoldername(x)
                error(['Input must be a non-empty, folder name ' ...
                    'compatible char array.']); 
            end
            
            x = sprintf('%s%s', FileBase.getRoot, x);
        end
    end
end
