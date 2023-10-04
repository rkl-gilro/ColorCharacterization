classdef AFC_Key
    %AFC_Key encapsulates the user key codes used in AFC_Feedback.
    %
    %   properties
    %       pos         uint8 array (keycodes of pos keys)
    %       confirm     uint8 scalar (keycode of confirmation key)
    %       cancel      uint8 scalar (keycode of cancel key)
    %
    %   methods
    %       AFC_Key     Constructor
    %       waitForKey  Returns logical, uint8 scalar, and float scalar
    %                       (waits for keyboard input)
    %       getPos      Returns float scalar (index of property pos)
    %       isPos       Returns logical scalar
    %       isConfirm   Returns logical scalar
    %       isCancel    Returns logical scalar
    %       nPos        Returns the number of pos keys
    
    properties (GetAccess = public, SetAccess = private)
        pos
        confirm
        cancel
    end
    
    methods
        function obj = AFC_Key(pos_, confirm_, cancel_)
            %AFC_Key: Constructor.
            %
            %   Input:  uint8 array (pos keys)
            %           uint8 scalar (confirmation key)
            %           uint8 scalar (cancel key)
            %   Output: AFC_Key object
            
            if ~Misc.is(pos_, 'int', [0, 255], 'unique', 'multiple')
                error(['First parameter must be a unique uint8 array ' ...
                    'with multiple elements.']);
            elseif ~Misc.is(confirm_, 'int', 'scalar', [0, 255])
                error('Second parameter must be a uint8 scalar.');
            elseif ~Misc.is(cancel_, 'int', 'scalar', [0, 255])
                error('Third parameter must be a uint8 scalar.');
            end
            
            obj.pos = uint8(pos_);
            obj.confirm = uint8(confirm_);
            obj.cancel = uint8(cancel_);
        end
        
        function [aborted, key, rt] = waitForKey(obj)
            %waitForKey waits for keyboard input.
            %
            %   Output: logical scalar (true = cancel key was pressed)
            %           uint8 scalar (key code)
            %           float scalar (reaction time)
            
            [key, rt] = Misc.waitForKey([obj.pos, obj.cancel]);
            aborted = isequal(key, obj.cancel);
        end

        function y = getPos(obj, x)
            %getPos returns the index of property pos corresponding 
            %to an input keycode.
            %
            %   Input:  uint8 scalar
            %   Output: float scalar
            
            if ~Misc.is(x, 'int', 'scalar', [0, 255])
                error('Input must be a uint8 scalar.'); 
            end
            y = find(obj.pos == x);
        end
        
        function y = isPos(obj, x)
            %isPos returns a logical scalar (true if input is contained
            %in property pos).
            %
            %   Input:  uint8 scalar
            %   Output: logical scalar
            
            y = ~isempty(obj.getPos(x));
        end
        
        function y = isConfirm(obj, x)
            %isConfirm returns a logical scalar (true if input is equal to
            %property confirm).
            %
            %   Input:  uint8 scalar
            %   Output: logical scalar
            
            if ~Misc.is(x, 'int', 'scalar', [0, 255])
                error('Input must be a uint8 scalar.'); 
            end
            y = obj.confirm == x;
        end
        
        function y = isCancel(obj, x)
            %isCancel returns a logical scalar (true if input is equal to
            %property cancel).
            %
            %   Input:  uint8 scalar
            %   Output: logical scalar
            
            if ~Misc.is(x, 'int', 'scalar', [0, 255])
                error('Input must be a uint8 scalar.'); 
            end
            y = obj.cancel == x;
        end
        
        function x = nPos(obj)
            %nPos returns the number of pos keys.
            %
            %   Output: float scalar
            
            x = numel(obj.pos);
        end
    end
end

