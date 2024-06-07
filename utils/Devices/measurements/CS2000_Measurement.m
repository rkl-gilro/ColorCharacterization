classdef CS2000_Measurement < CS2000_MeasurementData
    %CS2000_Measurement encapsulates the measurement data of the Konica 
    %Minolta CS-2000. CS2000_Measurement is a child class of 
    %CS2000_MeasurementData.
    %
    %   properties
    %       name                char array
    %       time                DateTime object
    %       condition           CS2000_Condition object
    %
    %   inherited properties
    %       device              CS2000_Device object
    %       report              CS2000_Report array
    %       radiance            Spectrum array
    %       color               CS2000_Color array
    %   
    %   methods
    %       CS2000_Measurement  Constructor
    
    properties (GetAccess = public, SetAccess = private)
        name
        time
        condition
    end
    
    methods
        function obj = CS2000_Measurement(name_, time_, condition_, ...
                device_, report_, radiance_, color_)
            %CS2000_Measurement: Constructor.
            %
            %   Input:  char array
            %           DateTime object
            %           CS2000_Condition object
            %           CS2000_Device object
            %           CS2000_Report array
            %           Spectrum array
            %           CS2000_Color array
            %   Output: CS2000_Measurement object
     
            obj = obj@CS2000_MeasurementData(device_, report_, ...
                radiance_, color_);
            
            if ~ischar(name_)
                error('First parameter must be a char array.');
            elseif ~Misc.is(time_, 'DateTime', 'scalar')
                error('Second parameter must be a DateTime object.');
            elseif ~Misc.is(condition_, 'CS2000_Condition', 'scalar')
                error(['Third parameter must be a CS2000_Condition ' ...
                    'object.']);
            end
            
            obj.name = name_;
            obj.time = time_;
            obj.condition = condition_;
        end
    end 
end

