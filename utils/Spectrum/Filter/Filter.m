classdef Filter < matlab.mixin.Heterogeneous
    %Filter encapsulates properties and methods for optical filters. Base
    %class for classes BPFilter (band pass) and NDFilter (neutral density).
    %Base class is matlab.mixin.Heterogeneous.
    %
    %   properties
    %       name            char array
    %       manufacturer    char array
    %       transmission    Spectrum object
    %       thickness_mm    float scalar
    %
    %   methods
    %       Filter          Constructor
    %       show            Shows property transmission. Works with arrays
    
    properties (GetAccess = public, SetAccess = private)
        name
        manufacturer
        transmission
        thickness_mm
    end
    
    methods
        function obj = Filter(name_, manufacturer_, transmission_, ...
                thickness_mm_)
            %Filter: Constructor.
            %
            %   Input:  char array (name)
            %           char array (manufacturer)            
            %           Spectrum (transmission)
            %           float scalar (thickness in mm)
            %   Output: Filter object
            
            if ~Misc.is(name_, 'char', '~isempty') 
                error('First parameter must be a non-empty char array.');
            elseif ~Misc.is(manufacturer_, 'char', '~isempty') 
                error('Second parameter must be a non-empty char array.');
            elseif ~Misc.is(transmission_, 'Spectrum', 'scalar')
                error('Third parameter must be a Spectrum object.');
            elseif ~Misc.is(transmission_.value, [0 1])
                error(['Property value of third parameter must be ' ...
                    'in [0 1].']);
            elseif ~Misc.is(thickness_mm_, 'float', 'scalar', 'pos')
                error(['Fourth parameter must be a positive float ' ...
                    'scalar.'])
            end
            
            obj.name = name_;
            obj.manufacturer = manufacturer_;
            obj.transmission = transmission_;
            obj.thickness_mm = thickness_mm_;
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
            
            n = numel(obj);
            label = cell(1, n);
            h = nan(1, n);
            Misc.dockedFigure;
            hold on
            
            for i = 1 : n
                h(i) = plot(obj(i).transmission.wavelength, ...
                    obj(i).transmission.value);
                label{i} = sprintf('%s %s', obj(i).manufacturer, ...
                    obj(i).name);
                label{i}(label{i} == '_') = ' ';                            %replace underline with space
            end
            
            xlabel('wavelength [nm]');
            ylabel('transmission');
            if logScale, set(gca, 'YScale', 'log'); end
            axis tight
            legend(h, label);
            box on
        end
    end
end

