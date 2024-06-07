classdef CS2000_Device
    %CS2000_Device encapsulats the basic device information of a Konica
    %Minolta CS-2000.
    %
    %   properties
    %       model           char array (device model)
    %       variation       int scalar (variation number)
    %       serial          int scalar (serial number)
    %       timeCalib       DateTime object (factory calibration)
    %
    %   methods
    %       CS2000_Device   Constructor
    %       print           Prints formatted properties in command window
    
    properties (GetAccess = public, SetAccess = private)
        model
        variation
        serial
        timeCalib
    end
    
    methods
        function obj = CS2000_Device(model_, variation_, serial_, ...
                timeCalib_)
            %CS2000_Device: Constructor.
            %
            %   Input:  char array (model)
            %           int scalar (variation)
            %           int scalar (7-digit serial number)
            %           DateTime object
            %   Output: CS2000_Device object
            
            if ~ischar(model_)
                error('First parameter must be a char array.');
            elseif ~Misc.is(variation_, 'int', 'scalar', [0, 9])
                error('Second parameter must be a scalar in [0 9].');
            elseif ~Misc.is(serial_, 'int', 'scalar', [0, 1e7 - 1])
                error(['Third parameter must be an int scalar with ' ...
                    'max. 7 digits.']);
            elseif ~Misc.is(timeCalib_, 'DateTime', 'scalar')
                error('Fourth parameter must be a DateTime object.');
            end
            
            obj.model = model_;
            obj.variation = variation_;
            obj.serial = serial_;
            obj.timeCalib = timeCalib_;
        end
        
        function print(obj)
            %print prints the formatted device information.
            
            fprintf(['Model:\t\t\t\t\t%s\nVariation:\t\t\t\t%d\n' ...
                'Serial number:\t\t\t%d\nFactory calibration:\t%s\n'], ...
                obj.model, obj.variation, obj.serial, obj.timeCalib.char);
        end
    end
end

