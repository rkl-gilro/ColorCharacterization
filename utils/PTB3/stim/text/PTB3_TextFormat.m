classdef PTB3_TextFormat
    %PTB3_TextFormat encapsulates properties and methods to format text
    %with PTB3.
    %
    %   properties
    %       font                char array (font type)
    %       size                int scalar (font size)
    %       pos                 1 x 2 int (position, [x, y])
    %       color               1 x 3 uint8 (font color)
    %       mirror              PTB3_Mirror object
    %       paragraph           PTB3_Paragraph object
    %
    %   methods
    %       PTB3_TextFormat     Constructor
    
    properties (GetAccess = public, SetAccess = public)
        font
        size
        pos
        color
        mirror
        paragraph    
    end
    
    methods
        function obj = PTB3_TextFormat(varargin)
            %PTB3_TextFormat: Constructor.
            %
            %   Input:      OPTIONAL, IN ARBITRARY ORDER
            %           char array (Arial, Geneva, Helvetica, sans-serif, 
            %               DejaVu Sans)
            %           int scalar (font size)    
            %           1 x 2 int (position, [x, y])
            %           1 x 3 uint8 or float (color, [R, G, B])
            %           1 x 2 logical ([hor., ver.] mirroring)
            %           PTB3_Paragraph object
            %   Output: PTB3_TextFormat object

            %default values
            obj.font = 'Arial';
            obj.size = 32;
            obj.color = [0, 0, 0];
            obj.mirror = PTB3_Mirror;
            
            %set properties
            prop = properties(obj);
            valid = false;
            
            for i = 1 : numel(varargin)
                for j = 1 : numel(prop)
                    if ~valid
                        try 
                            obj.(prop{j}) = varargin{i};
                            valid = true;
                        catch
                        end
                    end
                    if ~valid
                        error('%s parameter is redundant or unknown.', ...
                            Misc.ordinalNumber(i));
                    end
                end
            end

            if isempty(obj.paragraph)
                if isempty(obj.pos)
                    obj.paragraph = PTB3_Paragraph('c', 'c');
                else
                    obj.paragraph = PTB3_Paragraph('l', 'l');
                end
            end
        end
        
        function obj = set.font(obj, x)
            %set.font sets property font.
            %
            %   Input:  char array (Arial, Geneva, Helvetica, sans-serif, 
            %               DejaVu Sans)
            
            valid = {'Arial', 'Geneva', 'Helvetica', 'sans-serif', ...
                'DejaVu Sans'};
            if ~Misc.isInCell(x, valid)
                error('Input must be %s.', Misc.cellToList(valid));
            end
            obj.font = x;
        end
        
        function obj = set.size(obj, x)
            %set.size sets property size.
            %
            %   Input:  int scalar
            
            if ~Misc.is(x, 'pos', 'int', 'scalar')
                error('Input must be a positive int scalar.');
            end
            obj.size = x;
        end

        function obj = set.pos(obj, x)
            %set.pos sets property pos.
            %
            %   Input:  1 x 2 int

            if ~Misc.is(x, 'int', {'numel', 2})
                error('Input must be a 1 x 2 int array.');
            end
            obj.pos = x(:)';
        end
        
        function obj = set.color(obj, x)
            %set.color sets property color.
            %
            %   Input:  1 x 3 int

            if ~Misc.is(x, 'int', {'>=', 0}, {'numel', 3})
                error('Input must be a 1 x 3 array >= 0.');
            end
            obj.color = uint8(x(:)');
        end
        
        function obj = set.mirror(obj, x)
            %set.mirror sets property mirror.
            %
            %   Input:  PTB3_Mirror object

            if ~Misc.is(x, 'PTB3_Mirror', 'scalar')
                error('Input must be a PTB_Mirror object.');
            end
            obj.mirror = x(:);
        end
        
        function obj = set.paragraph(obj, x)
            %set.paragraph sets property paragraph.
            %
            %   Input:  PTB3_Paragraph object

            if ~Misc.is(x, 'PTB3_Paragraph', 'scalar')
                error('Input must be a PTB3_Paragraph object.');
            end
            obj.paragraph = x;
        end
    end
end

