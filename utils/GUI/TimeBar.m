classdef TimeBar < handle
    %TimeBar encapsulates a waitbar that shows the remaining time for
    %computation.
    %
    %   properties
    %       h           matlab.ui.Figure object
    %       t           double scalar (start time)
    %       text        char array (shown in waitbar window)
    %       ndecimal    int scalar (number of decimal places shown)
    %       done        double scalar (proportion done)
    %
    %   properties
    %       TimeBar     Constructor
    %       update      Updates properties done and refreshes waitbar
    %       close       Closes the waitbar
    
    properties
        h
        t
        text
        ndecimal
        done
    end
    
    methods
        function obj = TimeBar(text_, ndecimal_)
            %TimeBar: Constructor.
            %
            %   Input:  char array (waitbar core text)
            %           int scalar (number od decimal places, >= 0)
            %   Output: TimeBar object
            
            
            if ~ischar(text_)
                error('First parameter must be a char array.');
            elseif nargin < 2
                ndecimal_ = 0;
            elseif ~Misc.is(ndecimal_, 'int', 'scalar', {'>=', 0})
                error('Second parameter must be an int scalar >= 0.');
            end

            obj.text = text_;
            obj.done = 0;
            obj.ndecimal = ndecimal_;
            obj.h = waitbar(obj.done, sprintf('%s 0%%\n', obj.text));
            obj.t = datenum(clock);
        end
        
        function update(obj, done_)
            %update updates property done and refreshes the waitbar if 
            %necessary.
            %
            %   Input:  double scalar (proportion job is done, in [0 1])
            
            if round(obj.done * 10 ^ (obj.ndecimal + 2)) ~= ...
                    round(done_ * 10 ^ (obj.ndecimal + 2))
                obj.done = done_;
                c = sprintf(['%s %.' num2str(obj.ndecimal) ...
                    'f%%\nRemaining: %s'], obj.text, obj.done * 100, ...
                    datestr((1 - obj.done) / obj.done * ...
                    (datenum(clock) - datenum(obj.t)), 'HH:MM:SS'));
                
                try waitbar(obj.done, obj.h, c);
                catch, obj.h = waitbar(obj.done, c);                        %re-open if closed
                end
            end
            if done_ == 1, obj.close; end
        end
        
        function close(obj)
            %close closes the waitbar figure.
            try close(obj.h); catch, end
        end
    end
    
end

