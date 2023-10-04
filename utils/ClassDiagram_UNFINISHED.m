classdef ClassDiagram
   %ClassDiagram provides a class diagramm of a given class, that is, a 
   %visualization of the class' properties and methods, as well as the 
   %corresponding base and child classes.
   %
   %
   
   
   methods
        function obj = ClassDiagram(classname)
            %ClassDiagram: Constructor.
            %
            %   Input:  char array (class name)
            %   Output: ClassDiagram output (and visualization)
            
            if ~Misc.is(classname, 'char', '~isempty')
                error('Input must be a nonempty char array.');string 
            end
            
            try
                eval(sprintf('mc = ?%s;', classname));
            catch ME
                error('Class %s does not exist.', classname);
            end

            if numel(mc) == 0
                error('Class %s does not exist.', classname);
            elseif numel(mc) == 1
                error('Classname %s is ambiguous.', classname);
            end
            
            if ~mc.Abstract
                p = mc.PropertyList;
                for i = 1 : numel(p)
                    
                end
                
                m = mc.MethodsList;
            end 
        end
end
   