classdef CS2000_Compensation
    %CS2000_Compensation encapsulates spectral correction parameters for 
    %the Konica Minolta CS-2000 (for each measurement angle setting). 
    %CS2000_Compensation object is used in CS2000_Lens and 
    %CS2000_ExternalND.
    %
    %   properties
    %       deg_1                   Spectrum object (meas. angle 1°)
    %       deg_0_2                 Spectrum object (meas. angle 0.2°)
    %       deg_0_1                 Spectrum object (meas. angle 0.1°)
    %
    %   methods
    %       CS2000_Compensation     Constructor
    
    properties (GetAccess = public, SetAccess = protected)
        deg_1
        deg_0_2
        deg_0_1
    end
    
    methods
        function obj = CS2000_Compensation(deg_1_, deg_0_2_, deg_0_1_)
            %CS2000_Compensation: Constructor.
            %
            %   Input:  Spectrum object (for measurement angle 1°)
            %           Spectrum object (for measurement angle 0.2°)
            %           Spectrum object (for measurement angle 0.1°)
            %   Output: CS2000_Compensation object

            obj.deg_1 = deg_1_;
            obj.deg_0_2 = deg_0_2_;
            obj.deg_0_1 = deg_0_1_;
            
            field = fieldnames(obj);
            for i = 1 : 3
                if ~Misc.is(obj.(field{i}), 'Spectrum', 'scalar')
                    error('%s parameter must be a Spectrum object.', ...
                        Misc.ordinalNumber(i));
                elseif ~Misc.is(obj.(field{i}).value, 'float', [0, 1])
                        error(['Compensation values of %s parameter ' ...
                            'must be in [0 1].'], Misc.ordinalNumber(i));
                end
                obj.(field{i}) = obj.(field{i}).setDomain(...
                    CS2000.getWavelength);
            end
        end
    end
end