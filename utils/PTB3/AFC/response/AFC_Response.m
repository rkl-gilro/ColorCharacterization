classdef AFC_Response
    %AFC_Response encapsulates properties and methods for prompting the
    %user to respond to a stimulus and to interpret this response.
    %
    %   properties
    %       visual          PTB3_Visual subclass array
    %       feedback        AFC_Feedback object
    %       maxRT_sec       float scalar (max. reaction time in sec)
    %
    %   methods
    %       AFC_Response    Construtor
    %       make            Calls visual.make
    
    properties (GetAccess = public, SetAccess = private)
        visual
        feedback
        maxRT_sec
    end
    
    methods
        function obj = AFC_Response(visual_, feedback_, maxRT_sec_)
            %AFC_Response: Constructor. 
            %
            %   Input:  PTB3_Visual array
            %           AFC_Key object
            %           AFC_Feedback object
            %           float scalar (max. reaction time)
            %   Outut:  AFC_Response object
            
            if ~isa(visual_, 'PTB3_Visual')
                error('First parameter must be a PTB3_Frame array.');
            elseif ~Misc.is(feedback_, 'AFC_Feedback', 'scalar')
                error('Third parameter must be a AFC_Feedback object.');
            elseif ~Misc.is(maxRT_sec_, 'float', 'pos', 'scalar')
                error('Fourth parameter must be a positive scalar.');
            end
            
            obj.visual = visual_;
            obj.feedback = feedback_;
            obj.maxRT_sec = maxRT_sec_;
        end
        
        function make(obj)
            %make calls make of property visual.
            
            obj.visual.make;
        end
    end
end