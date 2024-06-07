classdef CS2000_Reflectance
    %CS2000_Recflectance encapsulates a reflectance measurement performed
    %with the Konica Minolta CS-2000.
    %    
    %   properties
    %       sample              CS2000_MeasurementData object
    %       white               CS2000_MeasurementData object
    %       whiteStandard       WhiteStandard object
    %
    %   methods
    %       CS2000_Reflectance  Constructor
    %       reflectance         Returns reflectance spectrum
    %       illumination        Returns illumination spectrum
    
    properties
        sample
        white
        whiteStandard
    end
    
    methods
        function obj = CS2000_Reflectance(sample_, white_, whiteStandard_)
            %CS2000_Reflectance: Constructor.
            %
            %   Input:  CS2000_MeasurementData object (of sample)
            %           CS2000_MeasurementData object (of white standard)
            %           White Standard object
            %   Output: CS2000_Reflectance object
            
            if ~Misc.is(sample_, 'CS2000_Measurement', 'scalar')
                error(['First parameter must be a CS2000_Measurement ' ...
                    'object.']);
            elseif ~Misc.is(white_, 'CS2000_Measurement', 'scalar')
                error(['Second parameter must be a CS2000_Measurement ' ...
                    'object.']);
            elseif ~Misc.is(whiteStandard_, 'WhiteStandard', 'scalar')
                error('Third parameter must be a WhiteStandard object.');
            end
               
            obj.sample = sample_;
            obj.white = white_;
            obj.whiteStandard = whiteStandard_;
        end
        
        function x = reflectance(obj)
            %reflectance returns the reflectance spectrum of property 
            %sample.
            %
            %   Output: Spectrum object
            
            tmp = Spectrum.commonDomain([...
                obj.sample.radiance ...
                obj.white.radiance.mean ...
                obj.whiteStandard.reflectance.mean]);
            x = Spectrum(tmp(1).wavelength, tmp(1).value .* ...
                repmat(tmp(3).value ./ tmp(2).value, ...
                [1 tmp(1).count]));
        end
        
        function x = illumination(obj)
            %illumination returns the spectrum of the illumination.
            %
            %   Output: Spectrum object
            
            tmp = Spectrum.commonDomain([obj.white.radiance.mean ...
                obj.whiteStandard.reflectance.mean]);
            x = Spectrum(tmp(1).wavelength, tmp(1).value ./ tmp(2).value);
        end
    end
end

