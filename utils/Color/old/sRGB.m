classdef sRGB
    %sRGB provides static methods to apply or remove sRGB gamma correction 
    %from RGB values.
    %
    %   methods
    %       gamma       Returns numeric array (applies gamma correction)
    %       degamma     Returns numeric array (removes gamma correction)
    
    methods (Static)
        function I = gamma(I, bitdepth)
            %gamma applies the sRGB gamma correction to a given numeric
            %array.
            %
            %   Input:  numeric array
            %           int scalar (bitdepth)
            %   Output: numeric array
            
            if nargin < 2, bitdepth = 8; end
            sRGB.checkInput(I, bitdepth);

            slope = 12.92;
            knee = .0031308;
            offset = .055;
            power = 1 / 2.4;
            
            %apply gamma
            I = sRGB.limitAndNorm(I, bitdepth);
            below = I < knee;
            I(below) = I(below) * slope;
            I(~below) = ((1 + offset) * (I(~below) .^ power) - offset);

            %scale to bitdepth range
            I = I * (2 ^ bitdepth - 1);
        end

        function I = degamma(I, bitdepth)
            %degamma applies the reverse sRGB gamma correction to a given 
            %numeric array.
            %
            %   Input:  numeric array
            %           int scalar (bitdepth)
            %   Output: numeric array
            
            if nargin < 2, bitdepth = 8; end
            sRGB.checkInput(I, bitdepth);

            slope = 12.92;
            knee = .04045;
            offset = .055;
            power = 2.4;
            
            %apply reverse gamma
            I = sRGB.limitAndNorm(I, bitdepth);
            below = I < knee;
            I(below) = I(below) / slope;
            I(~below) =  ((I(~below) + offset) ./ (1 + offset)) .^ power;

            %scale to bitdepth range
            I = I * (2 ^ bitdepth - 1);
        end
    end

    methods (Static, Hidden)
        function checkInput(I, bitdepth)
            %checkInput checks input parameters for fucntions of this
            %class.
            %
            %   Input:  numeric array
            %           int scalar (bitdepth)
            
            if ~isnumeric(I)
                error('First parameter must be a numeric array.');
            elseif ~Math.isPosScalar(bitdepth)
                error('Second parameter must be a positive int scalar.');
            end                
        end
        
        function I = limitAndNorm(I, bitdepth)
            %limitAndNorm limits a numeric array corresponding to a given
            %bitdepth and normalizes it to [0 1].
            %
            %   Input:  numeric array
            %           int scalar (bitdepth)
            %   Output: numeric array
            
            sRGB.checkInput(I, bitdepth);
            
            I = double(I);
            maxI = 2 ^ bitdepth - 1;
            I(I < 0) = 0;
            I(I > maxI) = maxI;
            I = I / maxI;
        end
   end
end
 