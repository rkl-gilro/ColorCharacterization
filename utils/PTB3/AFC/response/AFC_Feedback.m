classdef AFC_Feedback
    %AFC_feedback encapsulates the feedback options for class AFC.
    %
    %   properties
    %       training        logical scalar
    %       experiment      logical scalar
    %       correct         audioplayer object (positive feedback)
    %       wrong           audioplayer object (negative feedback)
    %
    %   methods
    %       AFC_Methods     Constructor
    %       play            Plays the audio feedback
    
    properties (GetAccess = public, SetAccess = private)
        training 
        experiment
        correct
        wrong
    end
    
    methods
        function obj = AFC_Feedback(training_, experiment_, correct_, ...
                wrong_)
            %AFC_Feedback: Constructor.
            %
            %   Input:  logical scalar (true = feedback in training)
            %           logical scalar (true = feedback for experiment)
            %           audioplayer object (positive feedback)
            %           audioplayer object (negative feedback)
            %   Output: AFC_Feedback output
            
            if nargin < 3
                fps = 44100;
                amp = .7;
                correct_ = audioplayer(amp * sin(100 * ...
                    linspace(0, 2 * pi, .15 * fps)), fps);
                wrong_ = audioplayer(amp * sin(50 * ...
                    linspace(0, 2 * pi, .15 * fps)), fps);
            end
            if nargin < 2, experiment_ = false; end
            if nargin < 2, training_ = true; end
            
            if ~Misc.is(training_, 'logical', 'scalar')
                error('First parameter must be a logical scalar.');
            elseif ~Misc.is(experiment_, 'logical', 'scalar')
                error('Second parameter must be a logical scalar.');
            elseif ~Misc.is(correct_, 'audioplayer', 'scalar')
                error('Third parameter must be a audioplayer object.');
            elseif ~Misc.is(wrong_, 'audioplayer', 'scalar')
                error('Fourth parameter must be a audioplayer object.');
            end
            
            obj.training = training_;
            obj.experiment = experiment_;
            obj.correct = correct_;
            obj.wrong = wrong_;
        end
        
        function play(obj, isCorrect, isTraining)
            %play plays the auditive feedback, if active.
            %
            %   Input:  logical scalar (true = response was correct)
            %           logical scalar (true = training)
            
            if ~Misc.is(isCorrect, 'logical', 'scalar')
                error('First parameter msut be a logical scalar.');
            elseif ~Misc.is(isTraining, 'logical', 'scalar')
                error('Second parameter msut be a logical scalar.');
            end
            
            if ~isempty(obj) && ((isTraining && obj.training) || ...
                    (~isTraining && ~obj.training))
                if isCorrect
                    obj.correct.play;
                else
                    obj.wrong.play;
                end
            end
        end
    end
end

        