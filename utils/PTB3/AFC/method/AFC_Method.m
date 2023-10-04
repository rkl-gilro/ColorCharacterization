classdef (Abstract) AFC_Method < handle
    %AFC_Method is an abstract class that encapsulates properties and 
    %methods of pschophysic experimental methods. Base class for 
    %AFC_NonDynMethod and AFC_MoCS. Base class is handle.
    %
    %   properties
    %       nPos                float scalar (number of AF choices)
    %       nMaxPosRep          int scalar (max. num. of succeeding 
    %                               repetitions of the same position)
    %       iTrial              int scalar (trial counter)
    %       posSeq              int array (position sequence)
    %
    %   methods 
    %       AFC_Method          Constructor
    %       pRand               float scalar (prob. of correct rand. resp.)
    %       pos                 Returns int scalar (current position)
    %       reset               Returns AFC_Method obj. (resets iTrial and
    %                               calls rand)
    %       update              Returns AFC_Method obj. (counts up iTrial)
    %       rand                Returns AFC Method obj. (randomizes posSeq)
    
    properties (GetAccess = public, SetAccess = private)
        nPos
        nMaxPosRep
        iTrial
        posSeq
    end

    methods
        function obj = AFC_Method(nPos_, nMaxPosRep_)
            %AFC_Method: Constructor.
            %
            %   Input:  int scalar (number of AFC positions)
            %           int scalar (num. of trials per repetition)
            %           int scalar (num. of repetitions)
            %           int scalar (num. of max. succ. rep. of same pos.)
            %   Output: AFC_Method object

            if ~Misc.is(nPos_, 'int', 'scalar', {'>', 1})
                error('First parameter must be an int scalar > 1.');
            elseif ~Misc.is(nMaxPosRep_, 'pos', 'int')
                error('Second parameter must be a positive int scalar.');
            end
 
            obj.nPos = nPos_;
            obj.nMaxPosRep = nMaxPosRep_;
            obj.iTrial = 1;
        end

        function x = pRand(obj)
            %pRand returns the probability of a correct random response.
            %
            %   Output: float scalar
            
            x = 1 / obj.nPos;
        end
        
        function x = pos(obj)
            %trial returns the position to test next.
            %
            %   Output: int scalar
            
            obj.errIfFinished;
            x = obj.posSeq(obj.iTrial);
        end
        
        function reset(obj)
            %reset resets iTrial and calls update.
            
            obj.iTrial = 1;
            obj.rand;
        end
        
        function update(obj)
            %update counts up property iTrial.
            
            obj.errIfFinished;
            obj.iTrial = obj.iTrial + 1;
        end
        
        function isort = rand(obj)
            %rand randomizes the order of posSeq from iTrial onwards, so
            %that no more than nMaxPosRep succeeding repetitions of a 
            %position occur.
            %
            %   Output: AFC_Method object
            %           int array (randomization index)
            
            obj.errIfFinished;

            valid = false;
            offset = obj.iTrial;                                            %offset is the index from which on posSeq is randomized
            n = numel(obj.posSeq);
            isort = 1 : n;
            
            while ~valid
                idx = offset : n;                                           %indices to randomize
                irand = idx(randperm(numel(idx)));                          %randomized indices of idx
                obj.posSeq(idx) = obj.posSeq(irand);
                isort(idx) = isort(irand);
                
                freq = 1;                                                   %counter for repetitions of positions
                i0 = idx(1) - obj.nMaxPosRep;
                if i0 < 2, i0 = 2; end
                for i = i0 : idx(end)
                    if obj.posSeq(i) == obj.posSeq(i - 1)
                        freq = freq + 1;                                    %equal suceeding position found: count up
                    else
                        freq = 1;                                           %suceeding poritions differ: reset counter
                    end
                    if freq > obj.nMaxPosRep                                %too many repetitions of one position found
                        if numel(unique(obj.posSeq(idx))) == 1              %if there is only equal positions left...
                            offset = 1;                                     %...then randomize the whole sequence again
                        else
                            offset = i - obj.nMaxPosRep;                    %otherwise set offset to the index where the repetition started
                        end
                        break
                    end
                end
                valid = freq <= obj.nMaxPosRep;                             %number of repetitions within accepted limits
            end
        end
    end
    
    methods (Access = protected)
        function errIfFinished(obj)
            %errIfFinished throws an error if index iTrial is out of range
            %of property posSeq.
            
            if obj.iTrial > numel(obj.posSeq)
                error('Maximal number of trials reached.');
            end
        end
    end
end
