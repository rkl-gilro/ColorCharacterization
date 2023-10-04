classdef (Abstract) Color
    %Color is an abstract class that contains static functions for color 
    %computations.
    
    methods(Static)
        function x = XYZ(spectrum, cmf)
            %xyY: Returns X, Y, and Z for a given Spectrum and CMF object.
            %Note: Multiply with 683 to transform Y to cd/sqm.
            %
            %   Input:  Spectrum object
            %           CMF object
            %   Output: XYZ values (column vector or matrix)
            
            if ~Misc.is(spectrum, 'Spectrum', 'scalar')
                error('First parameter must be a Spectrum object.');
            elseif ~Misc.is(cmf, 'CMF', 'scalar')
                error('Second parameter must be a CMF object.');
            end
            
            tmp = Spectrum.commonDomain([spectrum, cmf.spectrum]);
            x = reshape((tmp(1).value(:, :)' * tmp(2).value)', ...
                [tmp(2).count, tmp(1).count]);
        end
        
        function x = xyY(spectrum, cmf)
            %xyY: Returns x, y, and Y for a given Spectrum object, where Y
            %is returned in cd/sqm.
            %
            %   Input:  Spectrum object
            %           CMF object
            %   Output: xyY values (column vector or matrix)
            
            if ~Misc.is(spectrum, 'Spectrum', 'scalar')
                error('First parameter must be a Spectrum object.');
            elseif ~Misc.is(cmf, 'CMF', 'scalar')
                error('Second parameter must be a CMF object.');
            end
            
            x = Color.XYZToxyY(Color.XYZ(spectrum, cmf));
        end
        
        function [xyY] = XYZToxyY(XYZ)
            %XYZToxyY: Converts XYZ values (Y is not scaled to cd/sqm) into
            %xyY (Y unit is in cd/sqm).
            %
            %   Input:  3 x n float ([X; Y; Z], where Y is NOT in cd/sqm)
            %   Output: 3 x n float ([x; y; Y], where Y is in cd/sqm)
            
            if ~Misc.is(XYZ, 'float', {'size', 1, 3}, {'>=' 0})
                error('Input must be a 3 x n float array >= 0.')
            end
            
            X = XYZ(1, :);
            Y = XYZ(2, :);                                                  %conversion from W/sqm to candela/sqm
            sumXYZ = sum(XYZ);
            x = X ./ sumXYZ;
            y = Y ./ sumXYZ;
            xyY = [x; y; Y * 683];
        end
        
        function XYZ = xyYToXYZ(xyY)
            %xyYToXYZ: Converts xyY to XYZ values.
            %
            %   Input:  3 x n float ([x; y; Y], where Y is in cd/sqm)
            %   Output: 3 x n float ([X; Y; Z], where Y is NOT in cd/sqm)
            
            if ~Misc.is(xyY, 'float', {'size', 1, 3}, {'>=', 0})
                error('Input must be a 3 x n float array >= 0.');
            end
            
            xyY(3, :) = xyY(3, :) / 683;
            XYZ = zeros(size(xyY));
            z = 1 - xyY(1,:) - xyY(2, :);
            XYZ(1, :) = xyY(3, :) .* xyY(1, :) ./ xyY(2, :);
            XYZ(2, :) = xyY(3, :);
            XYZ(3, :) = xyY(3, :) .* z ./ xyY(2, :);
        end
        
        function RGB = XYZToRGB(XYZ)
            %XYZToRGB converts XYZ values to sRGB linear primaries.
            %Note:  The forward transfer function (gamma) is not included. 
            %To account for it, apply Color.gammaRGB on the output. Values 
            %must be scaled so that for D65 Y = 1.
            %
            %   Input:  3 x n float ([X; Y; Z], where Y is NOT in cd/sqm)
            %   Output: 3 x n float ([R; G; B], linear sRGB in [0 1])

            if ~(isfloat(XYZ) && size(XYZ, 1) == 3)
                error('Input must be floating number with 3 rows.');
            end
            
            RGB = [3.2406, -1.5372, -.4986; ...
                   -.9689, 1.8758, .0415; ...
                   .0557, -.2040, 1.0570] * XYZ;
        end
            
        function XYZ = RGBToXYZ(RGB)
            %RGBToXYZ converts (linear) RGB values to XYZ values.
            %Note: The reverse transfer function (gamma) is not included. 
            %To account for it, apply Color.reverseGammaRGB on the input 
            %beforehand.
            %
            %   Input:  3 x n float ([R; G; B], linear sRGB)
            %   Output: 3 x n float ([X; Y; Z], where Y is NOT in cd/sqm)
            
            if ~Misc.is(RGB, 'numeric', {'size', 1, 3}, {'>=', 0})
                error('Input must be 3 x n numeric array >= 0.');
            end
            if isinteger(RGB)
                RGB = double(RGB) / double(intmax(class(RGB)));
            end
                
            XYZ = [.4124, .3576, .1805; ...
                   .2126, .7152, .0722; ...
                   .0193, .1192, .9505] * RGB;
        end
        
        function xyY = RGBToxyY(RGB)
            %RGBToxyY converts (linear) RGB values to xyY values.
            %Note: The reverse transfer function (gamma) is not included. 
            %To account for it, apply Color.reverseGammaRGB on the input 
            %beforehand.
            %       
            %   Input:  3 x n numeric ([R; G; B], linear sRGB)
            %   Output: 3 x n float ([x; y; Y], where Y is in cd/sqm)
        
            xyY = Color.XYZToxyY(Color.RGBToXYZ(RGB));
        end

        function RGB = xyYToRGB(xyY)
            %xyYToRGB converts xyY values to sRGB linear primaries.
            %Note: The forward transfer function (gamma) is not included. 
            %To account for it, apply Color.gammaRGB on the output. Values 
            %must be scaled so that for D65 Y = 1.
            %
            %   Input:  3 x n float ([x; y; Y], where Y is in cd/sqm)
            %   Output: 3 x n float ([R; G; B])
        
            RGB = Color.XYZToRGB(Color.xyYToXYZ(xyY));
        end
        
        function RGB = gammaRGB(RGB)
            %gammaRGB applies the sRGB transfer function on linear RGB 
            %values. Use this function to get the RGB values for a sRGB 
            %display, e.g. after converting XYZ into linear RGB values with
            %Color.XYZToRGB.
            %
            %   Input:  3 x n numeric ([R; G; B], linear sRGB)
            %           3 x n float ([R; G; B], gamma sRGB in [0 1])
            
            if ~Misc.is(RGB, 'numeric', {'size', 1, 3}, {'>=', 0})
                error('Input must be 3 x n numeric array >= 0.');
            end
            if isinteger(RGB)
                RGB = double(RGB) / double(intmax(class(RGB)));
            end
            
            i = RGB <= .0031308;
            alpha = .055;
            RGB(i) = 12.92 * RGB(i);
            RGB(~i) = (1 + alpha) * RGB(~i) .^ (1 / 2.4) - alpha;
        end
        
        function RGB = reverseGammaRGB(RGB)
            %reverseGammaRGB applies the reverse sRGB transfer function on
            %sRGB values. Use this function to convert RGB values shown on 
            %a sRGB display to linear RGB values, e.g., to convert further 
            %to XYZ using Color.RGBToXYZ.
            %
            %   Input:  3 x n numeric ([R; G; B], sRGB)
            %           3 x n float ([R; G; B], linear sRGB in [0 1])
            
            if ~Misc.is(RGB, 'numeric', {'size', 1, 3}, {'>=', 0})
                error('Input must be 3 x n numeric array >= 0.');
            end
            if isinteger(RGB)
                RGB = double(RGB) / double(intmax(class(RGB)));
            end
            
            i = RGB <= .04045;
            alpha = .055;
            RGB(i) = RGB(i) / 12.92;
            RGB(~i) = ((RGB(~i) + alpha) / (1 + alpha)) .^ 2.4;
        end
    end
end
    
