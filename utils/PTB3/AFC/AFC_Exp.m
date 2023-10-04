classdef AFC_Exp < FileBase
    %AFC_Exp executes an AFC experiment. Base class is FileBase.
    %
    %   properties
    %       subject             char array (name of subject)
    %       screen              int array (PTB3 screen indices)
    %       block               AFC_Block array
    %       iBlock              int scalar (index of current block)
    %       key                 AFC_Key object
    %       response            AFC_Response object
    %       adaptation          PTB3_Frame array (adaptation frames)
    %       pause               AFC_Pause object
    %       fps                 double array (display frame rate)
    %       data                AFC_Data array
    %       log                 Struct with fields 
    %                               time    DateTime object
    %                               event   char array
    %       
    %   methods
    %       AFC_Exp             Constructor
    %       run                 Returns AFC_Data object (runs experiment)
    %       test                Returns logical scalar (tests single stim)
    %       info                Returns logical (true = cancel key)
    %       nPos                Returns number of AFC
    
    properties (GetAccess = public, SetAccess = private)
        subject
        screen
        block
        iBlock
        key
        response
        adaptation
        pause
        fps
        data
        log
    end
    
    properties (Transient, Hidden, SetAccess = private)
        fid
    end
    
    methods
        function obj = AFC_Exp(subject_, screen_, block_, key_, ...
                response_, varargin)
            %AFC_Exp: Constructor.
            %
            %   Input:  char array (subject name)
            %           int scalar (PTB3 screen indices)
            %           AFC_Block array
            %           AFC_Key object
            %           AFC_Response object
            %               OPTIONAL key / value pairs
            %           adaptation  PTB3_Frame array
            %           pause       AFC_Pause object
            %   Output: AFC_Exp object

            if ~Misc.is(subject_, 'char', '~isempty')
                error('First parameter must be a non-empty char array.');
            elseif ~Misc.is(screen_, 'int', '~isempty', 'unique', ...
                    {'>=', 0})
                error('Second parameter must be a unique int array >= 0.');
            elseif ~Misc.is(block_, 'AFC_Block', '~isempty')
                error(['Third parameter must be a non-empty ' ...
                    'AFC_Block array.']);
            elseif ~Misc.is(key_, 'AFC_Key', 'scalar')
                error(['Fourth parameter must be a AFC_Key object.');
            elseif ~Misc.is(response_, 'AFC_Response', 'scalar')
                error('Fifth parameter must be an AFC_Response object.'); 
            elseif any([block_.nPos]) ~= key_.nPos
                error(['Inconsistent number of AFC between fourth ' ...
                    'and fifth parameter.']);
            end

            %set mandatory properties
            obj.subject = subject_;
            obj.screen = screen_;
            obj.block = block_;
            obj.key = key_;
            obj.response = response_;
            obj.data = AFC_Data.empty;

            %check and set optional properties
            if mod(numel(varargin), 2) ~= 0
                error('Expected an even number of parameters.');
            end
            validProp = {'adaptation', 'pause'};
            type = {'PTB3_Frame', 'AFC_Pause'};
            param = {'~isempty', 'scalar'};
            arrOrObj = {'array', 'object'};

            for i = 1 : 2 : numel(varargin)
                if ~ischar(varargin{i})
                    error('%s parameter must be a char array.', ...
                        Misc.ordinalNumber(i + 3));
                end

                [valid, j] = ismember(varargin{i}, validProp);
                if ~valid
                    error('Unknown key %s.', varargin{i});
                else
                    if ~Misc.is(varargin{i + 1}, type{j}, param{k})
                        if j < 4, tmp = 'non-empty %s array.'; 
                        else, tmp = '%s object.';
                        end
                        error(['%s parameter must be a ', tmp], ...
                            Misc.ordinalNumber((i + 1) + 3), ...
                            type{j}, arrOrObj{k});
                    end
                end
                obj.(validProp{j}) = varargin{i + 1};
            end
            
            %write first log entry
            obj.appendLog('constructed');
        end
        
        function run(obj)            
            %run runs (starts or continues) the experiment. 
            
            try
                obj.appendLog('run');
                PTB3_Window.open(obj.screen);                               %open windows

                %make textures (and sounds) that do not depend on blocks
                obj.response.make;
                if ~isempty(obj.adaptation), obj.adaptation.make; end
                if ~isempty(obj.pause), obj.pause.make; end

                %set property iBlock / reset property block
                if isempty(obj.iBlock), obj.iBlock = 1;                     %experiment started first time: initialize block index
                else, obj.block = obj.block.reset;                          %reset block if experiment was cancelled
                end

                %adaptation
                cancelled = false;
                if ~isempty(obj.adaptation)
                    obj.appendLog('adaptation');
                    [~, ~, cancelled] = ...
                        obj.adaptation.draw(obj.key.cancel);
                end

                if ~cancelled, obj.pause.update; end                        %sets property t of AFC_pause object to current system time
                
                while ~cancelled && obj.iBlock <= obj.nBlock
                    %pause if necessary
                    if obj.pause.isTimeToSleep
                        obj.appendLog('pause');
                        key_ = obj.pause.run( ...
                            [obj.key.cancel, obj.key.confirm]);
                        cancelled = key_ == obj.key.cancel;
                    end
                    tFlip = 0;
                    
                    b = obj.block(obj.iBlock);
                    hasPreStim = ~isempty(b.preStim);
                    hasPostStim = ~isempty(b.postStim);

                    
                    %show block info and wait for user response
                    obj.appendLog(sprintf('block %d', obj.iBlock));
                    cancelled = obj.info(b.info);
                    if cancelled, break; end
                    
                    while ~cancelled
                        obj.appendLog(sprintf('block %d, trial %d', ...
                            obj.iBlock, b.iTrial));
                        
                        %create stimulus textures
                        b.stim(b.method.pos).makeTexture(obj.method.intensity)
                        
                    end
                    
                    obj.iBlock = obj.iBlock + 1;
                end

                
                
                
                
                
                
                    
%what is "valid" and why continue if not valid?                    
                    valid = false;
                    while ~cancelled && ~valid
                        obj.appendLog(sprintf('block %d, trial %d', ...
                            obj.iBlock, b.iTrial));
%                         t = cell(1, 5);                                     %draw time of {pause, preStim, stim, reaction time, postStim} frames

                        %pause if necessary
                        if obj.pause.isTimeToSleep
                            [cancelled, t{1}] = obj.pause.run;
                        end
                        tFlip = 0;

%%%%%%%%%%%%%MAKE STIMULUS TEXTURES HERE                        
                        
                        if ~cancelled
                            if hasPreStim
                                t{2} = b.preStim.draw(0);
                            end
                            
%DRAW STIMULUS
%GET RESPONSE

                            if hasPostStim
                                t{2} = b.preStim.draw(0);
                            end


                            stim = obj.block(i).stim;
                            pos = obj.block(i).pos;
                            [tStim, tFlip] = stim.draw(tFlip);
                            tResp = obj.response.draw(tFlip);
                            [cancelled, key, rt_sec] = obj.key.waitForKey;   %get and interpret user response
                            
                            if ~cancelled
                                %check validity of stim. pres. and reaction time
                                validFlip = all(abs(diff([tStim tResp]) - ...
                                    stim.duration_sec(pos)) <= 0.5 / obj.fps);      %check if stimulus frames were presented within accepted limits
                                validRT = rt_sec <= obj.response.maxRT_sec;         %check if the user's response was fast enough
                                
                                reportedPos = obj.key.getPos(key);
                                correct = reportedPos == pos;
                                
                                %audio feedback
                                if (obj.block(i).isTraining && ...
                                        obj.response.feedback.training) || ...
                                        (~obj.block(i).isTraining && ...
                                        obj.response.feedback.experiment)
                                    if correct
                                        obj.response.correct.play;
                                    else
                                        obj.response.wrong.play;
                                    end
                                end
                                
    %postStim is prop of AFC_Block
    %                         %post-stimulus
    %                         if ~isempty(trial.post)
    %                             [tPost, tFlip] = obj.postStim.draw(0);          %post stimulus
    %                         end
                            end
                        end
                        
                        %save
                        trialData = AFC_Data(obj.subject, dateTime, cancelled, ....
                            obj.block(i).tag, obj.block(i).isTraining, i, ...
                            obj.block(i).iTrial, obj.block(i).intensity, ...
                            pos, reportedPos, rt_sec, validRT, validFlip, ...
                            [tPause, tPre(1), tStim(1), tResp, tPost(1)]);
                        obj.data = obj.data.append(trialData);
                        trialData.appendToFile(obj.fid);
                        
                        valid = validFlip && validRT;
                        if ~valid
                            obj.block(i) = obj.block(i).rand;                       %re-randomize position (and stimulus, if method of constant stimuli is used)
                        elseif ~obj.block(i).isTraining && ...
                                isa(obj.block(i).method, 'AFC_Quest')
                            obj.block(i) = obj.block(i).update(correct);            %update Quest method
                        else
                            obj.block(i) = obj.block(i).update;                     %update method or training
                        end
                    end
                    
                    
                    
                    %***************************************************************************
                    tFlip = 0;
                    for j = 1 : obj.block(obj.iBlock).nTrial
                        %PUT TEST CODE HERE, DELETE SUBFUNC
                        %[cancelled, tFlip] = obj.test(tFlip);
                        if cancelled, break, end
                    end
                    
                    obj.iBlock = obj.iBlock + 1;
                end
                
                if cancelled, obj.appendLog('cancelled'); end
                
%save obj
            catch ME
                Screen('CloseAll');
                fclose(obj.fid);                                            %close data file
%save obj            
                throw(ME);
            end
        end
    end
    
    methods (Access = private)
%         function [cancelled, tFlip] = test(obj, tFlip)
%             %test tests a given trial at a given position.
%             %
%             %   Input:  float scalar (flip time, default = 0)
%             %   Output: logical scalar (true = user cancelled experiment)
%             %           float scalar (last flip time)
%             
%             if nargin < 2, tFlip = 0; end                                   %i.e., flip asap
%             if ~Misc.is(tFlip, 'float', 'scalar', 'pos')
%                 error('Input must be a positive float scalar.');
%             end
% 
%             i = obj.iBlock; 
%             cancelled = false;
%             valid = false;
% 
%             while ~cancelled && ~valid
%                 tPause = NaN;
%                 tPre = NaN;
%                 tStim = NaN;
%                 tResp = NaN;
%                 tPost = NaN;
%                 
%                 dateTime = DateTime(now);                                   %current day and time
%                 
%                 %check if it's time for a pause
%                 if obj.pause.isTimeToSleep
%                     %pause screen, play sleep
%                     obj.bg.draw;
% %                     obj.text.char = 'Pause';
% %                     tPause = obj.text.draw(0);
%                     obj.pause.update;
%                     obj.pause.sleep.play;
% 
%                     %save data and sleep
%                     save(obj.filename.obj, 'obj');
%                     WaitSecs(obj.pause.interval_sec - ...
%                         (GetSecs - obj.pause.t));
%                     
%                     %wakeup
%                     obj.bg.draw(0);
%                     obj.audio.wakeup.play;
% 
%                     cancelled = obj.info('Press Enter to continue');
%                     tFlip = 0;
%                 end
% 
%                 if ~cancelled
% %prestim is prop of AFC_Block                    
% %                     %pre-stimulus
% %                     if ~isempty(trial.pre)
% %                         [tPre, tFlip] = obj.preStim.draw(tFlip);            %pre stimulus (e.g., fixation)
% %                     end
% 
%                     %stimulus and response texture
%                     stim = obj.block(i).stim;
%                     pos = obj.block(i).pos;
%                     [tStim, tFlip] = stim.draw(tFlip);
%                     tResp = obj.response.draw(tFlip);
%                     [cancelled, key, rt_sec] = obj.key.waitForKey;   %get and interpret user response
% 
%                     if ~cancelled
%                         %check validity of stim. pres. and reaction time
%                         validFlip = all(abs(diff([tStim tResp]) - ...
%                             stim.duration_sec(pos)) <= 0.5 / obj.fps);      %check if stimulus frames were presented within accepted limits
%                         validRT = rt_sec <= obj.response.maxRT_sec;         %check if the user's response was fast enough
%                         
%                         reportedPos = obj.key.getPos(key);
%                         correct = reportedPos == pos;
%                         
%                         %audio feedback
%                         if (obj.block(i).isTraining && ...
%                                 obj.response.feedback.training) || ...
%                                 (~obj.block(i).isTraining && ...
%                                 obj.response.feedback.experiment)
%                             if correct
%                                 obj.response.correct.play;
%                             else
%                                 obj.response.wrong.play;
%                             end
%                         end
% 
% %postStim is prop of AFC_Block                        
% %                         %post-stimulus
% %                         if ~isempty(trial.post)
% %                             [tPost, tFlip] = obj.postStim.draw(0);          %post stimulus
% %                         end
%                     end
%                 end
% 
%                 %save
%                 trialData = AFC_Data(obj.subject, dateTime, cancelled, ....
%                     obj.block(i).tag, obj.block(i).isTraining, i, ...
%                     obj.block(i).iTrial, obj.block(i).intensity, ...
%                     pos, reportedPos, rt_sec, validRT, validFlip, ...
%                     [tPause, tPre(1), tStim(1), tResp, tPost(1)]);
%                 obj.data = obj.data.append(trialData);
%                 trialData.appendToFile(obj.fid);
%          
%                 valid = validFlip && validRT;
%                 if ~valid
%                     obj.block(i) = obj.block(i).rand;                       %re-randomize position (and stimulus, if method of constant stimuli is used)
%                 elseif ~obj.block(i).isTraining && ...
%                         isa(obj.block(i).method, 'AFC_Quest')
%                     obj.block(i) = obj.block(i).update(correct);            %update Quest method
%                 else
%                     obj.block(i) = obj.block(i).update;                     %update method or training
%                 end
%             end
%         end

        function [cancelled, t] = info(obj, visual)
            %info displays a given PTB3_Visual subclass array and waits for
            %key input. If the cancel key was pressed, true is returned, 
            %otherwise false.
            %
            %   Input:  PTB3_Visual subclass array
            %   Output: logical scalar (true = cancel key was pressed)
            %           float scalar (time of key hit)

            if ~Misc.is(visual, {'isa', 'PTB3_Visual'}, '~isempty')
                error(['Input must be a non-empty PTB3_Visual ' ...
                    'subclass array.']);
            end
            
            visual.draw(0);
            [key, t] = Misc.waitForKey([obj.key.cancel, obj.key.confirm]);
            cancelled = obj.key.isCancel(key);
        end
        
        function x = nPos(obj)
            %nPos returns the number of stimulus positions.
            %
            %   Output: Int scalar
            
            x = obj.key.nPos;
        end
        
        function appendLog(obj, event)
            %appendLog appends an element to property log.
            
            if Misc.is(event, 'char', '~isempty')
                error('Input must be a non-empty char array.');
            end
            
            if isempty(obj.log), i = 1; 
            else, i = numel(obj.log) + 1;
            end
            obj.log(i).time = DateTime(now);
            obj.log(i).event = event;
        end
    end
end

