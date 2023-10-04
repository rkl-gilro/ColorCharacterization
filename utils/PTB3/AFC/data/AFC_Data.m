classdef AFC_Data
    %AFC_Data is a container for the data gained by an trial in class 
    %AFC_Exp.
    %
    %   properties
    %       subject         char array (subject name)
    %       dateTime        DateTime object
    %       aborted         logical (true = trial was aborted)
    %       training        logical (true = training trial)
    %       tag             char array (stimulus category)
    %       block           int scalar (block index)
    %       trail           int scalar (trial index)
    %       intensity       float scalar (stimulus intensity)
    %       pos             int scalar (idx of stimulus position)
    %       reportedPos     int scalar (idx of reported stimulus position)
    %       correct         logical (if true, reprotedPos == pos)
    %       rt              float scalar (reaction time)
    %       flip            AFC_Flip object
    %       validRT         logical scalar (if true, rt was within limits)
    %       validFlip       logical scalar (if true, stim flips were ok)
    %
    %   methods
    %       AFC_Data        Constructor
    %       isCorrect       Return logical (true if response is correct)
    %       appendToFile    Appends data to given text file
    
    properties (GetAccess = public, SetAccess = private)
        subject
        dateTime
        aborted
        training
        tag
        block
        trial
        intensity
        pos
        reportedPos
        correct
        rt
        flip
        validRT
        validFlip
    end
    
    methods
        function obj = AFC_Data(subject_, dateTime_, aborted_, ...
                training_, tag_, block_, trial_, intensity_, pos_, ...
                reportedPos_, rt_, flip_, validRT_, validFlip_)
            %AFC_Data: Constructor.
            % 
            %   Input:  char array (subject name)
            %           DateTime object
            %           logical (true = aborted)
            %           logical (true = training)
            %           char array (block tag)
            %           int scalar (block index)
            %           int scalar (trial index)
            %           float scalar (intensity)
            %           int scalar (position index)
            %           int scalar (reported position index)
            %           float scalar (reaction time)
            %           AFC_Flip object
            %           logical (true = reaction time within limits)
            %           logical (true = stimulus flip times within limits)
            %   Output: AFC_Data object
            
            if ~Misc.is(subject_, 'char', '~isempty')
                error('First parameter must be a non-empty char array.');
            elseif ~Misc.is(dateTime_, 'DateTime', 'scalar')
                error('Second parameter must be a DateTime object.');
            elseif ~Misc.is(aborted_, 'logical', 'scalar')
                error('Third parameter must be a logical scalar.');
            elseif ~Misc.is(training_, 'logical', 'scalar')
                error('Fourth parameter must be a logical scalar.');
            elseif ~Misc.is(tag_, 'char', '~isempty')
                error('Fifth parameter must be a non-empty char array.');
            elseif ~Misc.is(block_, 'pos', 'int', 'scalar')
                error('Sixth parameter must be a positive int scalar.');
            elseif ~Misc.is(trial_, 'pos', 'int', 'scalar')
                error('Seventh parameter must be a positive int scalar.');
            elseif ~Misc.is(intensity_, 'float', 'scalar')
                error('Eigth parameter must be a float scalar.');
            elseif ~Misc.is(pos_, 'pos', 'int', 'scalar')
                error('Nineth parameter must be a positive int scalar.');
            elseif ~Misc.is(reportedPos_, 'pos', 'int', 'scalar')
                error('Tenth parameter must be a positive int scalar.');
            elseif ~Misc.is(rt_, 'pos', 'scalar', {'>=', 0})
                error('Eleventh parameter must be a scalar >= 0.');
            elseif ~Misc.is(flip, 'AFC_Flip', 'scalar')
                error('Twelveth parameter must be an AFC_Flip object.');
            elseif ~Misc.is(validRT_, 'logical', 'scalar')
                error('Thirteenth parameter must be a logical scalar.');
            elseif ~Misc.is(validFlip_, 'logical', 'scalar')
                error('Fourteenth parameter must be a logical scalar.');
            end
            
            obj.subject = subject_;
            obj.dateTime = dateTime_;
            obj.aborted = aborted_;
            obj.training = training_;
            obj.tag = tag_;
            obj.block = block_;
            obj.trial = trial_;
            obj.intensity = intensity_;
            obj.pos = pos_;
            obj.reportedPos = reportedPos_;
            obj.correct = obj.reportedPos == obj.pos;
            obj.rt = rt_;
            obj.flip = flip_;
            obj.validRT = validRT_;
            obj.validFlip = validFlip_;
        end
    end
end

