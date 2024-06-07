classdef CS2000_Sample < CS2000_MeasurementData
    %CS2000_Sample encapsulates sample data of the Konica Minolta CS-2000.
    %Samples are measurement data stored in the device memory. 
    %CS2000_Sample is a child class of CS2000_MeasurementData.
    %
    %   properties
    %       index               int scalar (sample Index)
    %
    %   inherited properties
    %       device              CS2000_Device object
    %       report              CS2000_Report object
    %       radiance            Spectrum object
    %       color               CS2000_Color object
    %   
    %   methods
    %       CS2000_Sample       Constructor
    %
    %   static methods
    %       checkSampleIndex    Throws an error if sample index is invalid
    
    
    properties (GetAccess = public, SetAccess = private)
        index
    end
    
    methods
        function obj = CS2000_Sample(index_, device_, report_, ...
                radiance_, color_)
            %CS2000_Sample: Constructor.
            %
            %   Input:  int scalar (sample index, [0 99])
            %           CS2000_Report object
            %           Spectrum object
            %           CS2000_Color object
            %   Output: CS2000_Sample object
     
            obj = obj@CS2000_MeasurementData(device_, report_, ...
                radiance_, color_);
            
            try
                CS2000_Sample.checkSampleIndex(index_);
            catch ME
                error('First parameter is invalid.\n%s', ME.message);
            end
            obj.index = index_;
        end
    end 
    
    methods (Static)
        function checkSampleIndex(idx)
            %checkSampleIndex: Throws an error if sample index is invalid.
            %
            %   Input:  int scalar (sample index, [0 99])
            
            if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                error('Sample index must be an int scalar in [0 99].');
            end
        end
    end
end

