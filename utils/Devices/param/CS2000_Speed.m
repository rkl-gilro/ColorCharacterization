classdef CS2000_Speed < KonicaMinoltaParam
    %CS2000_Speed encapsulates the speed mode parameter of the Konica 
    %Minolta CS-2000. Base class is KonicaMinoltaParam.
    %
    %   constant properties
    %       valid                   cell array (of char arrays)
    %
    %   inherited properties
    %       int                     int scalar
    %       char                    char array
    %
    %   properties
    %       internalND              CS2000_InternalND object
    %       integrationTime_sec     float scalar (integration time in sec)
    %
    %   methods
    %       CS2000_Speed            Constructor
    %
    %   inherited methods
    %       isValid                 Returns logical scalar
    %       toInt                   Returns int scalar
    %       toChar                  Returns char array
    
    properties (Constant)
        valid = {'Normal', 'Fast', 'Multi normal', 'Manual', 'Multi fast'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        internalND
        integrationTime_sec
    end
    
    methods
        function obj = CS2000_Speed(x, internalND_, integrationTime_sec_)
            %CS2000_Speed: Constructor.
            %
            %   Input:  char array OR int scalar (speed mode)
            %               'Normal'
            %               'Fast'
            %               'Multi normal'
            %               'Manual'
            %               'Multi fast'
            %                   OR
            %               0, 1, 2, 3, 4
            %
            %           char array OR int scalar (internal ND filter)
            %               'Off'
            %               'On'
            %               'Auto' (unless mode is 'manual')
            %                   OR
            %                0, 1, 2
            %
            %           char array OR int scalar (integration time in sec)
            %               Speed mode 3: float scalar in [.005 120]
            %               Speed mode 2 or 4: int scalar in [1 16]
            %
            %   Output: CS2000_Speed object
            
            obj = obj@KonicaMinoltaParam(x);
            
            if ~Misc.is(internalND_, 'CS2000_InternalND', 'scalar')
                error(['Second parameter must be a CS2000_InternalND ' ...
                    'object.']);
            elseif obj.int == 3 && internalND_.int == 2
                error(['Second parameter cannot be ''Auto'' in speed ' ...
                    'mode ''Manual''.']);
            end
            obj.internalND = internalND_;
            
            if any(obj.int == 2 : 4)
                if obj.int == 3 && ~Misc.is(integrationTime_sec_, ...
                        'float', 'scalar', [.005 12])
                    error(['Third parameter must be a float scalar in ' ...
                        '[.005 16].'])
                elseif ~Misc.is(integrationTime_sec_, 'float', ...
                        'scalar', [1, 16])
                    error(['Third parameter must be an float scalar ' ...-
                        'in [1 16].'])
                end
                obj.integrationTime_sec = integrationTime_sec_;
            end
        end
    end
end