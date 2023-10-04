classdef CRF < ColorFunc
    %CRF encapsulates the cone and rod fundamentals.
    %
    %   inherited properties    
    %       name            char array (name of source file)
    %       spectrum        Spectrum object ([S, R, M, L])
    %
    %   methods
    %       CRF             Constructor
    %       plot            Plots property spectrum
    %       getSRML         Returns 4 x n float (receptor absorption)
    %       getID           char array (short identifier, for filenames)
    %
    %   inherited methods
    %       getFilename     Returns char array (filename of data source)
    %       isValidName     Returns logical scalar (true = file exists)
    %       getValidName    Returns valid values for property name
    %       getAbsorption   Returns m x n float array (absorption rates)
    %
    %   inherited static methods
    %       readSpectrum    Returns Spectrum (read from csv file)

    methods
        function obj = CRF(name_)
            %CRF: Constructor.
            %
            %   Input:  char array (name)
            %   Output: CRF object        
            
            if nargin == 0, obj.init;
            else, obj.init(name_);
            end
            
            type = class(obj);
            tmp = Spectrum.merge([obj.spectrum, ...
                ColorFunc.readSpectrum(sprintf(['%s%s/rods/CIE 1951 ' ...
                'scotopic luminosity function.csv'], ...
                Misc.getPath(type), type))]);                               %append rod fundamentals to cone fundamentals (L, M, S, R)
            obj.spectrum = Spectrum(tmp.wavelength, ...
                tmp.value(:, [3, 4, 2, 1]));                                %bring into order S, R, M, L (in increasing order of maximum's wavelength)
        end

        function plot(obj)
            %plot plot sproperty spectrum.
            h = obj.spectrum.plot;
            ylabel('normalized sensitivity');
            legend (h, {'S-cone' 'Rod' 'M-cone' 'L-cone'});
        end
        
        function x = getSRML(obj, radiance)
            %getSRML returns the photoreceptor absorption corresponding to 
            %given spectral input.
            %
            %   Input:  Spectrum array
            %   Output: 4 x n float ([S; R; M; L] absorption)

            if ~Misc.is(radiance, 'Spectrum', '~isempty')
                error('Input must be a non-empty Spectrum array.');
            end
                
            tmp = Spectrum.commonDomain([obj.spectrum, ...
                Spectrum.merge(radiance)]);
            x = ([tmp(2).value]' * [tmp(1).value])';
        end
        
        function x = getID(obj)
            %getID returns a short identifier, which consists of all
            %capital letters and numbers of property name.
            %
            %   Output: char array
            
            valid = [double('A') : double('Z'), double('0') : double('9')];
            x = obj.name(ismember(obj.name, valid));
        end
    end
end       