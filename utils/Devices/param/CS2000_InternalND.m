classdef CS2000_InternalND < KonicaMinoltaParam
    %CS2000_InternalND encapsulates the internal ND filter setting of the 
    %Konica Minolta CS-2000. Base class is KonicaMinoltaParam.
    %
    %   constant properties
    %       valid               cell array (of char arrays)
    %
    %   inherited properties
    %       int                 int scalar
    %       char                char array
    %
    %   methods
    %       CS2000_InternalND   Constructor
    %
    %   inherited methods
    %       isValid             Returns logical scalar
    %       toInt               Returns int scalar
    %       toChar              Returns char array
    
    properties (Constant)
        valid = {'Off', 'On', 'Auto'};
    end
    
    methods
        function obj = CS2000_InternalND(x)
            %CS2000_InternalND: Constructor.
            %
            %   Input:  int scalar OR char array
            %   Output: CS2000_InternalND object
            
            obj = obj@KonicaMinoltaParam(x);
        end
    end
end