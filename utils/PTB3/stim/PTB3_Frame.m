classdef PTB3_Frame < PTB3_FrameBase
    %PTB3_Frame encapsulates an PTB3_Visual array and the duration of
    %presentation. Base class is PTB3_FrameBase.
    %
    %   properties
    %       visual          PTB3_Visual array
    %       uqScreen        int array (unique screen indices of visual)
    %
    %   inherited properties
    %       duration_sec    float scalar (duration in sec)
    %
    %   methods
    %       PTB3_Frame      Constructor
    %       draw            Draws the frame(s)
    %       make            Makes all textures contained in prop visual
    %       close           Closes all textures contained in prop visual
    
    properties (GetAccess = public, SetAccess = private)
        visual
        uqScreen
    end
    
    methods
        function obj = PTB3_Frame(visual_, duration_sec_)
            %PTB3_Frame: Constructor.
            %
            %   Input:  PTB3_Visual array
            %           float scalar (duration in sec, def = 1 / fps)
            %   Output: PTB3_Frame object

            if ~Misc.is(visual_, {'isa', 'PTB3_Visual'}, '~isempty')
                error('First parameter must be a PTB3_Visual array.');
            elseif ~Misc.is(duration_sec_, 'float', 'scalar', {'>=', 0})
                error('Input must be a float scalar >= 0.');
            end

            %set properties
            obj.visual = visual_;
            obj.uqScreen = unique([visual_.screen]);                        %unique PTB3 screen indices
            obj.duration_sec = duration_sec_;
        end
        
        function [tFlip, tNext, cancelled] = draw(obj, tNext, cancelKey)
            %draw draws and flips all textures and / or text stored in 
            %property visual. Works with arrays (i.e., multiple frames are 
            %displayed).
            %
            %   Input:  float scalar (flip time as returned by GetSecs, 
            %               def = 0 = asap)
            %           uint8 scalar (ASCII code of cancel key, stops draw)
            %   Output: float array (timestamp(s) of frame(s))
            %           float scalar (end time of (last) frame)
            %           logical scalar (true = cancelled)
            
            if nargin < 2, tNext = 0; end
            if ~Misc.is(tNext, 'float', 'scalar', '~isnan')
                error('First parameter must be a non-NaN float scalar.');
            elseif nargin > 2 && ...
                    ~Misc.is(cancelKey, 'uint8', 'scalar', 'pos')
                error('Second parameter must be a positive uint8 scalar.');
            end
           
            nObj = numel(obj);
            tBuffer = .5 / PTB3_Window.fps(obj(1).visual(1).screen);        %buffer time to read keyboard / to trigger next frame: half a frame duration
            tFlip = nan(1, nObj);
            hasCancel = nargin == 3;
            if hasCancel, iCancel = double(cancelKey) + 1; end              %index of cancel key in keycode returned by KbCheck
            cancelled = false;
            
            for i = 1 : nObj
                %check if cancelKey was pressed
                if hasCancel
                    while tNext - GetSecs > tBuffer
                        [hit, ~, keyCode] = KbCheck;
                        if hit && keyCode(iCancel)
                            cancelled = true;
                            return;
                        end
                    end
                end
                
                %draw and flip
                obj(i).visual.draw;
                tFlip(i) = PTB3_Window.flip(obj(i).uqScreen, tNext);
                tNext = tFlip(i) + obj(i).duration_sec - tBuffer;
            end
        end
        
        function make(obj)
            %make makes all PTB3 textures contained in property visual.
            %Works with arrays.

            for i = 1 : numel(obj), obj(i).visual.make; end
        end
        
        function close(obj)
            %close closes all PTB3 textures contained in property visual.
            %Works with arrays.
            
            for i = 1 : numel(obj), obj(i).visual.close; end
        end
    end
end