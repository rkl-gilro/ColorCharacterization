classdef PTB3_Paragraph
    %PTB3_Paragraph encapsulates the alignment and line spacing 
    %characteristics of a PTB3_Text object.
    %
    %   properties
    %       h                           char (horizontal alignment)
    %       v                           char (vertical alignment)
    %       spacing                     float scalar (line spacing, rel. to 
    %                                   font size)
    %
    %   methods
    %       PTB3_Paragraph              Constructor
    %       isHorizontallyCentered      Returns logical scalar
    %       isLeftAligned               Returns logical scalar
    %       isRightAligned              Returns logical scalar
    %       isVerticallyCentered        Returns logical scalar
    %       isTopAligned                Returns logical scalar
    %       isBottomAligned             Returns logical scalar
    %       isOnBaseline                Returns logical scalar
    
    properties (GetAccess = public, SetAccess = public)
        h
        v
        spacing
    end
    
    methods
        function obj = PTB3_Paragraph(h_, v_, spacing_)
            %PTB3_Paragraph: Constructor. 
            %
            %   Input:  char (horizontal alignment: (c)entered, (l)eft, or 
            %               (r)ight; def = c)
            %           char (vertical alignment: (c)entered, (t)op, 
            %               (b)ottom, or base(l)ine; def = c)
            %           float scalar (line spacing, rel. to font size, 
            %               def = 1.2)
            %           
            %   Output: PTB3_Paragraph object

            
            if nargin < 3, spacing_ = 1.2; end
            if nargin < 2, v_ = 'c'; end
            if nargin < 1, h_ = 'c'; end
            
            obj.h = h_;
            obj.v = v_;
            obj.spacing = spacing_;
        end
        
        function obj = set.h(obj, x)
            %set.h sets property h.
            %
            %   Input:  char
        
            valid = {'c', 'l', 'r'};
            if ~Misc.isInCell(x, valid)
                error('Input must be %s.', Misc.cellToList(valid));
            end
            obj.h = x;
        end
            
        function obj = set.v(obj, x)
            %set.v sets property v.
            %
            %   Input:  char
        
            valid = {'c', 't', 'b', 'l'};
            if ~Misc.isInCell(x, valid)
                error('Input must be %s.', Misc.cellToList(valid));
            end
            obj.v = x;
        end
            
        function obj = set.spacing(obj, x)
            %set.spacing sets property spacing.
            %
            %   Input:  float scalar
        
            if ~Misc.is(x, 'float', 'scalar', {'>=', 0})
                error('Input must be a float scalar >= 0.');
            end
            obj.spacing = x;
        end
        
        function b = isHorizontallyCentered(obj)
            %isVerticallyCentered returns true if property h is set to
            %'c'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.h, 'c');
        end
                
        function b = isLeftAligned(obj)
            %isLeftAligned returns true if property h is set to 'l'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.h, 'l');
        end
                
        function b = isRightAligned(obj)
            %isLeftAligned returns true if property h is set to 'r'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.h, 'r');
        end 

        function b = isVerticallyCentered(obj)
            %isVerticallyCentered returns true if property v is set to
            %'c'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.v, 'c');
        end
                
        function b = isTopAligned(obj)
            %isLeftAligned returns true if property v is set to 't'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.v, 't');
        end
                
        function b = isBottomAligned(obj)
            %isLeftAligned returns true if property v is set to 'b'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.v, 'b');
        end
        
        function b = isOnBaseline(obj)
            %isOnBaseline returns true if property v is set to 'l'.
            %
            %   Output: logical scalar
            
            b = isequal(obj.v, 'l');
        end
    end
end

