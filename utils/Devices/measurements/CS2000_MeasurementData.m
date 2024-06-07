classdef CS2000_MeasurementData
    %CS2000_MeasurementData encapsulates the main measurement data of the
    %Konica Minolta CS-2000, radiance and color, as well as the device
    %information and the reported measurement conditions.
    %CS2000_MeasurementData is base class of CS2000_Measurement and 
    %CS2000_Sample.
    %
    %   properties
    %       device              CS2000_Device object
    %       report              CS2000_Report array
    %       radiance            Spectrum array
    %       color               CS2000_Color array
    %
    %   methods
    %       CS2000_Measurement  Constructor
    
    properties (GetAccess = public, SetAccess = private)
        device
        report
        radiance
        color
    end
    
    methods
        function obj = CS2000_MeasurementData(device_, report_, ...
                radiance_, color_)
            %CS2000_MeasurementData: Constructor.
            %
            %   Input:  CS2000_Device object
            %           CS2000_Report array
            %           Spectrum array
            %           CS2000_Color array
            %   Output: CS2000_MeasurementData object

            if ~Misc.is(device_, 'CS2000_Device', 'scalar')
                error('First parameter must be a CS2000_Device object.');
            elseif ~Misc.is(report_, 'CS2000_Report', '~isempty')
                error(['Second parameter must be a non-empty ' ...
                    'CS2000_Report array.']);
            elseif ~Misc.is(radiance_, 'Spectrum', '~isempty')
                error(['Third parameter must be a non-empty Spectrum ' ...
                    'array.']);
            elseif ~Misc.is(color_, 'CS2000_Color', '~isempty')
                error(['Fourth parameter must be a non-empty ' ...
                    'CS2000_Color array.']);
            end
            
            obj.device = device_;
            obj.report = report_.merge;
            obj.radiance = Spectrum.merge(radiance_);
            obj.color = color_.merge;
            
            if numel(unique([obj.report.count, obj.color.count, ...
                    obj.radiance.count])) ~= 1
                error(['Different number of elements for properties ' ...
                    'report, radiance and color.']);
            end 
        end
    end 
end

