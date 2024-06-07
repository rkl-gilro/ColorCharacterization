classdef CS2000_ExternalND < KonicaMinoltaParam
    %CS2000_ExternalND encapsulates the external ND filter setting of the
    %Konica Minolta CS-2000. Base class is KonicaMinoltaParam.
    %
    %   constant properties
    %       valid               cell array (of char arrays)
    %
    %   properties
    %       compensation        CS200_Compensation object
    %
    %   inherited properties
    %       int                 int scalar
    %       char                char array
    %
    %   methods
    %       CS2000_ExternalND   Constructor
    %
    %   inherited methods
    %       isValid             Returns logical scalar
    %       toInt               Returns int scalar
    %       toChar              Returns char array
    
    properties (Constant)
        valid = {'None', '1/10', '1/100'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        compensation
    end
    
    methods
        function obj = CS2000_ExternalND(x, compensation_)
            %CS2000_ExternalND: Constructor.
            %
            %   Input:  int scalar OR char array ('None', '1/10', '1/100', 
            %               or 0, 1, 2)
            %           CS2000_Compensation object (if first parameter is
            %               not 'None' or 0)
            %   Output: CS2000_ExternalND object
            
            obj = obj@KonicaMinoltaParam(x);
            if obj.int == 0
                if nargin == 2, error('Too many input parameters.'); end
            elseif nargin == 1
                    error('Too few input parameters.');
            elseif ~Misc.is(compensation_, 'CS2000_Compensation', 'scalar')
                error(['Second parameter must be a ' ...
                    'CS2000_Compensation object.']);
            else
                obj.compensation = compensation_;
            end
        end
    end
end