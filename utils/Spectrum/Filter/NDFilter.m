classdef NDFilter < Filter
    %NDFilter encapsulates properties and methods of a neutral density
    %filter. Base class is Filter. 
    %
    %   inherited properties
    %       name            char array
    %       manufacturer    char array
    %       transmission    Spectrum object
    %       thickness_mm    float scalar
    %
    %   methods
    %       NDFilter        Constructor
    %       OD              Returns float scalar (optical density)
    %
    %   inherited methods
    %       show            Shows property transmission. Works with arrays
    
    methods
        function obj = NDFilter(name_, manufacturer_, transmission_, ...
                thickness_mm_)
            %NDFilter: Constructor.
            %
            %   Input:  char array (name)
            %           char array (manufacturer)            
            %           Spectrum (transmission)
            %           float scalar (thickness in mm)
            %   Output: NDFilter object
            
            obj = obj@Filter(name_, manufacturer_, transmission_, ...
                thickness_mm_);
        end

        function x = OD(obj, wvlIv)
            %OD returns the optical density for the given wavelength
            %interval.
            %
            %   Input:  1 x 2 float (wavelength interval, def = all)
            %   Output: float scalar

            if nargin < 2
                wvlIv = obj.transmission.wavelength([1 end]);
            end
            if ~Misc.is(wvlIv, 'float', 'interval')
                error('Input must be a positive float interval.');
            end

            valid = obj.transmission.wavelength >= wvlIv(1) & ....
                obj.transmission.wavelength <= wvlIv(2);
            x = log10(1 ./ mean(obj.transmission.value(valid)));
        end
    end 
end
