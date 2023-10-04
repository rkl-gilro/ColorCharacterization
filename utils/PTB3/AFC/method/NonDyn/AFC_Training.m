classdef AFC_Training < AFC_NonDynMethod
    %AFC_Training encapsulates properties and methods corresponding to a
    %training phase in an AFC experiment. Base class is AFC_NonDynMethod.
    %
    %   properties
    %       info                PTB3_Visual subclass array
    %
    %   inherited properties
    %       nTrialPerRep        int scalar (num. of trials per repetition)
    %       nRep                int scalar (num. of repetition)
    %       stimSeq             int array (sequence of stimulus indices)
    %       nPos                float scalar (number of AF choices)
    %       nMaxPosRep          int scalar (max. num. of succeeding 
    %                               repetitions of the same position)
    %       iTrial              int scalar (trial counter)
    %       posSeq              int array (position sequence)
    %
    %   methods
    %       AFC_Training        Constructor
    %
    %   inherited methods
    %       iStim               Returns int scalar (current stimulus index)
    %       nTrial              int scalar (total number of trials)
    %       rand                Returns AFC_NonDynMethod object (randomizes
    %                               posSeq and stimSeq)
    %       pRand               float scalar (prob. of correct rand. resp.)
    %       pos                 Returns int scalar (current position)
    %       update              Returns AFC_Method obj. (counts up iTrial)

    properties (GetAccess = public, SetAccess = private)
        info
    end
    
    methods
        function obj = AFC_Training(nPos_, nTrialPerRep_, nRep_, ...
                nMaxPosRep_, info_)
            %AFC_Training: Constructor.
            %
            %   Input:  int scalar (number of AFC positions)
            %           int scalar (num. of max. succ. rep. of same pos.)
            %           int scalar (num. of trials per repetition)
            %           int scalar (num. of repetitions)
            %           PTB3_Texture array (info)
            %   Output: AFC_Training object
            
            obj = obj@AFC_NonDynMethod(nPos_, nMaxPosRep_, ...
                nTrialPerRep_, nRep_);
            
            if ~Misc.is(info_, {'isa', 'PTB3_Visual'}, '~isempty')
                error(['Fifth parameter must be a non-empty ' ...
                    'PTB3_Visual subclass array.']);
           end

            %set property info
            obj.info = info_;
            
            %initialize properties posSeq and stimSeq
            obj.posSeq = repmat(1 : obj.nPos, [1, obj.nTrial / obj.nPos]);  %sequence of position indices
            obj.stimSeq = repmat(obj.nTrialPerRep : -1 : 1, ...
                [obj.nRep, 1]);                                             %sequence of trial indices. Assumes that trial intensities will be sorted in ascending order.
            obj = obj.rand;                                                 %randomize posSeq
        end
    end
end

