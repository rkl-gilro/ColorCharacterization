classdef AFC_DataSet < handle
    %AFC_DataSet encapsulates AFC_Data for a one subject and experiment.
    %Base class is handle.
    %
    %   properties
    %       subject         char array (subject name)    
    %       dateTime        Returns DateTime object (of first trial)
    %       filename        char array 
    %       data            AFC_Data array
    %       tag             cell array (of char arrays, stimulus category)
    %       method          AFC_Method array
    %       nPos            int scalar (number of AFC positions)
    %
    %   methods
    %       AFC_DataSet     Constructor
    %       isAborted       Returns logical (true = data set is incomplete)
    %       nBlock          int scalar
    
    properties (GetAccess = public, SetAccess = private)
        subject
        dateTime
        filename
        data
        tag
        method
        nPos
    end
    
    methods
% - AFC_DataSet 
%     - durations der Frames aus block_ auslesen und abspeichern 
%       - funktion um Abw der Dauer auszugeben (auch fuer post!)
% - AFC_StartTime in AFC_Exp setzen
% - continue: blocks sind invalid da texturen neu geladen werden muessen. 
%    - continue in AFC_Exp. AFC_DataSet object laden und ueberrpeufen ob blocks gleich
%        - dabei bereits fertige blocks ignorieren (= koennen leer sein)
% - AFC_Quest und Weibull nicht auf log10 basieren - zu fehleranfaellig. D.h. Wert 0 ist nicht erlaubt
% - DEBUGGEN; Test mit einfachem Stimuluspattern
        
        
        function obj = AFC_DataSet(subject_, block_)
            %AFC_Data: Constructor.
            % 
            %   Input:  char array (subject name)
            %           AFC_Block array
            %   Output: AFC_DataSet object
            
            if ischar(subject_)
                error('First parameter must be a char array.');
            elseif ~Misc.is(block_, 'AFC_Block', '~isempty')
                error('Second parameter must be an AFC_Block array.');
            end
            
            obj.subject = subject_;
            obj.dateTime = DateTime(now);
            obj.method = [block_.method];
            obj.data = AFC_Data.empty;
            obj.nPos = block_(1).nPos;
            obj.tag = cell(1, numel(block_));                               %set tag
            for i = 1 : numel(block_)
                obj.tag{i} = block_(i).tag;
                if i > 1 && isequal(obj.tag{i}, obj.tag{i - 1})
                    error('Redundant tags.');
                end
            end
            folder = sprintf('%sdata/%s/', Misc.getPath('AFC_Exp'), ...
                obj.subject);
            if ~exist(folder, 'dir'), mkdir(folder), end
            obj.filename = sprintf('%s%s_%s.mat', folder, obj.subject, ...
                obj.dateTime.toFilename);                                   %set filename
        end
        
        function append(obj, x)
            %append appends an AFC_Data object to property data.
            %
            %   Input:  AFC_Data object
            %   Output: AFC_DataSet object
            
            if ~Misc.is(x, 'AFC_Data', 'scalar')
                error('Input must be a AFC_Data object.');
            end
            
            obj.data(end + 1) = x;
        end
        
        function x = isAborted(obj)
            %isAborted returns true if last element in data was aborted.
            %
            %   Output: logical
            
            if isempty(obj.data), error('Property data is empty.'); end
            x = obj.data(end).aborted;
        end
            
        function x = nBlock(obj)
            %nBlock returns the number of property blockTag.
            %
            %   Output: int scalar
            
            x = numel(obj.tag);
        end
    end
end

