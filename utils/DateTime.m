classdef DateTime
    %DateTime encapsulates date and time.
    %
    %   properties
    %       num             float scalar (serial date number)
    %
    %   methods
    %       DateTime        Constructor
    %       char            Returns char array corresponding to date
    %       vec             Returns 1 x 6 float array ([y m d h m s])
    %       toFilename      Returns char array (filename compatible)
    %       charNumMonth    Returns char array (month is a numeral)
    %       isInInterval    Returns logical
    %
    %   operators
    %       -               Returns float array (sec., works with arrays)
    %       ==              Returns logical array
    %       <               Returns logical array
    %       >               Returns logical array
    %       <=              Returns logical array
    %       >=              Returns logical array
    %       
    %   static methods
    %       diff            Returns float array (time differences in sec.)
    %       getDatenum      float scalar
    %       isDatenum       Returns logical scalar
    %       isDatevec       Returns logical scalar
    %       isDatestr       Returns logical scalar
    
    properties
        num
    end
    
    methods
        function obj = DateTime(x)
            %DateTime: Constructor
            %
            %   Input:  OPTIONAL (default = now)
            %           float scalar (serial date number as returned by 
            %               datenum) 
            %           OR 1 x 6 float (Date component vector as returned 
            %               by datevec) 
            %           OR char array (as returned by datestr)
            %   Output: DateTime object
            
            if nargin == 0, x = now; end
            if ~(DateTime.isDatenum(x) || DateTime.isDatevec(x) || ...
                DateTime.isDatestr(x))
                error(['Input must be a serial date number as ' ...
                    'returned by datenum, a date component vector as ' ...
                    'returned by datevec, or a date char array as ' ...
                    'eturned by datestr.']);
            end
            
            obj.num = DateTime.getDatenum(x);
        end
        
        function x = char(obj)
            %char returns the date and time as a char array.
            %
            %   Output: char array
            
            x = datestr(obj.num);
        end
            
        function x = vec(obj, i)
            %vec returns the corresponding date vector.
            %
            %   Input:  int array (index, def = 1 : 6)
            %   Output: 1 x 6 float array
            
            x = datevec(obj.num);
            if nargin == 2 
                if ~Misc.is(i, 'int', [1, 6])
                    error('Input must be an int in [1 6].');
                end
                x = x(i);
            end
        end
            
        function x = toFilename(obj)
            %toFilename returns a filename compatible version of property 
            %char.
            %
            %   Ouput: char array (DD-MMM-YYY_hh-mm-ss)
            
            x = obj.char;
            x(x == ' ') = '_';
            x(x == ':') = '-';
        end
        
        function x = charNumMonth(obj)
            %charNumMonth returns a char array where also the month is a 
            %number. 
            %
            %   Ouput: char array (DD-MM-YYY hh:mm:ss)
            
            x = datestr(obj.vec, 'dd-mm-yyyy HH:MM:SS');
        end
        
        function y = minus(obj, x)
            %minus is an overload of operator minus. Returns the number of 
            %seconds passed. Works with arrays.
            %
            %   Input:  DateTime object
            %   Output: float array (seconds)
            
            dimX = size(x);
            dimObj = size(obj);
            nX = numel(x);
            nObj = numel(obj);
            
            if ~(isa(x, 'DateTime') && ...
                    (nX == 1 || nObj == 1 || isequal(dimX, dimObj)))
                if prod(dim) > 1
                    error(['Input must be a DateTime object or a ', ...
                        repmat('%d x ', [1, nObj - 1]), ...
                        '%d DateTime array.'], dimObj);
                else
                    error('Input must be a DateTime object.');
                end                    
            end
    
            if nX < nObj, x = repmat(x, dimObj); end
            if nObj < nX, obj = repmat(obj, dimX); end

            y = nan(size(x));
            for i = 1 : numel(x)
                y(i) = etime(obj(i).vec, x(i).vec);
            end
        end
        
        function b = eq(obj, x)
            %eq is an overload of operator ==. Works with arrays.
            %
            %   Input:  DateTime array
            %   Output: logical array
            
            b = obj - x == 0;
        end
        
        function b = lt(obj, x)
            %lt is an overload of operator <. Works with arrays.
            %
            %   Input:  DateTime array
            %   Output: logical array

            b = obj - x < 0;
        end
            
        function b = gt(obj, x)
            %gt is an overload of operator >. Works with arrays.
            %
            %   Input:  DateTime array
            %   Output: logical array

            b = obj - x > 0;
        end
        
        function b = le(obj, x)
            %le is an overload of operator <=. Works with arrays.
            %
            %   Input:  DateTime array
            %   Output: logical array

            b = obj - x <= 0;
        end
            
        function b = ge(obj, x)
            %ge is an overload of operator >=. Works with arrays.
            %
            %   Input:  DateTime array
            %   Output: logical array

            b = obj - x >= 0;
        end
        
        function x = isInInterval(obj, interval)
            %isInInterval returns true if the date time is within the given
            %interval. Works with arrays.
            %
            %   Input:  1 x 2 DateTime
            %   Output: logical array
            
            if ~(Misc.is(interval, 'DateTime', {'numel', 2}) && ...
                    interval(2) > interval(1))
                error('Input must be a 1 x 2 DateTime interval.');
            end
            
            x = obj >= interval(1) & obj <= interval(2);
        end
    end
    
    methods (Static)
        function x = diff(obj)
            %diff returns the time differences between the elements of an 
            %input DateTime array.
            %
            %   Input:  1 x n DateTime
            %   Output: 1 x n - 1 float
           
            n = numel(obj);
            if ~Misc.is(obj, 'DateTime', 'multiple')
                error(['Input must be a DateTime array with multiple ' ...
                    'elements.']);
            end
            
            x = obj(2 : n) - obj(1 : n - 1);
        end

        function x = getDatenum(x)
            %getDatenum converts datevec or datestr into datenum, where
            %german month names are accepted for datestr.
            %
            %   Input:  float scalar (serial date number as returned by 
            %               datenum) 
            %           OR 1 x 6 float (Date component vector as returned 
            %               by datevec) 
            %           OR char array (as returned by datestr)
            %   Output: float scalar (serial date number)
            
            %convert german to english month names
            if ischar(x)
                monthGerman = {'Mrz' 'Mai' 'Okt' 'Dez'};
                monthEnglish = {'Mar' 'May' 'Oct' 'Dec'};
                i = find(ismember(x(4 : 6), monthGerman));
                if ~isempty(i), x(4 : 6) = monthEnglish{i}; end
            end
            if ~(DateTime.isDatenum(x) || DateTime.isDatevec(x) || ...
                DateTime.isDatestr(x))
                error(['Input must be a serial date number as returned ' ...
                    'by datenum, a date component vector as returned ' ...
                    'by datevec, or a date char array as returned by ' ...
                    'datestr.']);
            end
            
            x = datenum(x);
        end
        
        function b = isDatenum(x)
            %isDatenum returns true if input parameter is a float scalar
            %as returned by now.
            %
            %   Input:  arbitrary
            %   Output: logical scalar

            if isnumeric(x) && numel(x) == 1
                try
                    datevec(x);
                    b = true;
                catch
                    b = false;
                end
            else
                b = false;
            end
        end        

        function b = isDatestr(x)
            %isDatestr returns true if input parameter is an char array 
            %as returned by datestr.
            %
            %   Input:  arbitrary
            %   Output: logical scalar

            if ischar(x)
               try
                    datenum(x);
                    b = true;
                catch
                    b = false;
                end
            else
                b = false;
            end
        end
        
        function b = isDatevec(x)
            %isDatevec returns true if input parameter is an array as 
            %returned by datevec.
            %
            %   Input:  arbitrary
            %   Output: logical scalar

            if isnumeric(x) && numel(x) == 6
                try
                    datenum(x);
                    b = true;
                catch
                    b = false;
                end
            else
                b = false;
            end
        end
    end
end