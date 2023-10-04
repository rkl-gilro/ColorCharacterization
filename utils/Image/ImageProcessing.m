classdef ImageProcessing
    %ImageProcessing contains static methods to process images.
    %
    %   static methods
    %       addMargin       Returns numeric or logical array (adds
    %                           1px-margin around on-px
    
    methods (Static)
        function I = addMargin(I, r)
            %addMargin adds a margin around the non-NaN (if float) or
            %non-zero regions (if int or logical) of an input image matrix.
            %The intensity of margin-px is set to that of the on-px at the 
            %boundary. 
            %
            %   Input:  numeric or logical matrix (image wo. margin)
            %           float scalar (margin radius in px)
            %   Output: numeric or logical matrix (image w. margin)
            
            dim = size(I);
            if ~((isnumeric(I) || islogical(I)) && numel(dim) == 2)
                error(['First parameter must be a numeric or ' ...
                    'logical matrix.']);
            elseif ~Misc.is(r, 'float', 'pos', 'scalar')
                error('Second parameter must be a positive float scalar.');
            end
            
            if islogical(I), valid = I;
            elseif isfloat(I), valid = ~isnan(I);
            else, valid = I > 0;
            end
            
            %get boundary px
            for ixy = 1 : 2
                tmp = diff(valid, 1, 3 - ixy);
                [yp, xp] = find(tmp == 1);                                  %margin on the left / upper side
                [yn, xn] = find(tmp == -1);                                 %margin on the right / lower side

                if ixy == 1                                                 %horizontal
                    xyb = [[xp + 1, yp]; [xn, yn]];                         %boundary
                else                                                        %vertical
                    xyb = [xyb; [xp, yp + 1]; [xn, yn]];                    %#ok. boundary
                end
            end
            xyb = unique(xyb, 'rows')';

            %identify margin region
            r_ = ceil(r);
            [y, x] = ndgrid(-r_ : r_, -r_ : r_);
            mask = (x .^ 2 + y .^ 2) <= r ^ 2;
            dim_ = dim + 2 * r_;
            xyb_ = xyb + r_;
            rArr = -r_ : r_;
            margin = false(dim_);
            for i = 1 : size(xyb_, 2)
                margin(xyb_(2, i) + rArr, xyb_(1, i) + rArr) = mask | ...
                    margin(xyb_(2, i) + rArr, xyb_(1, i) + rArr);
            end
            margin = margin(r_ + (1 : dim(1)), r_ + (1 : dim(2)));          %cut frame
            margin = margin & ~valid;                                       %remove valid px
            [xym(2, :), xym(1, :)] = find(margin);

            j = (xym(1, :) - 1) * dim(1) + xym(2, :);
            if islogical(I)
                I(j) = true;
            else
                [xyv(2, :), xyv(1, :)] = find(valid);
                ip = scatteredInterpolant(xyv(1, :)', xyv(2, :)', ...
                    double(I(valid)));
                I(j) = ip(xym(1, :)', xym(2, :)');
            end
        end
    end
end
   