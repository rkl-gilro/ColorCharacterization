classdef CS2000_Color
    %CS2000_Color encapsulates the color information of the Konica Minolta 
    %CS-2000.
    %
    %   properties
    %       data            float array (raw color data)
    %
    %   methods
    %       CS2000_Color    Constructor
    %       merge           Returns CS2000_Color object (merges an array)
    %       count           Returns int scalar (number of measurements)
    %       getData         Returns 1 x n float (colorimetric value(s))
    %       XYZ             Returns 3 x n float [X, Y, Z]
    %       xyY             Returns 3 x n float [x, y, Y]
    %       uvY             Returns 3 x n float [u', v', Y]
    %       Tdelta_uvY      Returns 3 x n float [T, delta_uv, Y]
    %       lambda_dPeY     Returns 3 x n float [lambda_dPeY]
    %       XYZ10           Returns 3 x n float [X10, Y10, Z10]
    %       xyY10           Returns 3 x n float [x10, y10, Y]
    %       uvY10           Returns 3 x n float [u10, v10, Y]
    %       Tdelta_uvY      Returns 3 x n float [T10, delta_uv10, Y]
    %       lambda_dPeY     Returns 3 x n float [lambda_d10, Pe10, Y]
    %       Le              Returns 1 x n float Le
    %       Lv              Returns 1 x n float Lv

    properties (Hidden, Constant)
        unit = {'Le', 'Lv', 'X', 'Y', 'Z', 'x', 'y', 'u', 'v', 'T', ...
            'delta_uv', 'lambda_d', 'Pe', 'X10', 'Y10', 'Z10', 'x10', ...
            'y10', 'u10', 'v10', 'T10', 'delta_uv10', 'lambda_d10', ...
            'Pe10'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        data
    end
    
    methods (Access = public)
        function obj = CS2000_Color(data_)
            %CS2000_Color: Constructor.
            %
            %   Input:  24 x n float array (one column per measurement)
            %   Output: CS2000_Color object
            
            if ~Misc.is(data_, 'float', {'size', 1, 24})
                error('Input must be a 24 x  n float array.');
            end
            obj.data = data_;
        end
        
        function obj = merge(obj)
            %merge merges multiple CS2000_Color objects into one.
            %
            %   Input:  CS2000_Color array
            %   Output: CS2000_Color object
            
            if numel(obj) > 1
                tmp = obj(1);
                for i = 2 : numel(obj)
                    n = size(obj(i).data, 2);
                    tmp.data(:, end + (1 : n)) = obj(i).data;
                end
                obj = tmp;
            end
        end
        
        function x = count(obj)
            %count returns the number of columns of property data, i.e, the
            %number of measurements.
            %
            %   Output: int scalar
            
            x = size(obj.data, 2);
        end
        
        function x = getData(obj, c)
            %getData returns the demanded colorimetric value(s).
            %
            %   Input:  char array(Le, Lv, X, Y, Z, x, y, u, v, T, 
            %               delta_uv, lambda_d, Pe, X10, Y10, Z10,
            %               x10, y10, u10, v10, T10, delta_uv10,
            %               lambda_d10, Pe10)
            %   Output: 1 x n float (colorimetric value(s))
            
            x = obj.data(obj.getIndexUnit(c), :);
        end
        
        function x = XYZ(obj)
            %XYZ returns X, Y, Z.
            %
            %   Output: 3 x n float array
            
            x = obj.data(3 : 5, :);
        end
        
        function x = xyY(obj)
            %xyY returns x, y, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([6, 7, 2], :);
        end
        
        function x = uvY(obj)
            %uvY returns u', v', Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([8, 9, 2], :);
        end
        
        function x = Tdelta_uvY(obj)
            %Tdelta_uvY returns T, delta_uv, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([10, 11, 2], :);
        end
        
        function x = lambda_dPeY(obj)
            %lambda_dPeY returns lambda_d, Pe, Y.
            %
            %   Output: 3 x n float array

            x = obj.data([12, 13, 2], :);
        end
        
        function x = XYZ10(obj)
            %XYZ10 returns X10, Y10, Z10.
            %
            %   Output: 3 x n float array
            
            x = obj.data(14 : 16, :);
        end

        function x = xyY10(obj)
            %xyY10 returns x10, y10, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([17, 18, 15], :);
        end
        
        function x = uvY10(obj)
            %uvY10 returns u'10, v'10, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([19, 20, 15], :);
        end
        
        function x = Tdelta_uvY10(obj)
            %Tdelta_uvY10 returns T10, delta_uv10, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([21, 22, 15], :);
        end
        
        function x = lambda_dPeY10(obj)
            %lambda_dPeY10 returns lambda_d10, Pe10, Y.
            %
            %   Output: 3 x n float array
            
            x = obj.data([23, 24, 15], :);
        end
        
        function x = Le(obj)
            %Le returns Le.
            %
            %   Output: 1 x n float array
            
            x = obj.data(1, :);
        end
        
        function x = Lv(obj)
            %Lv returns Lv.
            %
            %   Output: 1 x n float array
            
            x = obj.data(2, :);
        end
    end
    
    methods (Access = private)
        function i = getIndexUnit(obj, unit_)
            %getIndexUnit returns an index of property unit.
            %
            %   Input:  char array
            %   Output: int scalar
            
            if ~ischar(unit_), error('Input must be a char array.'); end
            [~, i] = ismember(unit_, obj.unit);
            if i == 0, error('Invalid colorimetric identifier.'); end
        end
    end 
end

