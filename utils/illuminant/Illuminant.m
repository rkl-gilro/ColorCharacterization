classdef Illuminant
    %Illumninat encaosulates illuminants, i.e., name and spectrum.
    %
    %   properties
    %       name        char array (name of illuminant)
    %       spectrum    Spectrum object
    %
    %   methods
    %       Illuminant  Constructor
    
    
    properties
        name
        spectrum
    end
    
    methods
        function obj = Illuminant(name_, spectrum_)
            if ~ischar(name_)
                error('First parameter must be a char array.');
            elseif ~(Misc.is(spectrum_, 'Spectrum', 'scalar') &&...
                    spectrum_.count == 1)
                error(['Second parameter must be a Spectrum object ' ...
                    'containing one spectrum only.']);
            end
            
            obj.name = name_;
            obj.spectrum = spectrum_;
        end
    end
end    
