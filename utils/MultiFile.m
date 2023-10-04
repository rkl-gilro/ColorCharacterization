classdef (Abstract) MultiFile
    %MultiFile encapsulates static methods to write / read multiple binary 
    %and text files into / from a single binary .mul file. This allows to 
    %boost copy and read operations with large sets of small binary or text
    %files.
    %
    %   static methods
    %       write       Writes binary and text files into a .mul file
    %       read        Reads binary and text file data from a .mul file
    %       readHeader  Returns char array (header of a .mul file)

    properties (Constant)
        format1 = {'uchar', 'schar', 'int8', 'uint8'};
        format2 = {'int16', 'uint16'};
        format4 = {'int32', 'uint32', 'single', 'float32'};
        format8 = {'int64', 'uint64', 'double', 'float64'};
    end
    
    methods (Static)
        function write(source, destination, format, machine)
            %write writes a .mul file from multiple binary (or text) files.
            %
            %   Input:  1 x n cell of char arrays (paths of source files)
            %           char array (path of destination file)
            %           (1 x n cell of) char array(s) (format of 
            %               source files, valid are 
            %               uchar   unsigned integer (1 byte)
            %               schar   signed integer (1 byte)
            %               int8    integer (1 byte)
            %               int16   integer (2 byte)
            %               int32   integer (4 byte)
            %               int64   integer (8 byte)
            %               uint8   unsigned integer (1byte.
            %               uint16  unsigned integer (2 byte)
            %               uint32  unsigned integer (4 byte)
            %               uint64  unsigned integer (8 byte)
            %               single  floating point (4 byte)
            %               float32 floating point (4 byte)
            %               double  floating point (8 byte)
            %               float64 floating point (8 byte)
            %           (1 x n cell of) char array(s) (machine format of
            %               source files; optional, valid are 
            %               n (local machine format, default)
            %               l (IEEE floating point little-endian)
            %               b (IEEE floating point big-endian)
            %               a (IEEE floating point little-endian 8 byte)
            %               s (IEEE floating point big-endian byte 8 byte)

            if nargin < 5, machine = 'n'; end
            [nSource, destination] = ...
                MultiFile.checkSourceAndDest(source, destination);
            
            msg3 = sprintf(['Third parameter must be a (1 x %d ' ...
                'cell of) char array(s).'], nSource);
            if ~(ischar(format) || iscell(format)), error(msg3); end        %#ok

            msg4 = sprintf(['Fourth parameter must be a (1 x %d ' ...
                'cell of) char array(s).'], nSource);
            if ~(ischar(machine) || iscell(machine)), error(msg4); end      %#ok
            
            for i = 1 : nSource
                if iscell(format) && ~ischar(format{i}), error(msg3); end   %#ok
                if iscell(machine) && ~ischar(machine{i}), error(msg4); end %#ok
                if exist(source{i}, 'file') ~= 2
                    error('File %s not found.', source{i});
                end
            end
            
            validFormat = [MultiFile.format1, MultiFile.format2, ...
                MultiFile.format4, MultiFile.format8];
            validMachine = {'n', 'l', 'b', 'a', 's'};
            if numel(unique(source)) ~= numel(source)
                error('Third parameter contains redundant elements.');
            elseif any(~ismember(format, validFormat))
                error(['Fourth parameter contains invalid format ' ...
                    'specifiers.']);
            elseif any(~ismember(machine, validMachine))
                error(['Fourth parameter contains invalid machine ' ...
                    'format specifiers.']);
            end
   
            %check if file already exists
            if exist(destination, 'file') == 2
                error('%s already exists.', destination);
            end
            
            isSingleFormat = ~iscell(format);
            if isSingleFormat, thisFormat = format; end
            
            isSingleMachine = ~iscell(machine);
            if isSingleMachine, thisMachine = machine; end
            
            %write header
            fmul = fopen(destination, 'a');

            try
                %write header
                pos = 0;                                                    %source file position in bytes relative to data part origin
                headerSize = 0;
                header = char(zeros([1, numel(cell2mat(source)) + ...
                    nSource * 10], 'uint8'));                               %allocate char array with the roughly required size for header
                for i = 1 : nSource
                    if ~isSingleFormat, thisFormat = format{i}; end
                    line = sprintf('%s\t%d\t%s\n', source{i}, ...
                        pos, thisFormat);
                    lineSize = numel(line);
                    header(headerSize + (1 : lineSize)) = line;
                    headerSize = headerSize + lineSize;
                    info = dir(source{i});                                  %get file info
                    pos = pos + info.bytes;
                end
                header = header(1 : headerSize);
                fwrite(fmul, int64(headerSize + 8), 'int64');               %write header size. +8 for header size itself
                fwrite(fmul, header, 'char');                               %writes header (lines with filename, start position and format specifier)

                %write data
                for i = 1 : nSource
                    if ~isSingleFormat, thisFormat = format{i}; end
                    if ~isSingleMachine, thisMachine = machine{i}; end
                    fsource = fopen(source{i}, 'r', thisMachine);           %open binary / txt source file
                    fwrite(fmul, fread(fsource, inf, thisFormat), ...
                        thisFormat);                                        %append data
                    fclose(fsource);                                        %close source file
                end
            catch ME
                fclose('all');
                rethrow(ME);
            end
            fclose('all');
        end
        
        function data = read(source, destination, header)
            %read reads and returns data from a .mul file.
            %
            %   Input:  1 x n cell of char arrays (paths of files to read)
            %           char array (path of .mul file)
            %           char array (header content; optional, to increase
            %               performance, i.p. when data from single files 
            %               are read repeatedly from the same .mul file)
            %   Output: 1 x n cell array with data
            
            [nSource, destination] = ...
                MultiFile.checkSourceAndDest(source, destination);
            if nargin == 3 && ~ischar(header)
                error('Third parameter must be a char array.');
            end

            try
                fmul = fopen(destination, 'r');
                if ~exist('header', 'var')
                    header = MultiFile.readHeader(fmul);
                end
                c = textscan(header, '%s\t%d\t%s');                         %parse filenames, positons, and data format from header variable
                nLine = numel(c{1});                                        %number of lines in .mul file
                data = cell(1, nSource);                                    %output variable
                c{2} = c{2} + numel(header) + 8;                            %start position of data part of .mul file. +header because header comes first, then data. +8 because in the first 8 bytes are not part of the header variable, this is where header size is encoded
                
                for i = 1 : nSource
                    [found, j] = ismember(source{i}, c{1});                 %search index of file entry
                    if ~found
                        error('File %s not found in %s.', source{i}, ...
                            destination);
                    end
                    fseek(fmul, c{2}(j), -1);                               %set read position in .mul file to first element to read
                    if j == nLine
                        nRead = inf;                                        %inf = read until end of file
                    else
                        formatSize = MultiFile.getFormatSize(c{3}{i});      %size of data format in bytes
                        nRead = (c{2}(j + 1) - c{2}(j)) / formatSize;       %number of elements to read
                    end
                    data{i} = fread(fmul, nRead, c{3}{i});
                end
                fclose(fmul);
            catch ME
                fclose(fmul);
                rethrow(ME);
            end
        end
        
        function header = readHeader(fidOrFilename)
            %readHeader reads the header of a .mul file from a file 
            %identifier or filename.
            %
            %   Input:  double scalar (file identifier) 
            %               OR char array (path)
            %   Output: char array (header content)
            
            isFilename = ischar(fidOrFilename);
            if isFilename
                fid = fopen(fidOrFilename, 'r');
            else
                fid = fidOrFilename;
                if ~(isnumeric(fid) && numel(fid) == 1)
                    error('Input must be a numeric scalar or char array.');
                end
                fseek(fid, 0, -1);                                          %set cursor to beginning of file
            end
            
            headerSize = fread(fid, 1, 'int64');
            header = char(fread(fid, headerSize - 8, 'char'))';             %#ok

            if isFilename, fclose(fid); end
        end
    end
    
    methods (Static, Hidden)
        function [nSource, destination] = ...
                checkSourceAndDest(source, destination)
            %checkSourceAndDest checks input parameters source and
            %destination of function write and read and returns the number
            %of source files.
            %
            %   Input:  1 x n cell of char arrays (paths of files to read)
            %           char array (path of .mul file)
            %   Output: int scalar (number of source files)
            %           char array (path of .mul file)
            
            msg = 'First parameter must be a cell array of char arrays.';
            if ~iscell(source), error(msg); end
            nSource = numel(source);
            for i = 1 : nSource
                if ~ischar(source{i}), error(msg); end
            end            
            if ~(ischar(destination) && ~isempty(destination))
                error('Second parameter must be a non-empty char array.');
            end
            if numel(destination) < 5 || ...
                    ~isequal(destination(end - 3 : end), '.mul')
                destination = [destination, '.mul'];                        %append file ending to destination if missing
            end
        end
        
        function nByte = getFormatSize(format)
            %getFormatSize returns the size in bytes corresponding to a 
            %given format specifier.
            %
            %   Input:  char array (format specifier)
            %   Output: int scalar
            
            if ismember(format, MultiFile.format1)
                nByte = 1;
            elseif ismember(format, MultiFile.format2)
                nByte = 2;
            elseif ismember(format, MultiFile.format4)
                nByte = 4;
            elseif ismember(format, MultiFile.format8)
                nByte = 8;
            else
                error('Unknwon format identifier.');
            end
        end
    end
end