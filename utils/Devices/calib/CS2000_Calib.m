classdef CS2000_Calib
    %CS2000_Calib encapsulates a user calibration for the Konica Minolta 
    %CS-2000. 
    %
    %   properties
    %       channel         int scalar (calibration channel index)
    %       name            char array
    %       band            Spectrum object (wavelength)
    %       level           Spectrum object (output level factor)
    %   
    %   methods
    %       CS2000_Calib    Constructor
    
    properties (GetAccess = public, SetAccess = private)
        channel
        name
        band
        level
    end
    
    methods
        function obj = CS2000_Calib(channel_, name_, band_, level_)
            %CS2000_Calib: Constructor.
            %
            %   Input:  int scalar (calibration channel index)
            %           char array (max. 10 characters)
            %           Spectrum object (wavelength, int in [380 780])
            %           Spectrum object (correction factors for output 
            %               level of each band, [.001 1000])
            %   Output: CS2000_Calib object

            if ~Misc.is(channel_, 'int', 'scalar', [0, 10])
                error('Input must be an int scalar in [0 10].');
            elseif ~(numel(name_) <= 10 && ischar(name_))
                error(['Second parameter must be a char array with a ' ...
                    'maximal length of 10.']);
            end
            
            obj.channel = channel_;
            obj.name = name_;

            if obj.channel > 0 && nargin < 4
                error(['Four input parameters are required if channel ' ...
                    'index > 0.']);
            elseif nargin == 4
                wvl = CS2000.getWavelength;
                if ~Misc.is(band_, 'Spectrum', 'scalar')
                    error('Third parameter must be a Spectrum object.');
                elseif ~isequal(band_.wavelength, wvl)
                    error(['Bands of third parameter must be the CS2000 ' ...
                        'bands.']);
                elseif ~Misc.is(abs(band_.value - wvl), [0, 2])
                    error(['Values of third parameter deviate by more ' ...
                        'than +-2 nm from the default wavelength ' ...
                        'array (380 : 780)''.']);
                elseif ~Misc.is(level_, 'Spectrum', 'scalar')
                    error('Fourth parameter must be a Spectrum object.');
                elseif ~isequal(level_.wavelength, wvl)
                    error(['Bands of fourth parameter must be the ' ...
                        'CS2000 bands.']);
                elseif ~Misc.is(level_.value, [.001, 1000])
                    error(['Values of fourth parameter must be in ' ...
                        '[0.001 1000].']);
                end                
                
                obj.band = band_;
                obj.level = level_;
            end
        end
    end
end