classdef AFC_StartTime < AFC_Time
    %AFC_StartTime encapsulates the start times for all segments of a trial 
    %executed in AFC_Exp.test. Base class is AFC_Time.
    %
    %   inherited properties
    %       pause               1 x 3 float ([pause, rt, flip])
    %       preStim             float array (pre-stimulus frames)
    %       stim                float array (stimulus frames)
    %       response            1 x 3 float ([rt, sound, flip])
    %       postStim            float array (post-stimulus frames)
    %
    %   methods
    %       AFC_StartTime       Constructor
    %       duration            Returns AFC_Time array (duration times 
    %                               corresp. to given AFC_StartTime array)
    
    methods
        function obj = AFC_StartTime(pause_, preStim_, stim_, ...
                response_, postStim_)
            %AFC_StartTime: Constructor.
            % 
            %   Input:  1 x 3 float ([pause, rt, flip])
            %           float array (pre-stimulus frames)
            %           float array (stimulus frames)
            %           1 x 3 float ([rt, sound, flip])
            %           float array (post-stimulus frames)
            %   Output: AFC_StartTime object
            
            obj = obj@AFC_Time(pause_, preStim_, stim_, ...
                response_, postStim_);
            
            if any(diff([obj.pause, obj.preStim, obj.stim, ...
                    obj.response, obj.postStim]) < 0)
                error('Values must be monotonically increasing.');
            end            
        end
    end
        
    methods (Static)
        function y = duration(x, tEnd_)
            %duration computes the duration of segments in a given 
            %AFC_StartTime array and returns them as AFC_Time array.
            %
            %   Input:  1 x n AFC_StartTime array
            %           float scalar (end of last postStim frame; opt.)
            %   Output: AFC_Time array
            
            if nargin < 2, tEnd_ = NaN; end
            if ~isa(x, 'AFC_StartTime') 
                error('First parameter must be a AFC_StartTime array.');
            elseif isfloat(tEnd_) && numel(tEnd_) == 1
                error('Second parameter must be a float scalar.');
            end
            
            y = AFC_Time.empty();
            n = numel(x);
            for i = 1 : n
                if i < n
                    tEnd = x(n).pause(1);
                else
                    tEnd = tEnd_;                    
                end
                
                y(i) = AFC_Time( ...
                    diff([x.pause, x.preStim(1)]), ...
                    diff([x.preStim, x.stim(1)]), ...
                    diff([x.stim, x.response(1)]), ...
                    diff([x.response, x.postStim(1)]), ...
                    diff([x.postStim tEnd]));
            end
        end
    end
end

