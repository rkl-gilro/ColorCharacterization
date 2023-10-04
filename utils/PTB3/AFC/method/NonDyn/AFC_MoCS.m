classdef AFC_MoCS < AFC_NonDynMethod
    %AFC_MoCS encapsulates parameters and methods of the method of 
    %constant stimuli. Base class is AFC_NonDynMethod.
    %
    %   inherited properties
    %       nStim               int scalar (num. of trials per repetition)
    %       nRep                int scalar (num. of repetition)
    %       stimSeq             int array (sequence of stimulus indices)
    %       nPos                float scalar (number of AF choices)
    %       nMaxPosRep          int scalar (max. num. of succeeding 
    %                               repetitions of the same position)
    %       iTrial              int scalar (trial counter)
    %       posSeq              int array (position sequence)
    %
    %   methods
    %       AFC_MoCS            Constructor
    %
    %   inherited methods
    %       iStim               Returns int scalar (current stimulus index)
    %       nTrial              int scalar (total number of trials)
    %       rand                Returns AFC_NonDynMethod object (randomizes
    %                               posSeq and stimSeq)
    %       pRand               float scalar (prob. of correct rand. resp.)
    %       pos                 Returns int scalar (current position)
    %       update              Returns AFC_Method obj. (counts up iTrial)

    methods
        function obj = AFC_MoCS(nPos_, nStim_, nRep_, nMaxPosRep_)
            %AFC_MoCS: Constructor.
            %
            %   Input:  int scalar (number of AFC positions)
            %           int scalar (num. of max. succ. rep. of same pos.)
            %           int scalar (num. of trials per repetition)
            %           int scalar (num. of repetitions)
            %   Output: AFC_MoCS object
            
            obj = obj@AFC_NonDynMethod(nPos_, nMaxPosRep_, nStim_, nRep_);
            
            %initialize properties posSeq and stimSeq
            dim = [obj.nPos, obj.nStim / obj.nPos, obj.nRep];                             
            obj.posSeq = repmat((1 : dim(1))', [1, dim(2 : 3)]);            %sequence of position indices
            obj.stimSeq = repmat(1 : dim(2), [dim(1), 1, dim(3)]);          %sequence of trial indices
            obj = obj.rand;                                                 %randomize position and trial indices
        end
    end
end

