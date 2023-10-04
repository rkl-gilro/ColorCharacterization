classdef AFC_Quest < AFC_Method
    %AFC_Quest encapsulates properties and parameters of the PTB3 Quest
    %method. Base class is AFC_Method.
    %
    %   properties
    %       intensity           float array (log10 intensities tested)
    %       response            logical array (correctness of user resp.)
    %       pdf                 double matrix (probability of log10 
    %                           intensities rel. to thrPrior to be the 
    %                           threshold, [intensitiy, probability])
    %       thrPrior            float scalar (prior log10 threshold)
    %       thrPriorSd          float scalar (log10 sd of thrPrior)
    %       thrEst              float array (log10 of estimated thresholds)
    %       weibull             Weibull object
    %       range               float scalar (log10 intensity range)
    %       grain               float scalar (log10 intensity step size)
    %       mode                char array ('mean' (improved method by 
    %                           King-Smith et al, 1994) or 'mode' (original
    %                           method by Watson & Pelli, 1983)
    %
    %   inherited properties
    %       nPos                float scalar (number of AF choices)
    %       nMaxPosRep          int scalar (max. num. of succeeding 
    %                               repetitions of the same position)
    %       iTrial              int scalar (trial counter)
    %       posSeq              int array (position sequence)
    %
    %   methods
    %       AFC_Quest           Constructor
    %       reset               Returns AFC_Quest obj. (resets thrEst and
    %                               pdf, calls AFC_Method.reset)
    %       update              Returns AFC_Quest obj. (updates prop. pdf, 
    %                               counts up iTrial)
    %       simulate            Returns logical (simulates observer resp.)
    %       simulateExp         Returns AFC_Quest object (sim. observer 
    %                           responses and plots real and est. thr.)
    %
    %   inherited methods
    %       pRand               float scalar (prob. of correct rand. resp.)
    %       pos                 Returns int scalar (current position)
    %       update              Returns AFC_Method obj. (counts up iTrial)
    %       rand                Returns AFC Method obj. (randomizes posSeq)
        
    properties (GetAccess = public, SetAccess = private)
        intensity 
        response
        pdf
        thrPrior
        thrPriorSd
        thrEst
        weibull
        range
        grain
        method
    end
    
    methods
        function obj = AFC_Quest(nPos_, nTrialPerRep_, nRep_, ...
                nMaxRepOfPos_, thrPrior_, thrPriorSd_, varargin)
            %AFC_MoCS: Constructor.
            %
            %   Input:  int scalar (number of AFC positions)
            %           int scalar (num. of trials per repetition)
            %           int scalar (num. of repetitions)
            %           int scalar (num. of max. succ. rep. of same pos.)
            %           float scalar (prior threshold estimate)
            %           float scalar (sd of prior)
            %
            %               OPTIONAL, in key / value pairs
            %           weibull     Weibull object
            %           range       float scalar (log10 intensity range, 
            %                       def = 5)
            %           grain       float scalar (log10 step size, 
            %                       def = .01)
            %           method      char array ('mean' (improved method by 
            %                       King-Smith et al, 1994) or 'mode' 
            %                       (original method by Watson & Pelli, 
            %                       1983)
            %
            %   Output: AFC_Quest object
            
            obj = obj@AFC_Method(nPos_, nTrialPerRep_, nRep_,...
                nMaxRepOfPos_);
            
            if ~Misc.is(thrPrior_, 'float', 'scalar')
                error('Fifth parameter must be a float scalar.');
            elseif ~Misc.is(thrPriorSd_, 'float', 'pos', 'scalar')
                error('Sixth parameter must be a positive float scalar.');
            end
            
            %parse varargin
            n = numel(varargin);
            if mod(n, 2) == 0
                error('Even number of parameters expected.');
            end
            
            %default values
            range_ = 5;
            grain_ = .01;
            method_ = 'mean';
            
            for i = 1 : 2 : numel(varargin)
                if ~ischar(varargin{i})
                    error('%s parameter must be a char array.', ...
                        Misc.ordinalNumber(i + 4));
                elseif isequal(varargin{i}, 'weibull')
                    if ~Misc.is(varargin{i + 1}, 'Weibull', 'scalar')
                        error('%s parameter must be a Weibull object.', ...
                            Misc.ordinalNumber(i + 1));
                    end
                    weibull_ = varargin{i + 1};
                elseif isequal(varargin{i}, 'range')
                    if ~Misc.is(varargin{i + 1}, 'float', 'pos')
                        error(['%s parameter must be a positive ' ...
                            'float scalar.'], Misc.ordinalNumber(i + 1));
                    end
                    range_ = varargin{i + 1};
                elseif isequal(varargin{i}, 'grain')
                    if ~Misc.is(varargin{i + 1}, 'float', 'pos')
                        error(['%s parameter must be a positive float ' ...
                            'scalar.'], Misc.ordinalNumber(i + 1));
                    end
                    grain_ = varargin{i + 1};
                elseif isequal(varargin{i}, 'method')
                    valid = {'mean', 'mode'};
                    if ~Misc.isInCell(varargin{i + 1}, valid)
                        error('%s parameter must be %s.', ...
                            Misc.ordinalNumber(i + 1), ...
                            Misc.cellToList(valid));
                    end
                    method_ = varargin{i + 1};
                else
                    error('%d parameter contains unknown key %s.', ...
                        Misc.ordinalNumber(i), varargin{i});
                end
            end

            if ~exist('weibull', 'var')
                weibull_ = Weibull(3.5, .01, obj.pRand, thrPrior_);
            end
            
            if weibull_.gamma ~= obj.pRand
                error(['Weibull gamma parameter does not match the ' ...
                    'number of AFC.']);
            elseif range_ / grain_ < 2
                error(['Property range must be at least twice as big ' ...
                    'as property grain.']);
            end
            
            obj.thrPrior = double(thrPrior_);
            obj.thrPriorSd = double(thrPriorSd_);
            obj.weibull = weibull_;
            obj.range = double(range_);
            obj.grain = double(grain_);
            obj.pdf(:, 1) = -obj.range / 2 : obj.grain : obj.range / 2;     %log10 stimulus intensities relative to thrPriori
            obj.method = method_;
        
            %initialize property posSeq
            dim = [obj.nPos, obj.nTrial / obj.nPos];
            obj.posSeq = repmat(1 : dim(1), [1, dim(2)]);                   %sequence of position indices
            
            %set thrEst, pdf, and call rand
            obj = obj.reset;
        end
        
        function reset(obj)
            %reset resets properties thrEst, pdf, and iTrial, and calls
            %rand.
            
            obj.thrEst = obj.thrPrior;
            obj.pdf(:, 2) = Math.gauss(obj.pdf(:, 1), obj.thrPriorSd);
            obj.iTrial = 1;
            obj.rand;
        end
        
        function update(obj, response_)
            %update updates the properties intensity, response, and pdf
            %with the data gained from the last trial.
            %
            %   Input:  AFC_Quest object
            %           logical scalar (response)
            %           float scalar (log10 intensity, optional)
            
            obj.errIfFinished;
            
            if ~Misc.is(response_, 'logical', 'scalar')
                error('First parameter must be a logical scalar.');
            elseif ~Misc.is(intensity_, 'float', 'scalar')
                error('Second parameter must be a float scalar.');
            end
            obj.response(end + 1) = response_;
            obj.intensity(end + 1) = intensity_;

            x = obj.intensity(end) + obj.pdf(:, 1);                         %intensity range shifted by last intensity
            s = obj.weibull.getProbability(x);                              %pdf factor
            if ~obj.response(end), s = 1 - s; end                           %if response was negative, take the inverse
            s = s(end : -1 : 1);

            obj.pdf(:, 2) = obj.pdf(:, 2) .* s;                             %updated pdf
            obj.pdf(:, 2) = obj.pdf(:, 2) / sum(obj.pdf(:, 2));             %normalize, otherwise underflow

            %set thrEst            
            if isequal(obj.method, 'mean')
                obj.thrEst(end + 1) = sum(prod(obj.pdf, 2)) / ...
                    sum(obj.pdf(:, 2)) + obj.thrPrior;
            elseif isequal(obj.method, 'mode')
                [~, iMode] = max(obj.pdf(:, 2));
                obj.thrEst(end + 1) = obj.pdf(iMode, 1) + obj.thrPrior;
            end

            obj.iTrial = obj.iTrial + 1;                                    %count up property iTrial
        end
        
        function b = simulate(obj, observer, x)
            %simulate simulates the response of an observer for a given
            %log10 intensity. 
            %
            %   Input:  Weibull object (pschyometric function of observer, 
            %               default is the prior)
            %           float scalar (log10 intensity, default is the last 
            %               estimated threshold)
            %   Output: logical (true if if user response is correct)
            
            if nargin < 3, x = obj.thrEst(end); end
            if nargin < 2, observer = obj.weibull; end

            if ~Misc.is(observer, 'Weibull', 'scalar')
                error('First parameter must be a Weibull object.');
            elseif ~Misc.is(x, 'float', 'scalar', '~isnan')
                eror('Second parameter must be a non-NaN float scalar.');
            end
            
            b = rand < observer.getProbability(x);
        end
        
        function obj = simulateExp(obj, observer, flagPlot)
            %simulateExp simulates the response of an observer for the 
            %remaining trials. In each trial, the currently estimated 
            %threshold is presentedto the observer. 
            %
            %   Input:  Weibull object (pschyometric function of observer, 
            %               default is the prior)
            %           logical scalar (plots thresholds if true)           
            %   Output: AFC_Quest object
            
            if nargin < 4, flagPlot = true; end
            if nargin < 3, observer = obj.weibull; end
 
            if ~Misc.is(observer, 'Weibull', 'scalar')
                error('First parameter must be a Weibull object.');
            elseif ~Misc.is(flagPlot, 'logical', 'scalar')
                eror('Second parameter must be a logical scalar.');
            end
            
            for i = obj.iTrial : obj.nTrial
                obj = obj.update(obj.simulate(observer));
            end
                
            if flagPlot
                Misc.dockedFigure; 
                hold on
                h = [plot(0 : ntrial, obj.thrEst, '.-'), ...
                    plot([0 ntrial], observer.thr * [1 1])];
                xlabel('trial numnber');
                ylabel('log10 intensity');
                legend(h, {'estimated thresholds', 'true threshold'});
            end
        end
    end
 end

