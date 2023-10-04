classdef (Abstract) PTB3_Visual < matlab.mixin.Heterogeneous & handle
    %PTB3_Visual is an abstract class that encapsulates a PTB3 screen 
    %index. Base class for PTB3_Texture and PTB3_Text. Base classes are 
    %handle and matlab.mixin.Heterogeneous.
    %
    %   properties
    %       screen          int scalar (PTB3 screen index)
    %
    %   methods
    %       PTB3_Visual     Constructor
    %       make            Makes calls make of PTB3_Texture objects
    %       close           Closes calls close of PTB3_Texture objects
    
    properties (GetAccess = public, SetAccess = private)
        screen
    end
    
    methods
        function obj = PTB3_Visual(screen_)
            %PTB3_Visual: Constructor.
            %
            %   Input:  int scalar (PTB3 screen index)
            %   Output: PTB3_Visual object
            
            if ~Misc.is(screen_, 'int', 'scalar', {'>=', 0})
                error('Input must be an int scalar >= 0.');
            end
            obj.screen = screen_;
        end
        
        function make(obj)
            %make calls make for PTB3_Texture objects. Works with arrays.
            
            for i = 1 : numel(obj)
                if Misc.is(obj(i), 'PTB3_Texture'), obj(i).make; end
            end            
        end
        
        function close(obj)
            %close calls close of PTB3_Texture objects. Works with arrays.
            
            for i = 1 : numel(obj)
                if Misc.is(obj(i), 'PTB3_Texture') && ~isempty(obj(i).h)
                    Screen('Close', obj(i).h); 
                end
            end
        end
    end
    
    methods (Sealed, Access = protected)
        function x = isHetero(obj)
            %isHetero returns true if the inpuut if called from an 
            %heterogeneous PTB3_Visual array.
            %
            %   Output: logical scalar
            
            x = Misc.is(obj, 'PTB3_Visual');
        end
        
        function t = drawHetero(obj, tFlip)
            %drawHetero draws the visual, and flips the screen(s) if a flip
            %time is defined. Called by draw of a subclass if object array
            %is heterogeneous.
            %
            %   Input:  float scalar (flip time as returned by GetSecs, 
            %               0 = asap, optional)
            %   Output: float array (timestamp, if flip time was defined)

            if nargin == 2 && ~Misc.is(tFlip, 'float', 'scalar', '~isnan')
                error('Input must be a non-NaN float scalar.');
            end
            
            for i = 1 : numel(obj), obj(i).draw; end

            if nargin == 2
                t = PTB3_Window.flip([obj.screen], tFlip);
            elseif nargout > 0
                error(['Timestamp cannot be returned because screen ' ...
                    'was not flipped.']);                                   %flip time must be defined to flip texture and return flip time
            end            
        end
    end
end