classdef PTB3_Text < PTB3_Visual
    %PTB3_Text encapsulates properties and methods of text in PTB3.
    %Base class is PTB3_Visual.
    %
    %   properties (public)
    %       char                    char array (text, public setter)
    %       format                  PTB3_TextFormat object (public setter)
    %
    %   inherited properties
    %       screen                  int scalar (PTB3 screen index)
    %
    %   methods
    %       PTB3_Text               Constructor
    %       draw                    Draws given char array on given window
    
    
    properties (GetAccess = public, SetAccess = public)
        char
        format
    end
    
    methods
        function obj = PTB3_Text(screen_, char_, format_)
            %PTB3_Text: Constructor.
            %
            %   Input:  int scalar (PTB3 screen index)
            %           char array (text)
            %           PTB3_TextFormat object (optional)
            %   Output: PTB3_Text object
            
            obj = obj@PTB3_Visual(screen_);
            
            if nargin < 3, format_ = PTB3_TextFormat; end
            obj.char = char_;
            obj.format = format_;
        end
        
        function obj = set.format(obj, format_)
            %set.format sets property format.
            %
            %   Input:  PTB3_TextFormat object
            
            if ~Misc.is(format_, 'PTB3_TextFormat', 'scalar')
                error('Input must be a PTB3_TextFormat object.');
            end
            obj.format = format_;
        end
        
        function obj = set.char(obj, char_)
            %set.char sets property char.
            %
            %   Input:  char array
            
            if ~ischar(char_), error('Input must be a char array.'); end
            obj.char = char_;
        end
            
        function t = draw(obj, tFlip)
            %draw draws the text. If no drawing time is defined, the window
            %will not be flipped. Drawing time is the absolute time as 
            %returned by GetSecs. Works with arrays.
            %
            %   Input:  float scalar (drawing time, opt.)
            %   Output: double scalar (timestamp)

            if obj.isHetero
                if nargin == 2, obj.drawHetero(tFlip); 
                else, obj.drawHetero; 
                end
                return;
            elseif nargin == 2 && ~Misc.is(tFlip, 'float', 'scalar', '~isnan')
                error('Input must be a non-NaN float scalar.');
            end
            
            if numel(obj) > 1
                for i = 1 : numel(obj), obj(i).draw; end
            else
                %set text size and font type
                winH = PTB3_Window.getHandle(obj.screen);                   %get PTB3 windows handle
                Screen('TextSize', winH, obj.format.size);
                Screen('TextFont', winH, obj.format.font);

                %get position reference if not defined
                if isempty(obj.format.pos)
                    [wWindow, hWindow] = ...
                        Screen('WindowSize', winH);

                    if obj.format.paragraph.isVerticallyCentered || ...
                            obj.format.paragraph.isOnBaseline
                        obj.format.pos(2) = hWindow / 2;
                    elseif obj.format.paragraph.isTopAligned
                        obj.format.pos(2) = 0;
                    elseif obj.format.paragraph.isBottomAligned
                        obj.format.pos(2) = hWindow;
                    end

                    if obj.format.paragraph.isHorizontallyCentered
                        obj.format.pos(1) = wWindow / 2;
                    elseif obj.format.paragraph.isLeftAligned
                        obj.format.pos(1) = 0;
                    elseif obj.format.paragraph.isRightAligned
                        obj.format.pos(1) = wWindow;
                    end
                end

                %text width and height of boundary box, get its position
                iEOL = [1, find(obj.char == 10), numel(obj.char) + 1];      %find EOLs
                nline = numel(iEOL) - 1;                                    %number of lines
                line = cell(1, nline);                                      %text per line
                wStr = nan(1, nline);                                       %width per line
                hStr = nan(1, nline);                                       %height per line
                hStrBelowBaseline = nan(1, nline);                          %height of text below baseline, per line
                hStrAboveBaseline = nan(1, nline);                          %height of text above baseline, per line

                for i = 1 : nline            
                    line{i} = obj.char(iEOL(i) : iEOL(i + 1) - 1);
                    [tmp1, tmp2] = Screen('TextBounds', winH, ...
                        line{i}, 0, 0, 1);
                    wStr(i) = tmp1(3);
                    hStr(i) = tmp1(4);                                      %single line: depends on characters
                    hStrBelowBaseline(i) = tmp2(4);
                    hStrAboveBaseline(i) = hStr(i) - hStrBelowBaseline(i);
                end

                %get total height of text block
                spacing_px = obj.format.paragraph.spacing * ...
                    obj.format.size;                                        %line spacing in px
                hTotal = hStr(1) - hStrBelowBaseline(1) + ...
                    spacing_px * (nline - 1) + ...
                    hStrBelowBaseline(end);

                for i = 1 : nline            
                    if obj.format.paragraph.isHorizontallyCentered
                        x = obj.format.pos(1) - round(wStr(i) / 2);
                    elseif obj.format.paragraph.isLeftAligned
                        x = obj.format.pos(1);
                    elseif obj.format.paragraph.isRightAligned
                        x = obj.format.pos(1) - wStr(i);
                    end

                    if obj.format.paragraph.isVerticallyCentered
                        if nline == 1
                            y = obj.format.pos(2) - round(hStr / 2);
                        else
                            if i == 1
                                y = obj.format.pos(2) - round(hTotal / 2);
                            else
                                y = obj.format.pos(2) - ...
                                    round(hTotal / 2) + ...
                                    hStrAboveBaseline(1) + ...
                                    (i - 1) * spacing_px - ...
                                    hStrAboveBaseline(i);
                            end
                        end
                    elseif obj.format.paragraph.isTopAligned || ...
                            obj.format.paragraph.isOnBaseline
                        if nline == 1
                            y = obj.format.pos(2);
                        else
                            y = obj.format.pos(2) + ...
                                round((i - 1) * spacing_px);
                        end
                    elseif obj.format.paragraph.isBottomAligned
                        if nline == 1
                            y = obj.format.pos(2) - hStr;
                        else
                            y = round(obj.format.pos(2) - hTotal + ...
                                hStrAboveBaseline(1) + ...
                                (i - 1) * spacing_px - ...
                                hStrAboveBaseline(i));
                        end
                    end

                    Screen('glPushMatrix', winH);                           %backup copy of the current transformation matrix
                    obj.format.mirror.apply(obj.screen, ...
                        round(x + wStr(i) / 2), ...
                        round(y + hStr(i) / 2));                            %mirror
                    Screen('DrawText', winH, ...
                        line{i}, x, y, obj.format.color, [], ...
                        double(obj.format.paragraph.isOnBaseline));         %draw text
                    Screen('glPopMatrix', winH);                            %restore original transformation matrix
                end
            end
            
            %flip
            if nargin == 2
                t = PTB3_Window.flip(obj.screen, tFlip);
            elseif nargout > 0
                error(['Timestamp cannot be returned because screen ' ...
                    'was not flipped.']);                                   %flip time must be defined to flip screen and return flip time
            end
        end
end

