classdef AFC_NonDynMethod < AFC_Method
    %AFC_NonDynMethod encapsulates psychophysic methods and their
    %parametrization for an AFC experiment that do not change behavior 
    %based on the user's response. Base class of AFC_MoCS and AFC_Training.
    %
    %   properties
    %       nStim               int scalar (num. of trials per repetition)
    %       nRep                int scalar (num. of repetition)
    %       stimSeq             int array (sequence of trial indices)
    %
    %   inherited properties
    %       nPos                float scalar (number of AF choices)
    %       nMaxPosRep          int scalar (max. num. of succeeding 
    %                               repetitions of the same position)
    %       iTrial              int scalar (trial counter)
    %       posSeq              int array (position sequence)
    %
    %   methods 
    %       AFC_NonDynMethod    Constructor
    %       iStim               Returns int scalar (current trial index)
    %       nTrial              int scalar (total number of trials)
    %       rand                Returns AFC_NonDynMethod object (randomizes
    %                               posSeq and stimSeq)
    %
    %   inherited methods 
    %       pRand               float scalar (prob. of correct rand. resp.)
    %       pos                 Returns int scalar (current position)
    %       update              Returns AFC_Method obj. (counts up iTrial)
    
    properties (GetAccess = public, SetAccess = private)
        nStim
        nRep
    end

    methods
        function obj = AFC_NonDynMethod(nPos_, nMaxPosRep_, nStim_, nRep_)
            %AFC_NonDynMethod: Constructor.
            %
            %   Input:  int scalar (number of AFC positions)
            %           int scalar (num. of max. succ. rep. of same pos.)
            %           int scalar (num. of stimuli)
            %           int scalar (num. of repetitions)
            %   Output: AFC_NonDynMethod object

            obj = obj@AFC_Method(nPos_, nMaxPosRep_);
            
            if ~Misc.is(nStim_, 'pos', 'int', 'scalar')
                error('Third parameter must be a positive int scalar.');
            elseif mod(nStim_, obj.nPos) ~= 0
                error('Third parameter (%d) must be a multiple of %d.', ...
                nStim_, obj.nPos);                                          %otherwise position is not balanced
            elseif ~Misc.is(nRep_, 'pos', 'int', 'scalar')
                error('Fourth parameter must be a positive int scalar.');
            end
            
            obj.nStim = nStim_;
            obj.nRep = nRep_;
        end
        
        function x = iStim(obj)
            %iStim returns the index of the stimulus to test.
            %
            %   Output: int scalar
            
            obj.errIfFinished;
            x = obj.stimSeq(obj.iTrial);
        end
        
        function x = nTrial(obj)
            %nTrial returns the total number of trials.
            %
            %   Output: int scalar
            
            x = obj.nRep * obj.nStim;
        end
        
        function obj = rand(obj)
            %rand randomizes posSeq and stimSeq.
            %
            %   Output: AFC_MoCS object
            
            [obj, isort] = rand@AFC_Method(obj); 
            obj.stimSeq = obj.stimSeq(isort);
        end
    end
    
    methods (Access = protected)
        function errIfFinished(obj)
            %errIfFinished thors an error if iTrial is >= nTrial.
            
            if obj.iTrial >= obj.nTrial
                error('Maximal number of trials reached.');
            end
        end
    end
end
