classdef PTB3_Sequence < PTB3_FrameBase
    %PTB3_Sequence encapsulates a sequence of PTB3 textures, where one 
    %frame contains one texture per screen. PTB3_Sequence is a functionally
    %reduced but mor performant alternative to a PTB3_Frame array. Base 
    %class is PTB3_FrameBase.
    %
    %   properties
    %       screen          1 x n int array (PTB3 screen indices) 
    %       im              1 x n cell array of h x w x (1 or 3) x m 
    %                           uint8 (images, dim: y, x, mono/rgb, frame)
    %       h               n x m int (PTB3 texture handle(s))
    %       rect            n x 1 or n x m Rect (texture rect)
    %
    %   inherited properties
    %       duration_sec    float scalar or 1 x m float (frame dur in sec)
    %
    %   methods
    %       PTB3_Sequence   Constructor
    %       nScreen         Returns int scalar (num. of screens / windows)
    %       nFrame          Returns int scalar (num. of frames)
    %       make            Makes the textures and sets property h
    %       draw            Returns 1 x m float (timestamps)
    %       close           Closes textures
    
    properties (GetAccess = public, SetAccess = private)
        screen
        im
        h
        rect
    end
    
    methods
        function obj = PTB3_Sequence(screen_, im_, duration_sec_, rect_)
            %PTB3_Sequence: Constructor.
            %
            %   Input:  1 x n int scalar (PTB3 screen indices)
            %           (1 x n cell array) of h x w x (1 or 3) x m 
            %               uint8 (images, dim: y, x, mono/rgb, frame)
            %           float scalar or 1 x m float (frame duration in sec)
            %           n x 1 or n x m Rect (texture rect, optional)
            %   Output: PTB3_Sequence object

            if ~Misc.is(screen_, 'int', '~isempty', {'>=', 0})
                error(['First parameter must be a non-empty int array ' ...
                    ' >= 0.']);
            end
            nScreen_ = numel(screen_);
            
            %check second parameter
            if nScreen_ == 1
                if ~Misc.is(im_, 'uint8', {'size', 3, [1, 3]}, ...
                        {'dim', 2 : 4})
                    error(['Second parameter must be a ' ...
                        'h x w x (1 or 3) x n uint8 array.'], nScreen_);
                end
                nFrame_ = size(im_, 4);
            else
                if ~(Misc.isCellOf(im_, 'uint8') && ...
                        numel(im_) == nScreen_ && Misc.is(im_{1}, ...
                        'uint8', {'size', 3, [1, 3]}, {'dim', 2 : 4}))
                    error(['Second parameter must be a 1 x %d cell ' ...
                        'array containing h x w x (1 or 3) x n ' ...
                        'uint8 arrays.'], nScreen_);
                end
                
                dim = size(im_{1});
                for i = 2 : nScreen_
                    dim_ = size(im_{i});
                    if ~isequal(dim(3 : end), dim_(3 : end))
                        error(['Second parameter must be a h x w ', ...
                            repmat('x %d ', [1, numel(dim) - 2]), ... 
                            'uint8 array.'], dim(3 : end));
                    end
                end
                nFrame_ = size(im_{1}, 4);
            end
            
            %check third and fourth parameter
            if ~Misc.is(duration_sec_, 'float', 'pos', ...
                    {'numel', [1, nFrame_]})
                error(['Third parameter must be a positive float ' ...
                    'scalar or 1 x %d float array.'], nFrame_);
            elseif ~(Misc.is(rect_, 'Rect') && ...
                        (numel(rect_) == nScreen_ || ...
                        isequal(size(rect_), [nScreen_, nFrame_])))
                error(['Fourth parameter must be a %d x 1 or %d x %d ' ...
                    'Rect array.'], nScreen_, nScreen_, nFrame_);
            end

            %set property screen
            obj.screen = screen_(:)';
            
            %set property im
            if ~iscell(im_), obj.im = {obj.im};
            else, obj.im = im_;
            end
            
            %set property duration_sec
            if numel(duration_sec_) == nFrame_
                obj.duration_sec = duration_sec_(:)';
            else
                obj.duration_sec = repmat(duration_sec_, [1, nFrame_]);
            end
            
            %set property rect
            if nargin == 4
                if isequal(size(obj.rect), [nScreen_, nFrame_])
                    obj.rect = rect_;
                else
                    obj.rect = repmat(rect_(:), [1, nFrame_]);
                end
            end
        end

        function x = nScreen(obj)
            %nFrame returns the number of screens.
            %
            %   Output: int scalar
            
            x = numel(obj.screen);
        end
        
        function x = nFrame(obj)
            %nFrame returns the number of frames.
            %
            %   Output: int scalar
            
            x = size(obj.im{1}, 4);
        end
        
        function make(obj)
            %make makes the textures via PTB3 and sets property h. Must
            %be called before the texture can be drawn. Works with arrays.

            n = numel(obj);
          	screen_ = [obj.screen];
            winH = PTB3_Window.getHandle(screen_);
            iW = 0;
            for i = 1 : n
                for j = 1 : obj(i).nFrame
                    for k = 1 : obj(i).nScreen
                        obj(i).h(k, j) = Screen('MakeTexture', ...
                            winH(iW + k), obj.im{k}(:, :, :, j), 0, 4);
                    end
                end
                iW = iW + obj(i).nScreen;
            end
        end
        
        function t = draw(obj, tFlip)
            %draw draws the texture. Works with arrays.
            %
            %   Input:  float scalar (flip time of first frame as returned 
            %               by GetSecs, def = 0 = asap)
            %   Output: float array (timestamp, if flip time was defined)
            
            if nargin < 2, tFlip = 0; end                                   %flip asap
            if ~Misc.is(tFlip, 'float', 'scalar', '~isnan')
                error('Input must be a non-NaN float scalar.');
            end
            
            it = 1; 
            t = nan(1, sum([obj.nFrame]));                                  %flip timestamps
            
            for i = 1 : numel(obj)
                winH = PTB3_Window.getHandle(obj(i).screen);                %PTB3 window handles
                hasRect = ~isempty(obj(i).rect);                            %true = property rect was defined for current object
                tBuffer = .5 / PTB3_Window.fps(obj(i).screen(1));           %buffer time to ask for flip: half a frame duration
                
                for j = 1 : obj(i).nFrame
                    if hasRect
                        for k = 1 : obj(i).nScreen
                            Screen('DrawTexture', winH(k), ...
                                obj(i).h(k, j), [], ...
                                obj(i).rect(k, j).xywh);
                        end
                    else
                        for k = 1 : obj(i).nScreen
                            Screen('DrawTexture', winH(k), obj(i).h(k, j));
                        end
                    end

                    %flip
                    t(it) = PTB3_Window.flip(obj(i).screen, tFlip);
                    tFlip = t(it) + obj(i).duration_sec(j) - tBuffer;
                    it = it + 1;
                end
            end
        end        
        
        function close(obj)
            %close closes all PTB3 textures corresponding to property h.
            %Works with arrays.
            
            for i = 1 : numel(obj)
                if ~isempty(obj(i).h), Screen('Close', obj(i).h); end
            end
        end
    end
end