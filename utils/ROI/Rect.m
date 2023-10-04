classdef Rect < handle
    %Rect encapsulates the coordinates of a rectangle in an image.
    %
    %   properties
    %       x           int scalar (x-coordinate of upper left edge)
    %       y           int scalar (y-coordinate of upper left edge)
    %       w           int scalar (width)
    %       h           int scalar (height)
    %
    %   methods
    %       Rect        Contructor
    %       dim         Returns 1 x 2 int ([height, width])
    %       center      Returns 1 x 2 float ([x, y] of center)
    %       xywh        Returns 1 x 4 int ([x, y, w, h])
    %       x1          Returns int scalar (x of left edge)
    %       y1          Returns int scalar (y of upper edge)
    %       x2          Returns int scalar (x of right edge)
    %       y2          Returns int scalar (y of lower edge)
    %       crop        Returns Rect object (cropped to given image dim.)
    
    properties
        x
        y
        w
        h
    end
    
    methods
        function obj = Rect(x_, y_, w_, h_)
            %Rect: Constructor.
            %
            %   Input:  int scalar (x-position upper left corner)
            %           int scalar (y-position upper left corner)
            %           int scalar (width)
            %           int scalar (height)
            %   Output: Rect object
            
            if ~Misc.is(x_, 'int', 'scalar')
                error('First parameter must be an int scalar.');
            elseif ~Misc.is(y_, 'int', 'scalar')
                error('Second parameter must be an int scalar.');
            elseif ~Misc.is(w_, 'int', 'scalar', {'>=', 0})
                error('Third parameter must be an int scalar >= 0.');
            elseif ~Misc.is(h_, 'int', 'scalar', {'>=', 0})
                error('Fourth parameter must be an int scalar >= 0.');
            end
            
            obj.x = x_;
            obj.y = y_;
            obj.w = w_;
            obj.h = h_;
        end
        
        function k = dim(obj)
            %dim returns the rectangle dimensions [height weidth].
            %
            %   Input:  Rect object
            %   Output: 1 x 2 int ([x, y])

            k = [obj.h obj.w];
        end

        function k = center(obj)
            %center returns the coordinates of the center.
            %
            %   Input:  Rect object
            %   Output: 1 x 2 float ([x, y])
            
            k = [obj.x + obj.w / 2, obj.y + obj.h / 2];
        end
        
        function k = xywh(obj)
            %xywh returns properties x, y, w, and h as 1 x 4 int array.
            %
            %   Output: 1 x 4 int ([x, y, w, h])
            
            k = [obj.x, obj.y, obj.w, obj.h];
        end
        
        function k = x1(obj)
            %x1 returns the x-coordinate of the left edge.
            %
            %   Output: int scalar
            
            k = obj.x;
        end
        
        function k = y1(obj)
            %y1 returns the y-coordinate of the upper edge.
            %
            %   Output: int scalar
            
            k = obj.y;
        end
        
        function k = x2(obj)
            %x2 returns the x-coordinate of the right edge.
            %
            %   Output: int scalar
            
            k = obj.x + obj.w - 1;
        end
        
        function k = y2(obj)
            %y2 returns the y-coordinate of the lower edge.
            %
            %   Output: int scalar
            
            k = obj.y + obj.h - 1;
        end
        
        function crop(obj, dim)
            %crop limits the values of rect coordinates to match given
            %image dimensions.
            %
            %   Input:  1 x 2 int (image dim. [height, width])
            
            if ~Misc.is(dim, 'pos', 'int', {'numel', 2})
                error('Input must be a positive 1 x 2 int array.');
            end
            
            %lower boundary
            if (obj.x < 1), obj.x = 1; end
            if (obj.y < 1), obj.y = 1; end

            %upper boundaries - depends on image size
            if (obj.x + obj.w > dim(2)), obj.w = dim(2) - obj.x + 1; end 
            if (obj.y + obj.h > dim(1)), obj.h = dim(1) - obj.y + 1; end 
        end
    end
end

