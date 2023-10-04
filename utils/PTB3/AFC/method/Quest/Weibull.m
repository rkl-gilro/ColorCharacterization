classdef Weibull
    %Weibull encapsulates the parameters of a psychometricWeibull function.
    %Note: Intensities are log10 scaled.
    %
    %   properties
    %       beta            float scalar (slope parameter)
    %       delta           float scalar (prob. of missed trials)
    %       gamma           float scalar (prob. of correct response for
    %                       random input)
    %       thr             float scalar (log10 threshold intensity)
    %       pThr            float scalar (threshold probability)
    %
    %   methods
    %       Weibull         Constructor
    %       getProbability  Returns float scalar (probability of correct 
    %                       response to log10 intensity)
    
    properties (GetAccess = public, SetAccess = private)
        beta
        delta
        gamma
        thr
        pThr
    end
    
    methods
        function obj = Weibull(beta_, delta_, gamma_, thr_, pThr_)
            %Weibull: Constructor. If no threshold proability is defined,
            %the inflection point will be taken.
            %
            %   Input:  float scalar (slope parameter)
            %           float scalar (prob. of missed trials)
            %           float scalar (prob. baseline of corr. response)
            %           float scalar (log10 threshold intensity)
            %           float scalar (threshold probability, optional)
            
            if ~Misc.is(beta_, 'float', 'pos', 'scalar')
                error('First parameter must be a positive scalar.');
            elseif ~Misc.is(delta_, 'float', 'scalar', [0, 1])
                error('Second parameter must be a float scalar in [0 1].');
            elseif ~Misc.is(gamma_, 'float', 'scalar', [0, 1])
                error('Third parameter must be a float scalar in [0 1].');
            elseif ~Misc.is(thr_, 'float', 'scalar')
                error('Fourth parameter must be a float scalar.');
            end
            
            if nargin < 5
                pThr_ = (1 - gamma_) / 2 + gamma_;
            end
            if ~Misc.is(pThr_, 'float', 'scalar', [gamma_, 1 - delta_])
                error(['First parameter must be float scalar in ' ...
                    '[%.3f %.3f].'], ceil(gamma_ * 1000) / 1000, ...
                    floor(1 - delta_ * 1000) / 1000);
            end
            
            obj.beta = beta_;
            obj.delta = delta_;
            obj.gamma = gamma_;
            obj.thr = thr_;
            obj.pThr = pThr_;
        end
        
        function p = getProbability(obj, x)
            %getProbability returns the probability of detection for a
            %given intensity (intensities expressed as log10) based on the 
            %Weibull function.
            %
            %   Input:  float scalar (log10 intensity)
            
            if ~Misc.is(x, 'float', '~isnan')
                error('First parameter must be a non-NaN float scalar.')
            end
            
            x = x - obj.thr;                                                %intensity relative to threshold
            dx = log10(-log(((obj.pThr - obj.gamma * obj.delta) / ...
                (1 - obj.delta) - 1) / (obj.gamma - 1))) / obj.beta;        %intensity offset to bring weibull function to pThr at relative intensity zero
            p = obj.delta * obj.gamma + (1 - obj.delta) * ...
                (1 - (1 - obj.gamma) * exp(-10 .^ (obj.beta * (x + dx))));  %probability for correct response
        end
    end
end

