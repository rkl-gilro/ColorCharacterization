classdef ColorFunc < handle
    %ColorFunc is base class of CMF and CRF.
    %
    %   properties
    %       name            Name of color matching function (file)
    %       spectrum        Spectrum object
    %
    %   methods
    %       getFilename     Returns char array (filename of data source)
    %       isValidName     Returns logical scalar (true = file exists)
    %       getValidName    Returns valid values for property name
    %       getAbsorption   Returns m x n float array (absorption rates)
    %
    %   static methods
    %       readSpectrum    Returns Spectrum (read from csv file)
    
    properties (GetAccess = public, SetAccess = protected)
        name
        spectrum
    end
    
    methods
        function x = getFilename(obj)
            %getFilename: Returns filename of data source.
            
            type = class(obj);
            x = sprintf('%s%s/%s.csv', Misc.getPath(type), type, obj.name);
        end
        
        function x = isValidName(obj, name)
            %isValidName returns true if input char array is corresponds to
            %an existing color function txt file.
            %
            %   Input:  char array
            %   Output: logical scalar
            
            x = Misc.isInCell(name, obj.getValidName);
        end
        
        function x = getValidName(obj)
            %getValid: Returns all valid file names of color functions.
            %
            %   Output: cell array (char arrays)
            
            type = class(obj);
            tmp = dir(sprintf('%s%s/', Misc.getPath(type), type)); 
            x = {};
            for i = 1 : numel(tmp)
                if ~tmp(i).isdir && ...
                        isequal(tmp(i).name(end - 3 : end), '.csv')
                    x{end + 1} = tmp(i).name(1 : end - 4);                  %#ok
                end
            end
        end
        
        function x = getAbsorption(obj, spectrum_)
            %getAbsorption returns the integrated product of a given
            %spectrum and the color function.
            %
            %   Input:  Spectrum object
            %   Output: m x n float scalar (absorption rates)

            if ~Misc.is(spectrum_, 'Spectrum', 'scalar')
                error('Input must be a Spectrum object.');
            end
            
            tmp = Spectrum.commonDomain([obj.spectrum, spectrum_]);
            x = tmp(1).value' * tmp(2).value; 
        end
    end
    
    methods (Access = protected)
        function init(obj, name_)
            %init sets properties name and spectrum.
            
            if nargin < 2
                if isa(obj, 'CMF')
                    fprintf('Select color matching function:\n');
                else
                    fprintf('Select cone fundamentals:\n');
                end
                name_ = Menu.basic(obj.getValidName, 'default', 4);
            elseif ~ischar(name_)
                error('Input must be a char array.');
            elseif ~obj.isValidName(name_)
                error('Invalid color matching function name.');
            end
            
            obj.name = name_;
            obj.spectrum = ColorFunc.readSpectrum(obj.getFilename);
        end
    end
    
    methods (Static)
        function x = readSpectrum(filename)
            %readSpectrum reads spectral data from csv file. Transforms log
            %into linear data automatically.
            %
            %   Input:  char array (filename)
            %   Output: Spectrum object
            
            tmp = csvread(filename);
            if contains(filename, ' log ') || ...
                    contains(filename, ' log.csv')
                tmp(:, 2 : end) = 10 .^ tmp(:, 2 : end);
            end
            x = Spectrum(tmp(:, 1), tmp(:, 2 : end));
        end
    end
end

