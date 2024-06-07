classdef CS2000_Sync < KonicaMinoltaParam
    %CS2000_Sync encapsulates the sync mode parameter of the Konica Minolta
    %CS-2000. Base class is KonicaMinoltaParam.
    %
    %   constant properties
    %       valid           cell array (of char arrays)
    %
    %   inherited properties
    %       int             int scalar
    %       char            char array
    %
    %   properties
    %       freq_Hz         float scalar (Synchronization frequency in Hz)
    %
    %   methods
    %       CS2000_Sync     Constructor
    %
    %   inherited methods
    %       isValid         Returns logical scalar
    %       toInt           Returns int scalar
    %       toChar          Returns char array
    
    properties (Constant)
        valid = {'No sync', 'Internal', 'External'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        freq_Hz
    end
    
    methods
        function obj = CS2000_Sync(x, freq_Hz_)
            %CS2000_Sync: Constructor.
            %
            %   Input:  int scalar or char array
            %           float scalar (frequency [Hz]; if first param is 1 
            %               or 'internal')
            %   Output: CS2000_Sync object
            
            obj = obj@KonicaMinoltaParam(x);
            
            if obj.int == 1
                if ~Misc.is(freq_Hz_, 'float', 'scalar', [20, 200])
                    error(['Second parameter must be a float scalar ' ...
                        'in [20 200].']);
                end
                obj.freq_Hz = freq_Hz_;
            end
        end
    end
end