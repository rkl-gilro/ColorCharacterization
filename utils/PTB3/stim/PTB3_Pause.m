classdef PTB3_Pause < handle
    %PTB3_Pause encapsulates the properties and methods of a pause during 
    %an epxeriment. Base class is handle.
    %
    %   properties
    %       visual              PTB3_Frame array
    %       audio               PTB3_Audio object or 1 x 2 array
    %       key                 struct with fields (key code)
    %                               cancel      uint8 scalar or []
    %                               continue    uint8 scalar or []
    %       duration_sec        float scalar (pause duration in sec)
    %       interval_sec        float scalar (pause interval in sec)
    %       t                   float scalar (system time of pause end)
    %
    %   methods
    %       PTB3_Pause          Constructor
    %       make                Calls make for properties visual and audio
    %       run                 Returns logical scalar (true = cancelled)
    %       update              Sets property t to current system time
    %       isTimeToSleep       Returns logical
    %
    %   static methods
    %       defaultAudio        Returns 1 x 2 PTB3_Audio ([sleep, wake up])

    
    properties (GetAccess = public, SetAccess = private)
        visual
        audio
        key
        duration_sec
        interval_sec
        t
    end
    
    methods
        function obj = PTB3_Pause(visual_, varargin)
            %PTB3_Pause: Constructor.
            %
            %   Input:  1 x n PTB3_Frame
            %              KEY / VALUE PAIRS, OPTIONAL
            %           audio       1 x 2 PTB3_Audio ([sleep, wake up])
            %           cancel      uint8 scalar or [] (key code, def = [])
            %           continue    uint8 scalar or [] (key code, def = [])
            %           interval    float scalar (pause interval in sec)
            %   Output: PTB3_Pause object
        
            if ~Misc.is(visual_, 'PTB3_Frame', 'multiple')
                error(['First parameter must be a PTB3_Frame array ' ...
                    'with multiple elements.']);
            end
            
            duration_sec = [frame_.duration_sec];
            isInf = duration_sec_ == inf;                                   %true = frame has infinite duration (= prompt screen)
            if any(isInf(1 : numel(isInf) - 1))
                error(['First parameter, property duration_sec, can ' ...
                    'be inf for the last element only.']);
            end
            
            %set properties visual and duration_sec
            obj.visual = visual_;            
            obj.duration_sec = sum(duration_sec(~isInf));                   %sum up frame duration (without prompt screen, if it exists)
            
            %set optional parameters
            for i = 1 : numel(varargin)
                if isempty(obj.audio) && ... 
                        Misc.is(varargin{i}, 'PTB3_Audio', {'numel', 2})
                    obj.audio = varargin{i};
                elseif isempty(obj.key) && ...
                        Misc.is(varargin{i}, 'uint8', {'numel', [1, 2]})
                    obj.key = varargin{i};
                elseif isempty(obj.interval_sec) && ...
                        Misc.is(varargin{i}, 'float', 'scalar', 'pos')
                    obj.interval_sec = varargin{i};
                else
                    error('%s parameter is invalid.', ...
                        Misc.ordinalNumber(i + 1));
                end
            end
            
            %optional parameters sanity checks
            if numel(obj.key) ~= numel(unique(obj.key))
                error('Key parameter must be unique.');
            elseif ~isempty(obj.interval_sec) && ...
                    obj.interval_sec <= obj.duration_sec
                error('Pause interval must be > pause duration.');
            end            
        end
        
        function make(obj)
            %make calls make of properties visual and audio.
            
            for field = Misc.flat(fieldnames(obj.visual))'
                for j = 1 : numel(obj.visual.(field{1}))
                    if ismethod(obj.(field{1})(j), 'make')
                        obj.visual.(field{1})(j).make;
                    end
                end
                obj.audio.(field{1}).make;
            end
        end
        
        function [cancelled, tFlip] = run(obj)
            %run runs the pause.
            %
            %   Output: logical scalar (true = user pressed cancel key)
            %           float array (flip times; when cancelled or when 
            %               using a prompt screen, the last time stamp is 
            %               from the key press)           

            if ~isempty(obj.audio), obj.audio(1).play; end                  %play audio if exists

            %draw stimulus
            cancelled = false;
            if obj.visual(end).duration_sec == inf                          %last frame has infinite duration = prompt screen
                [tFlip, tNext, cancelled] = obj.visual.draw(0, obj.key(1)); %draw all frames and flip screen
                
                %prompt screen: wait for user key
                if cancelled
                    tFlip(end + 1) = tNext;                                 %tNext is the time when the cancel key was pressed
                else
                    if numel(obj.audio) == 2, obj.audio(2).play; end        %play wake up sound after prompt screen was flipped
                    if numel(obj.key) == 2
                        [key_, tFlip(end + 1)] = Misc.waitForKey(obj.key);  %continue key defined; only cancel and continue key can end frame  
                    else
                        [key_, tFlip(end + 1)] = Misc.waitForKey;           %no continue key defined: all keys can end frame
                    end
                    cancelled = key_ == obj.key(1);
                end
            else                                                            %no prompt screen, pause ends automatically
                if isempty(obj.key)
                    [tFlip, tNext] = obj.visual.draw(0);                    %no cancel key defined = drawing cannot be cancelled
                else
                    [tFlip, tNext, cancelled] = ...
                        obj.visual.draw(0, obj.key(1));
                end
                tFlip(end + 1) = tNext;
                if numel(obj.audio) == 2, obj.audio(2).play; end            %play wake up sound after last frame was flipped
            end
            
            if ~cancelled, obj.update(tFlip(end)); end                      %update property t
        end
        
        function update(obj, t_)
            %update sets property t (system time of pause end).
            %
            %   Input:  float scalar (def = current system time)
            
            if nargin < 2, t_ = GetSecs; end
            if isempty(obj.t), t0 = 0;
            else, t0 = obj.t;
            end
            if ~Misc.is(t_, 'float', {'>', t0})
                error('Input must be a float scalar > %f.', t0);
            end
                
            obj.t = t_;
        end
        
        function x = isTimeToSleep(obj)
            %isTimeToSleep returns true if at least interval_sec has been 
            %passed since t.
            %
            %   Output: logical scalar
           
            x = GetSecs - obj.t >= obj.interval_sec;
        end
    end
    
    methods(Static)
        function x = defaultAudio(iDev, sampleRate)
            %defaultAudio returns a 1 x 2 PTB3_Audio array that contains 
            %default sounds for the auditory sleep and wake up signal.
            %
            %   Input:  int scalar (PTB3 audio device index, def = 6)
            %           float scalar (sample rate in Hz, def = 48000)
            %   Output: 1 x 2 PTB3_Audio ([sleep, wake up])

            if nargin < 2, sampleRate = 48000; end
            if nargin < 1, iDev = 6; end
            if ~Misc.is(sampleRate, 'float', 'scalar', 'pos')
                error('Input must be a positive float scalar.');
            end
            
            amp = .7;
            p = linspace(0, 2 * pi, .1 * sampleRate);
            p = p(1 : end - 1);
            
            x = [PTB3_Audio(iDev, repmat(amp * [sin(60 * p), ...
                sin(50 * p), sin(40 * p), sin(30 * p)], [2, 1])), ...       %sleep: descending melody
                PTB3_Audio(iDev, repmat(amp * [sin(30 * p), ...
                sin(40 * p), sin(50 * p), sin(60 * p)], [2, 1]))];          %wake up: ascending melody
        end
    end
end