classdef CS2000_Angle < KonicaMinoltaParam
    %CS2000_Angle encapsulates the aperture setting of the Konica Minolta 
    %CS-2000. Base class is KonicaMinoltaParam.
    %
    %   constant properties
    %       valid           cell array (of char arrays)
    %
    %   inherited properties
    %       int             int scalar
    %       char            char array
    %
    %   methods
    %       CS2000_Angle    Constructor
    %       deg             Returns float scalar (meas. angle in degree)
    %
    %   inherited methods
    %       isValid         Returns logical scalar
    %       toInt           Returns int scalar
    %       toChar          Returns char array
    
    properties (Constant)
        valid = {'1', '0.2', '0.1'};
    end

    methods
        function obj = CS2000_Angle(x)
            %CS2000_Angle: Constructor.
            %
            %   Input:  int scalar OR char array
            %   Output: CS2000_Angle object
            
            obj = obj@KonicaMinoltaParam(x);
        end
        
        function x = deg(obj)
            %deg returns the measurement angle in degree.
            %
            %   Output: float scalar
            
            x = str2double(obj.char(1 : end));
        end
    end
end