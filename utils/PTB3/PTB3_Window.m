classdef (Abstract) PTB3_Window
    %PTB3_Window is an abstract class that wraps basic PTB3 Screen 
    %functionality to deal with PTB3 windows with static methods. 
    %       
    %   static methods
    %       open                Returns int array (PTB3 window handles, 
    %                               opens windows if necessary)
    %       close               Closes window
    %       getHandle           Returns int scalar (PTB3 window handle)
    %       isOpen              Returns logical array (true = window open)
    %       dim                 Returns 1 x 2 int ([height, width])
    %       width               Returns int scalar
    %       height              Returns int scalar
    %       fps                 Returns float scalar (nominal frame rate)
    %       fill                Fills window(s) with given color
    %       flip                Returns float scalar (timestamp)
    %       isUniqueFps         Returns true if screens have the same fps

    methods (Static)
        function open(screen)
            %open opens the window associated to property screen (if not 
            %open already). Works with arrays.
            %   
            %   Input:  1 x n int (PTB3 screen indices)
            %   Output: 1 x n int (PTB3 window handles)
     
            for i = Misc.flat(find(~PTB3_Window.isOpen(screen)))'           %#ok. Indices of objects where no window is open
                Screen('OpenWindow', screen(i));                            %open window
            end
        end
        
        function close(screen)
            %close closes the window. Works with arrays.
            %
            %   Input:  1 x n int (PTB3 screen indices)
            
            for i = Misc.flat(find(PTB3_Window.isOpen(screen)))'            %#ok. Indices of objects where a window is open
                Screen('Close', screen(i).getHandle);                       %close window
            end
        end        
        
        function x = getHandle(screen)
            %getHandle returns the PTB3 window handle corresponding to 
            %property screen. If window is not open, a error will be 
            %thrown. Works with arrays.
            %
            %   Input:  1 x n int (PTB3 screen indices)
            %   Output: int array (PBT3 window handle(s))
            
            n = numel(screen);                                              %number of input screens
            x = nan(1, n);                                                  %allocate output variable
            h = Screen('Windows');                                          %handles of all open PTB3 windows
            if n == 1
                for i = 1 : numel(h)                                        %pass handles of open windows
                    if Screen('WindowScreenNumber', h(i)) == screen
                        x = h(i);
                        break;
                    end
                end
            else                                                            %multiple objects
                [uqScreen, ~, iScreen] = unique(screen);                    %uqScreen = unique PTB3 screen indices; iScreen = indices within uqScreen corresponding to screen
                for i = 1 : numel(h)                                        %pass handles of open windows
                    jScreen = find(uqScreen == ...
                        Screen('WindowScreenNumber', h(i)));                %true = screen index corresponding to current window handle is equal to one of element in uqScreen
                    if ~isempty(jScreen), x(iScreen == jScreen) = h(i); end %handle found: set output element(s)
                    if all(~isnan(x)), break; end                           %break if all output elements were found
                end
            end
            if any(isnan(x)), error('Window is not open.'); end             %true = at least one window handle corresponding to a PTB3 screen index was not found (i.e., the corresponding window is not open)
        end

        function x = isOpen(screen)
            %exist returns true if the windows corresponding to property 
            %screen isOpen. Works with arrays.
            %
            %   Output: logical array (true = windows exist / is open)
            
            n = numel(screen);                                              %number of input screens
            h = Screen('Windows');                                          %handles of all open PTB3 windows

            if isempty(h)
                x = false(1, n);
            elseif n == 1
                for i = 1 : numel(h)                                        %pass handles of open windows
                    x = Screen('WindowScreenNumber', h(i)) == screen;
                    if x, break; end
                end
            else                                                            %multiple objects
                x = false(1, n);                                            %allocate output variable
                [uqScreen, ~, iScreen] = unique(screen);                    %uqScreen = unique PTB3 screen indices; iScreen = indices within uqScreen corresponding to screen
                for i = 1 : numel(h)                                        %pass handles of open windows
                    jScreen = find(uqScreen == ...
                        Screen('WindowScreenNumber', h(i)));                %true = screen index corresponding to current window handle is equal to one of element in uqScreen
                    if ~isempty(jScreen), x(iScreen == jScreen) = true; end %handle found: set output element(s)
                    if all(x), break; end                                   %break if all unique screens were found
                end
            end
        end
        
        function x = dim(screen)
            %dim returns the window dimensions in px.
            %
            %   Output: 1 x 2 int ([height, width])
            
            [x(2), x(1)] = Screen('WindowSize', screen);
        end
        
        function x = width(screen)
            %width returns the window width.
            %
            %   Output: int scalar
            
            x = PTB3_Window.dim(screen);
            x = x(2);
        end
        
        function x = height(screen)
            %height returns the window height.
            %
            %   Output: int scalar
            
            x = PTB3_Window.dim(screen);
            x = x(1);
        end
        
        function x = fps(screen)
            %fps returns the window's nominal frame rate.
            %
            %   Output: float scalar

            x = Screen('FrameRate', screen);
        end
        
        function fill(screen, col)
            %fill fills the screen with a given color. Works with arrays.
            %
            %   Input:  1 x 3 int ({R, G, B])
            
            if ~all(PTB3_Window.isOpen(screen))
                error('Window is not open.');
            elseif ~Misc.is(col, 'int', {'numel', 3})
                error('Input must be a 1 x 3 int array.');
            end
            for i = 1 : numel(screen)
                Screen('FillRect', PTB3_Window.getHandle(screen(i)), ...
                    col(:)');
            end
        end
        
        function t = flip(screen, tFlip)
            %dflip flips the screen(s) at the given absolute time (as 
            %returned by GetSecs). 
            %
            %   Input:  float scalar (flip time, def = 0 = asap)
            %   Output: float scalar (timestamp)
            
            if nargin < 2, tFlip = 0; end
            if ~Misc.is(tFlip, 'float', 'scalar', '~isnan')
                error('Input must be a non-NaN float scalar.');
            end
            
            %get handle(s)
            h = PTB3_Window.getHandle(screen);
            uqH = unique(h);                                                %unique window handles corresponding to objects
            nUqH = numel(uqH);                                              %number of unique windows of objects
            nWindow = numel(Screen('Windows'));                             %number of all windows
            if nUqH == 1
                t = Screen('Flip', uqH, tFlip);                             %single window: flip specified window only
            elseif nUqH < nWindow                                           
                for i = 1 : nUqH
                    t = Screen('AsyncFlipBegin', uqH(i), tFlip);            %multiple but not all windows: asynchronous flip              
                end
            else
                t = Screen('Flip', h(1), tFlip, [], [], 1);                 %all multiple windows: flip all synchronously
            end
        end
    
        function x = isUniqueFps(screen)
            %isUniqueFps returns true if all windows share the same nominal
            %fps.
            %
            %   Input:  int array (screen indices, def = all)
            %   Output: logical scalar
            
            screenDef = Screen('Screens'); 
            if nargin == 0
                screen = screenDef;
            elseif ~Misc.is(screen, 'int', '~isempty')
                error('Input must be a non-empty int array.');
            elseif  ~all(ismember(screen, screenDef))
                error('Invalid screen index.');
            end
            
            n = numel(screen);
            fps = nan(1, n);
            for i = 1 : n
                fps(i) = Screen('FrameRate', screen(i));
            end
            x = numel(unique(fps)) == 1;
        end
    end
end