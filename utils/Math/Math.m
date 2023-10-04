classdef Math
    %Math is a provides static functions for data format checks and
    %elementary math operations.
    %
    %   static functions
    %       angle           Returns float scalar (angle btw two 2-dim vec.)
    %       degToRad        Returns float array
    %       fitPlane        Returns 3 x 1 float (Hesse normal form)
    %       gabor           Returns float array
    %       gauss           Returns float array
    %       hexToSingle     Returns single array
    %       lim             Returns 1 x 2 numeric array ([min, max])
    %       normalizeInt    Returns float array
    %       planeZ          Returns float array (z-values of plane)
    %       radToDeg        Returns float array
    %       singleToHex     Returns char array
    
    methods (Static)
        function x = angle(v1, v2)
            %angle returns the angle between two 2-dim vectors in rad, by 
            %which the first vector is mapped onto the second by a
            %counter-clockwise rotation.
            %
            %   Input:  2 x n float matrix [x; y]
            %           2 x n float matrix [x; y]
            %   Output: float scalar (angle in ]-pi pi])
            
            if ~Misc.is(v1, 'float', {'size', 1, 2})
                error('First paramater must be a 2 x n float array.');
            elseif ~Misc.is(v2, 'float', {'size', 1, 2})
                error('Second paramater must be a 2 x n float array.');
            end
            
            if size(v1, 2) == 1 && size(v2, 2) > 1
                v1 = repmat(v1, [1 size(v2, 2)]);
            elseif size(v2, 2) == 1 && size(v1, 2) > 1
                v2 = repmat(v2, [1 size(v1, 2)]);
            elseif size(v1, 2) ~= size(v2, 2)
                error('Input parameters must have the same size.');
            end
            
            l1 = sqrt(sum(v1 .^ 2));
            l2 = sqrt(sum(v2 .^ 2)); 
            if any([l1, l2] == 0)
                error('At least one vector has length zero.'); 
            end
            
            v0 = [1 0];
            x1 = acos((v0 * v1) ./ l1);
            x2 = acos((v0 * v2) ./ l2);

            j = v1(2, :) < 0;
            x1(j) = 2 * pi - x1(j);
            
            j = v2(2, :) < 0;
            x2(j) = 2 * pi - x2(j); 
            
            x = x2 - x1; 
            x(x == 2 * pi) = 0;

            j = (x > pi);
            x(j) = x(j) - 2 * pi;
            
            j = (x < -pi);
            x(j) = x(j) + 2 * pi;
        end
        
        function x_rad = degToRad(x_deg)
            %degToRad converts degree to rad.
            %   
            %   Input:  float array
            %   Output: float array
            
            if ~isfloat(x_deg), error('Input must be a float array.'); end
            x_rad = x_deg * pi / 180;
        end
        
        function b = fitPlane(xyz, optim)
            %fitPlane fits a plane into a set of 3d data.
            %
            %   Input:  3 x n float ([x; y; z])
            %           optimset structure (optional)
            %   Output: 3 x 1 float (compressed Hesse normal form, i.e., 
            %               angle norm vector to y/x-axis and distance)
            
            if nargin < 2, optim = optimset; end
            if ~(Misc.is(optim, 'struct', 'scalar') && ...
                    isequal(fieldnames(optimset), fieldnames(optim)))
                error('Second parameter must be an optimset struct.');
            end
            
            b = fminsearch(@(b) sum((Math.normFromAngle(b(1:2)) * xyz - ...
                b(3)) .^ 2), [0 0 0]', optim); 
        end
        
        function x = gabor(xy_deg, cycPerDeg, sigma_deg, amp, ...
                orientation, phase)
            %gabor returns values of a gabor function (a gaussian 
            %enveloped cosine).
            %
            %   Input:  2 x h x w float array ([x; y] in deg.)
            %           float scalar (cyc. per deg. of cosine)
            %           float scalar (sigma in deg)
            %           float scalar (amplitude, default = 1)
            %           float scalar (orientation in rad, default = 0)
            %           float scalar (phase in rad, default = 0)
            %   Output: float matrix
            
            if nargin < 6, phase = 0; end
            if nargin < 5, orientation = 0; end
            if nargin < 4, amp = 1; end
            
            if ~Misc.is(xy_deg, 'float', {'size', 1, 2})
                error('First parameter must be a 2 x n float array.');
            elseif ~Misc.is(cycPerDeg, 'float', 'pos', 'scalar')
                error('Second parameter must be a positive float scalar.');
            elseif ~Misc.is(sigma_deg, 'float', 'pos', 'scalar')
                error('Third parameter must be a positive float scalar.');
            elseif ~Misc.is(amp, 'float', 'scalar')
                error('Fourth parameter must be a float scalar.');
            elseif ~Misc.is(orientation, 'float', 'scalar')
                error('Fifth parameter must be a float scalar.');
            elseif ~Misc.is(phase, 'float', 'scalar')
                error('Sixth parameter must be a float scalar.');
            end
                
            d = squeeze(sqrt(sum(xy_deg .^ 2)));
            x = amp * Math.gauss(d, sigma_deg, 'max') .* ...
                squeeze(cos(cycPerDeg * pi * ...
                (cos(orientation) * xy_deg(1, :, :) + ...
                sin(orientation) * xy_deg(2, :, :)) + phase));
        end
        
        function y = gauss(x, sigma, normalization)
            %gauss returns a gaussian distribution function.
            %
            %   Input:  float array (values to be mapped)
            %           float scalar (sigma)
            %           char array (specifies the normalization type):
            %               sum         Output sum is 1 (default)
            %               max         Output max is 1
            %               continuous  Normalization for continuous values
            %                               (textbook normalization)
            %               none        Output is not normalized
            %   Output: float array
            %
            %   Example:
            %       x = linspace(-1, 1, 100);
            %       y = Math.gauss(x, .5);
            %       plot(x, y);
            
            valid = {'sum', 'max', 'continuous', 'none'};
            if nargin < 3, normalization = 'sum'; end
            if ~isfloat(x)
                error('First parameter must be a float array.');
            elseif ~Misc.is(sigma, 'float', 'scalar')
                error('Second parameter must be a float scalar.');
            elseif ~Misc.isInCell(normalization, valid)
                error('Third parameter must be %s.', ...
                    Misc.cellToList(valid));
            end                
            
            y = exp(-x .^ 2 / (2 * sigma ^ 2));
            
            if isequal(normalization, 'max')
                y = y / max(y(:));
            elseif isequal(normalization, 'sum')
                y = y / sum(y(:));
            elseif isequal(normalization, 'continuous')
                y = y / sqrt(2 * pi * sigma ^ 2);
            end
        end
        
        function dec = hexToSingle(hex)
            %hexToSingle converts hexadecimal values of single precision
            %(4-byte) values to decimal values.
            %
            %   Input:  char array (hexadecimal of single precision array)
            %   Output: float array (decimal)

            dec = typecast(hex2num(hex), 'single');
            dec = dec(2 : 2 : end);
        end
        
        function x = lim(x)
            %lim returns the limits of a numeric array ([min max]).
            %
            %   Input:  numeric array
            %   Output: 1 x 2 numeric
            
            if ~isnumeric(x) || isempty(x)
                error('Input must be a numeric, non-empty array.');
            end
            
            x = [min(x(:)), max(x(:))];
        end
        
        function x = normalizeInt(x)
            %normalizeInt converts int data types to double and normalizes
            %the value range of the integer class to [0 1]. E.g., 255 for 
            %uint8 would be normalized to 1. Does nothing when input is 
            %float. Useful to unify format and value range of numeric 
            %arrays that represent images.
            %
            %   Input:  numeric non-float array
            %   Output: float array
            
            if ~isfloat(x)
                c = class(x);
                x = (double(x) - double(intmin(c))) / double(intmax(c)); 
            end
        end
        
        function z = planeZ(xy, b)
            %planeZ returns the z values corresponding to input x and y
            %and the compressed Hesse normal form.
            %
            %   Input:  2 x n matrix ([x; y])
            %           3 x 1 vector (compressed Hesse normal form, i.e., 
            %           angle norm vector to y/x-axis and distance)
            %   Output: 1 x n vector (z-values)
            
            if ~(isfloat(xy) && size(xy, 1) == 2)
                error(['First parameter must be floating point and ' ...
                    'have two rows (x and y).']);
            elseif ~(isfloat(b) && numel(b) == 3)
                error(['Second parameter must be a floating point ' ...
                    'vector with 3 elements.']);
            end
            
            n = Math.normFromAngle(b);
            z = (b(3) - n(1:2) * xy) / n(3);
        end
        
        function x_deg = radToDeg(x_rad)
            %radToDeg converts rad to degree.
            %
            %   Input:  float array
            %   Output: float array
            
            if ~isfloat(x_rad), error('Input must be float array'.'); end
            x_deg = x_rad * 180 / pi;
        end
        
        function hex = singleToHex(dec)
            %singleToHex converts decimal value into big endian 4-byte 
            %hexadecimal value of single precision. 
            %
            %   Input:  Decimal array
            %   Output: hexadecimal char array of single precision array

            hex = num2hex(single(dec));
        end
    end
    
    methods (Static, Hidden)
        function n = normFromAngle(b)
            %normFromAngle returns a 3d norm vector from two angles
            %(rotation around y and x).
            %
            %   Input:  vector with 2 elements (rot. around [y; x] in rad)
            %   Output: 3 x 1 vector ([x; y; z])
            
            n = [cos(b(1)) * cos(b(2)), sin(b(2)), sin(b(1)) * cos(b(2))];
        end
    end
end

