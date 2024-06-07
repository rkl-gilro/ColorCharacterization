classdef CS2000_Lens < KonicaMinoltaParam
    %CS2000_Lens encapsulates the close-up lens setting of the Konica 
    %Minolta CS-2000. Base class is KonicaMinoltaParam.
    %
    %   properties
    %       compensation        CS2000_Compensation object
    %
    %   inherited properties
    %       int                 int scalar
    %       char                char array
    %
    %   methods
    %       CS2000_Lens         Constructor
    %
    %   inherited methods
    %       isValid             Returns logical scalar
    %       toInt               Returns int scalar
    %       toChar              Returns char array
    
    properties (Constant)
        valid = {'None' 'Attached'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        compensation
    end
    
    methods
        function obj = CS2000_Lens(x, compensation_)
            %CS2000_Lens: Constructor.
            %
            %   Input:  int scalar OR char array ('None', 'Attached', or 
            %               0, 1)
            %           CS2000_Compensation object (if first parameter is
            %               'Attached' or 1)
            %   Output: CS2000_Lens object
            
            obj = obj@KonicaMinoltaParam(x);
            
            if obj.int == 0
                if nargin == 2, error('Too many input paramaters.'); end
            elseif nargin == 1
                    error('Too few input parameters.');
            elseif ~(isa(compensation_, 'CS2000_Compensation') && ...
                    numel(compensation_) == 1)
                error(['Second parameter must be a ' ...
                    'CS2000_Compensation object.']);
            else
                obj.compensation = compensation_;
            end
        end
    end
end