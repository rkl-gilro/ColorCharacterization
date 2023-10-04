classdef BPFilter < Filter
    %BPFilter encapsulates properties and methods of a single- or multi-
    %bandpass filter. Base class is Filter. 
    %
    %   properties
    %       band            Peak array
    %
    %   inherited properties
    %       name            char array
    %       manufacturer    char array
    %       transmission    Spectrum object
    %       thickness_mm    float scalar
    %
    %   methods
    %       BPFilter        Constructor
    %
    %   inherited methods
    %       show            Shows property transmission. Works with arrays
    
    properties (GetAccess = public, SetAccess = private)
        band
    end
    
    methods
        function obj = BPFilter(name_, manufacturer_, transmission_, ...
                thickness_mm_)
            %BPFilter: Constructor.
            %
            %   Input:  char array (name)
            %           char array (manufacturer)            
            %           Spectrum (transmission)
            %           float scalar (thickness in mm)
            %   Output: BPFilter object
            
            obj = obj@Filter(name_, manufacturer_, transmission_, ...
                thickness_mm_);
            
            obj.band = Peak.fromSpectrum(obj.transmission);
        end
        
        function show(obj, logScale)
            %show shows the filter's transmission spectrum. Works with
            %arrays (plots in one window).
            %
            %   Input:  logical scalar (true = log scaled, def = false)
            
            if nargin < 2, logScale = false; end
            if ~Misc.is(logScale, 'logical', 'scalar')
                error('Input must be a logial scalar.');
            end
            
            obj.show@Filter(logScale);
            legend('AutoUpdate', 'off');
            limy = get(gca, 'ylim');
            
            for i = 1 : numel(obj)
                nband = numel(obj(i).band);
                for j = 1 : nband
                    plot([obj(i).band(j).lb * [1; 1], ...
                        obj(i).band(j).ub * [1; 1]], [limy; limy]', ...
                        '--', 'Color', .5 * ones(1, 3));
                    plot(obj(i).band(j).center * [1; 1], ...
                        [limy; limy]', 'g:');
                    plot(obj(i).band(j).max * [1; 1], ...
                        [limy; limy]', 'r:');
                end
            end
        end
    end 
end
