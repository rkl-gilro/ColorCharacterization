classdef PTB3_Texture < PTB3_Visual
    %PTB3_Texture encapsulates methods and properties of a PTB3 texture.
    %Base class is PTB3_Visual.
    %
    %   properties
    %       h                       PTB3 texture handle
    %       im                      h x w x 1 or h x w x 3 numeric (image)
    %       rect                    Rect object (destination of texture)
    %
    %   inherited properties
    %       screen                  int scalar (PTB3 screen index)
    %
    %   methods
    %       PTB3_Texture            Constructor
    %       make                    Makes the texture and sets property h
    %       draw                    Returns float scalar (timestamp)
    %       close                   Closes texture(s)
      
    properties (GetAccess = public, SetAccess = private)
        h
        im
        rect
    end
    
    methods
        function obj = PTB3_Texture(screen_, im_, rect_)
            %PTB3_Texture: Constructor.
            %
            %   Input:  int scalar (PTB3 screen index)
            %           h x w x (1 or 3) uint8 array (input image)
            %           Rect object (texture rect, optional)
            %   Output: PTB3_Texture object
            
            obj = obj@PTB3_Visual(screen_);

            if ~Misc.is(im_, 'uint8', {'dim', [2, 3]}, {'size', 3, [1, 3]})
                error(['Second parameter must be a h x w or h x w x 3 ' ...
                    'uint8 array.']);                                       %2-dim: mono image, 3-dim: RGB image, 4-dim: multiple images (mono or RGB)
            elseif nargin == 3 && ~Misc.is(rect_, 'Rect', 'scalar')
                error('Third parameter must be a Rect object.');
            end

            obj.im = im_;
            if nargin == 3, obj.rect = rect_; end
        end

        function make(obj)
            %make makes the texture via PTB3 and sets property h. make must
            %be called before the texture can be drawn. Works with arrays.

            if obj.isHetero
                obj.make@PTB3_Visual; 
                return;
            end
            
            n = numel(obj);
            if n == 1
                obj.h = Screen(PTB3_Window.getHandle(obj.screen), ...
                    'MakeTexture', obj.im);
            else
                winH = PTB3_Window.getHandle([obj.screen]);
                for i = 1 : n
                    obj(i).h = Screen(winH(i), 'MakeTexture', obj(i).im);
                end
            end
        end
        
        function t = draw(obj, tFlip)
            %draw draws the texture. Works with arrays.
            %
            %   Input:  float scalar (flip time of first frame as returned 
            %               by GetSecs, 0 = asap, optional)
            %   Output: float array (timestamp, if flip time was defined)
            
            if obj.isHetero
                if nargin == 2, obj.drawHetero(tFlip); 
                else, obj.drawHetero; 
                end
                return;
            elseif nargin == 2 && ...
                    ~Misc.is(tFlip, 'float', 'scalar', '~isnan')
                error('Input must be a non-NaN float scalar.');
            end
            
            n = numel(obj);
            winH = PTB3_Window.getHandle([obj.screen]);
            if ~isempty(obj.rect)
                for i = 1 : n
                    Screen('DrawTexture', winH(i), obj(i).h, [], ...
                        obj(i).rect.xywh);
                end
            else
                for i = 1 : n
                    Screen('DrawTexture', winH(i), obj(i).h);
                end
            end
            
            if nargin == 2
                t = PTB3_Window.flip([obj.screen], tFlip);
            elseif nargout > 0
                error(['Timestamp cannot be returned because screen ' ...
                    'was not flipped.']);                                   %flip time must be defined to flip texture and return flip time
            end
         end
         
         function close(obj)
            %close closes texture(s). Works with arrays.
            
            if obj.isHetero
                obj.close@PTB3_Visual;
                return;
            end
            
            for i = 1 : numel(obj)
                if ~isempty(obj(i).h), Screen('Close', obj(i).h); end
            end
        end
    end
end