classdef WhiteStandard
    %WhiteStandard encapsulates properties of a white standard for
    %spectral measurements of illumination.
    %
    %   properties
    %       name                char array
    %       manufacturer        char array
    %       caibDate            DateTime object
    %       reflectance         Spectrum object
    %
    %   methods
    %       WhiteStandard       Constructor
    
    
    properties (GetAccess = public, SetAccess = private)
        name
        manufacturer
        calibDate
        reflectance
    end
    
    methods
        function obj = WhiteStandard(name_, manufacturer_, calibDate_, ...
            reflectance_)
            %WhiteStandard: Constructor. 
            %
            %   Input:  char array (name)
            %           char array (manufacturer)
            %           DateTime object (of calibration)
            %           Spectrum object (reflectance)
            %   Output: WhiteStandard object
            
            if ~Misc.is(name_, 'char', '~isempty')
                error('First parameter must be a non-empty char array.');
            elseif ~Misc.is(manufacturer__, 'char', '~isempty')
                error('Second parameter must be a non-empty char array.');
            elseif ~Misc.is(calibDate_, 'DateTime', 'scalar')
                error('Third parameter must be a DateTime object.');
            elseif ~Misc.is(reflectance_, 'Spectrum', 'scalar')
                error('Fourth parameter must be a Spectrum object.');
            end
            
            obj.name = name_;
            obj.manufacturer = manufacturer_;
            obj.calibDate = calibDate_;
            obj.reflectance = reflectance_;
        end
    end
end

