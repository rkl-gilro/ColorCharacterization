classdef (Abstract) KonicaMinoltaParam
    %KonicaMinoltaParam is an abtract base class encapsulates parameters of
    %the devices CM-700d and CS-2000. It is base class of CM700_Area, 
    %CM700_Specular, CS2000_Angle, CS2000_Lens, CS2000_Sync, CS2000_Speed, 
    %CS2000_InternalND, and CS2000_ExternalND.
    %
    %   properties
    %       int                     int scalar
    %       char                    char array
    %
    %   methods
    %       KonicaMinoltaParam      Constructor
    %
    %   static methods
    %       isValid                 Returns logical scalar
    %       toInt                   Returns int scalar
    %       toChar                  Returns char array
    
    properties (GetAccess = public, SetAccess = protected)
        int
        char
    end
    
    methods
        function obj = KonicaMinoltaParam(x)
            %KonicaMinoltaParam: Constructor.
            %
            %   Input:  char array OR int scalar
            %   Output: KonicaMinoltaParam object
            
            obj.int = obj.toInt(x);
            obj.char = obj.toChar(x);
        end
        
        function x = isValid(obj, value)
            %isValid returns true if the second parameter is contained in 
            %the first parameter, or if the second parameter corresponds to
            %indices of the first parameter.
            %
            %   Input:  (cell array of) char array(s) OR int array
            %   Output: logical scalar
            
            if Misc.isCellOf(value, 'char') || ischar(value)
                x = all(ismember(value, obj.valid));
            else 
                x = Misc.is(value, 'int', [0, numel(obj.valid) - 1]);                
            end
        end
        
        function x = toInt(obj, value)
            %toInt converts input to int array.
            %
            %   Input:  (cell array of) char array(s) OR int array
            %   Output: int array
            
            if ~obj.isValid(value), error('Invalid input.'); end
                
            if iscell(value)
                n = numel(value);
                x = nan(1, n);
                for i = 1 : n
                    x(i) = obj.toInt(value{i});
                end
            elseif ischar(value)
                [~, x] = ismember(obj.valid, value);
                x = find(x) - 1;
            else
                x = value;
            end
        end
        
        function x = toChar(obj, value)
            %toChar converts input to (cell array of) char array(s).
            %
            %   Input:  (cell array of) char array(s) OR int array
            %   Output: (cell array of) char array(s)
            
            if ~obj.isValid(value), error('Invalid input.'); end
            
            if isnumeric(value)
                n = numel(value);
                if n > 1
                    x = cell(1, n);
                    for i = 1 : n
                        x{i} = obj.toChar(value(i));
                    end
                else
                    x = obj.valid{value + 1}; 
                end
            else
                x = value;
            end
        end
    end
end