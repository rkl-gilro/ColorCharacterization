classdef AFC_Time
    %AFC_Time encapsulates times and durations of the segments of a trial 
    %executed in AFC_Exp.test. Also base class of AFC_StartTime.
    %
    %   properties
    %       pause           1 x 3 float ([pause, rt, flip])
    %       preStim         float array (pre-stimulus frames)
    %       stim            float array (stimulus frames)
    %       response        1 x 3 float ([rt, sound, flip])
    %       postStim        float array (post-stimulus frames)
    %
    %   methods
    %       AFC_Time        Constructor
    
    properties (GetAccess = public, SetAccess = private)
        pause
        preStim
        stim
        response
        postStim
    end
    
    methods
        function obj = AFC_Time(pause_, preStim_, stim_, response_, ...
                postStim_)
            %AFC_Time: Constructor.
            % 
            %   Input:  1 x 3 float ([pause, rt, flip])
            %           float array (pre-stimulus frames)
            %           float array (stimulus frames)
            %           1 x 3 float ([rt, sound, flip])
            %           float array (post-stimulus frames)
            %   Output: AFC_Time object
            
            if ~Misc.is(pause_, 'float', {'>=', 0}, {'numel', 3})
                error('First parameter must be a 1 x 3 float >= 0.');
            elseif ~Misc.is(preStim_, 'float', {'>=', 0}) 
                error('Second parameter must be a float array >= 0.');
            elseif ~Misc.is(stim_, 'float', {'>=', 0}) 
                error('Third parameter must be a float array >= 0.');
            elseif ~Misc.is(response_, 'float', {'>=', 0}, {'numel', 3})
                error('Fourth parameter must be a 1 x 3 float >= 0.');
            elseif ~Misc.is(postStim_, 'float', {'>=', 0}) 
                error('Fifth parameter must be a float array >= 0.');
            end
            
            obj.pause = pause_(:)';
            obj.preStim = preStim_;
            obj.stim = stim_;
            obj.response = response_(:)';
            obj.postStim = postStim_;
        end
    end
end

