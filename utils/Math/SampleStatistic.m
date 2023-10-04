classdef SampleStatistic < matlab.mixin.Copyable
    %SampleStatistic encapsulates mean, standard deviation, standard error,
    %lower and upper boundaries and number of samples of a data set.
    %
    %   properties
    %       m                   numeric array (mean)
    %       sd                  numeric array (standard deviation)
    %       se                  numeric array (standard error)
    %       lb                  numeric array (lower boundary)
    %       ub                  numeric array (upper boundary)
    %       n                   int scalar (number of samples)
    %       s                   numeric array (sum of squares of diff. from
    %                               mean; Welford, 962; Knuth, 1998)
    %
    %   methods
    %       SampleStatistic     Constructor
    %       update              Adds (a) new measurement(s)

    
    properties (GetAccess = public, SetAccess = protected)
        m
        sd
        se
        lb
        ub
        n
        s
    end
    
    methods
        function obj = SampleStatistic(varargin)
            %SampleStatistic: Constructor. Can take raw data as well as 
            %construct properties directly. If input consists of multiple 
            %samples, the measurement repetition must be coded in the last
            %dimension.
            %
            %   Input:      ON-THE-FLY
            %           numeric array
            %           logical scalar (true = multip. samples, def = true)
            %               OR PREPROCESSED
            %           numeric array (mean)
            %           numeric array (standard deviation)
            %           numeic array (standard error)
            %           numeric array (lower boundary)
            %           numeric array (upper boundary)
            %           int scalar (number of samples)
            %   Output: SampleStatistic object
            
            if any(nargin == 1 : 3)                                         %input is raw data, statistics will be computed here
                if nargin < 2, varargin{2} = true; end                      %last dimension is measurement repetition by default
                
                if ~isnumeric(varargin{1})
                    error('First parameter must be numeric.');
                elseif ~Misc.is(varargin{2}, 'logical', 'scalar')
                    error('Second parameter must be a logical scalar.');
                end
                
                if ~isfloat(varargin{1})
                    varargin{1} = double(varargin{1});                      %typecast to double if input is not float
                end
                dim = size(varargin{1});
                ndim = numel(dim);

                if varargin{2}
                    if ndim == 2 && dim(2) == 1, i = 1;
                    else, i = numel(dim);
                    end
                    obj.n = size(varargin{1}, i);
                    obj.m = mean(varargin{1}, i);
                    obj.sd = std(varargin{1}, 0, i);
                    obj.se = obj.sd / sqrt(obj.n);
                    obj.lb = min(varargin{1}, [], i);
                    obj.ub = max(varargin{1}, [], i);
                else
                    obj.n = 1;
                    obj.m = varargin{1};
                    obj.sd = nan(dim, class(varargin{1}));
                    obj.se = nan(dim, class(varargin{1}));
                    obj.lb = varargin{1};
                    obj.ub = varargin{1};
                end
                
            elseif nargin == 6                                              %data are pre-processed, each property is defined 
                for i = 1 : nargin
                    if ~isnumeric(varargin{i})
                        error('%s parameter must be numeric arrays.', ...
                            Misc.ordinalNumber(i));
                    elseif ~isfloat(varargin{i})
                        varargin{i} = double(varargin{i});                  %typecast to double if not float
                    end
                end
                
                %check size and type of sd, lb, and ub
                dim = size(varargin{1});
                type = class(varargin{1});
                for i = 2 : 5
                    if ~isequal(size(varargin{i}), dim)
                        error('%s parameter has a different size.', ...
                            Misc.ordinalNumber(i));
                    elseif ~isequal(type, class(varargin{i}))
                        error('%s parameter has a different type.', ...
                            Misc.ordinalNumber(i));
                    end
                end
                
                if any(varargin{2} < 0)
                    error(['Second parameter (standard deviation) ' ...
                        'contains negative values.']);
                elseif any(varargin{3} < 0)
                    error(['Third parameter (standard error) ' ...
                        'contains negative values.']);
                elseif any(varargin{3} > varargin{2})
                    error(['Third parameter (standard error) greater ' ...
                        'than second parameter (standard deviation).']);
                elseif any(varargin{4} > varargin{1})
                    error(['Fourth parameter (lower boundary) greater ' ...
                        'than first parameter (mean).']);
                elseif any(varargin{5} < varargin{1})
                    error(['Fifth parameter (upper boundary) smaller ' ...
                        'than first parameter (mean).']);
                elseif ~Misc.is(varargin{6}, 'pos', 'int', 'scalar')
                    error('Sixth parameter must be positive int scalar.');
                end
                
                obj.m = varargin{1};
                obj.sd = varargin{2};
                obj.se = varargin{3};
                obj.lb = varargin{4};
                obj.ub = varargin{5};
                obj.n = varargin{6};
            elseif nargin > 0
                error(['Expected two (on-the-fly) or six ' ...
                    '(pre-processed) input parameters.']);
            end
        end
        
        function update(obj, x)
            %update updates all properties with one or mutliple new
            %samples.
            %
            %    Input: numeric array

            dim = size(obj.m);
            dimx = size(x);
            ndim = numel(dim);
            ndimx = numel(dimx);
            
            if ~(isnumeric(x) && any(ndimx == ndim + [0 1]) && ...
                isequal(dim, dimx(1 : ndim)))                               %numeric AND dimesions equal to mean or (one new sample) or one more (multiple news samples) AND dimensions fit to mean
                error(['Input must be a numeric %d ', ...
                    repmat('x %d ', [1 ndim - 1]), 'x n array.'], dim);
            end
            nSample = size(x, ndim + 1);                                    %number of samples
            
            if isempty(obj.s)                                               %if this is the first update
                if obj.n == 1, obj.s = 0;
                else, obj.s = (obj.n - 1) * obj.sd .^ 2;
                end
            end
            
            %typecast if necessary
            if ~isequal(class(x), class(obj.m))
                x = typecast(x, class(obj.m)); 
            end
            
            obj.lb = min(obj.lb, min(x, [], ndim + 1));
            obj.ub = max(obj.ub, max(x, [], ndim + 1));
            
            %on the fly: mean and sum of squares of differences from mean
            %(Welford, 1962; Knuth, 1998)
            nDataPerSample = prod(dimx) / nSample;
            for i = 1 : nSample
                j = (i - 1) * nDataPerSample + (1 : nDataPerSample);
                this_x = reshape(x(j), dimx(1 : ndim));
                delta = this_x - obj.m;

                obj.n = obj.n + 1;
                obj.m = obj.m + delta / obj.n;
                obj.s = obj.s + delta .* (this_x - obj.m);
            end

            v = obj.s / (obj.n - 1);                                        %variance
            v(v < 0) = 0;
            obj.sd = sqrt(v);
            obj.se = obj.sd / sqrt(obj.n);
        end        
    end
end

