classdef CS2000_Report
    %CS2000_Report encapsulates measurement conditions of the 
    %last or a stored measurement reported by the Konica Minolta CS-2000.
    %
    %Compared to class CS2000_Condition, the following data are missing:
    %   - synchronization frequency (if sync mode 'internal')
    %   - demanded integration time setting (for speed modes 'multi 
    %     normal' and 'manual')
    %   - compensation factors of close-up lens and external ND filters (if
    %     used)
    %   - calibration name and, for user calibration, correction spectra
    %
    %In contrast, the following additional data are available:
    %   - the actually used integration time in sec
    %   - the actual usage of an internal ND filter
    %
    %In conclusion, CS2000_Report is useful to 
    %   - provide measurement conditions for stored measurements
    %   - obtain additional information about measurement conditions
    %   - verify if a CS2000_Condition object was set correctly
    %
    %
    %   properties
    %       data                    8 x n int array
    %
    %   methods
    %       CS2000_Report           Constructor
    %       merge                   Returns CS2000_Report object
    %       count                   Returns int scalar (number of reports)
    %       speed                   Returns speed mode identifier(s)
    %       sync                    Returns sync mode identifier(s)
    %       integrationTime_sec     Returns float array (integration 
    %                                   time(s) in seconds)
    %       internalND              Returns int array (internal ND filter 
    %                                   identifier(s))
    %       lens                    Returns int array (lens mode 
    %                                   identifier(s))
    %       externalND              Returns int array (external ND filter 
    %                                   identifier(s))
    %       angle                   Returns int array (measurement angle 
    %                                   identifier(s))
    %       channel                 Returns int array (calibration channel 
    %                                   indices)
    %       print                   Prints data in human friendly format
    %                                   in command window
    
    properties (GetAccess = public, SetAccess = private)
        data
    end
    
    methods
        function obj = CS2000_Report(x)
            %CS2000_Report: Constructor.
            %
            %   Input:  8 x n int ([speed; sync; integration time in
            %               sec; internal ND filter; close-up lens; 
            %               external ND filter; measurement angle; 
            %               calibration channel)
            %   Output: CS2000_Report object
            
            if ~Misc.is(x, {'size', 1, 8})
                error('Input must be a 8 x n int array.');
            elseif ~Misc.is(x(1, :), 'int', ...
                    [0, numel(CS2000_Speed.valid) - 1])
                error('First row is invalid.');
            elseif ~Misc.is(x(2, :), 'int', ...
                    [0, numel(CS2000_Sync.valid) - 1])
                error('Second row is invalid.');
            elseif ~Misc.is(x(3, :), 'float', 'pos', 'scalar')
                error('Third row must be a positive int scalar.');
            elseif ~Misc.is(x(4, :), 'int', ...
                    [0, numel(CS2000_InternalND.valid) - 1])
                error('Fourth row is invalid.');
            elseif ~Misc.is(x(5, :), 'int', ...
                    [0, numel(CS2000_Lens.valid) - 1])
                error('Fifth row is invalid.');
            elseif ~Misc.is(x(6, :), 'int', ...
                    [0, numel(CS2000_ExternalND.valid) - 1])
                error('Sixth row is invalid.');
            elseif ~Misc.is(x(7, :), 'int', ...
                    [0, numel(CS2000_Angle.valid) - 1])
                error('Seventh row is invalid.');
            elseif ~Misc.is(x(8, :), 'int', [0, 10])
                error('Eighth row is invalid.');
            end
            
            obj.data = x;
        end

        function obj = merge(obj)
            %merge merges multiple CS2000_Report objects into one.
            %
            %   Input:  CS2000_Report array
            %   Output: CS2000_Report object
            
            if numel(obj) > 1
                tmp = obj(1);
                for i = 2 : numel(obj)
                    n = size(obj(i).data, 2);
                    tmp.data(:, end + (1 : n)) = obj(i).data;
                end
                obj = tmp;
            end
        end
        
        function x = count(obj)
            %count returns number of columns of property data, i.e, the
            %number of reports.
            %
            %   Output: int scalar
            
            x = size(obj.data, 2);
        end
        
        function x = speed(obj)
            %speed returns speed identifier(s).
            %
            %   Output: int array
            
            x = obj.data(1, :);
        end
        
        function x = sync(obj)
            %sync returns sync identifier(s).
            %
            %   Output: int array
            
            x = obj.data(2, :);
        end
        
        function x = integrationTime_sec(obj)
            %integrationTime_sec returns integration time in seconds.
            %
            %   Output: float array
            
            x = obj.data(3, :);
        end
        
        function x = internalND(obj)
            %internalND returns internal ND filter identifier(s).
            %
            %   Output: int array
            
            x = obj.data(4, :);
        end
         
        function x = lens(obj)
            %lens returns close-up lens identifier(s).
            %
            %   Output: int array
            
            x = obj.data(5, :);
        end
       
        function x = externalND(obj)
            %externalND returns external ND filter identifier(s).
            %
            %   Output: int array
            
            x = obj.data(6, :);
        end
         
        function x = angle(obj)
            %angle returns measurement angle identifier(s).
            %
            %   Output: int array
            
            x = obj.data(7, :);
        end
         
        function x = channel(obj)
            %channel returns calibration channel indices.
            %
            %   Output: int array
            
            x = obj.data(8, :);
        end
        
        function print(obj)
            %print prints property data in human friendly format into the 
            %command window.
            
            label = {'Index:\t\t\t\t\t', 'Speed mode:\t\t\t\t', ...
                'Sync mode:\t\t\t\t', 'Integration time [sec]:\t', ...
                'Internal ND filter:\t\t', 'Lens status:\t\t\t', ...
                'External ND filter:\t\t', 'Measurement angle:\t\t', ...
                'Calibration channel:\t'};

            n = size(obj.data, 2);

            %convert int array to char arrays
            value = {1 : n, obj.speed.toChar, obj.sync.toChar, ...
                obj.integrationTime_sec, obj.internalND.toChar(), ...
                obj.lens.toChar, obj.externalND.toChar, ...
                obj.angle.toChar, obj.channel};

            if n == 1
                %plot list
                for i = 1 : 9
                    fprintf(sprintf('%s', label{i}));
                    if i == 4                                               %integration time
                        fprintf(sprintf('%.04f', value{i}));
                    elseif i == 1 || i == 9                                 %channel index
                        fprintf(sprintf('%d', value{i}));
                    else                                                    %char array identifier
                        fprintf(sprintf('%s', value{i}));
                    end
                    fprintf('\n');
                end
                
            else
                %get maximal length of char array identifier
                maxLength = max(numel(num2str(n)), 7);                      %maximal length of measurement number vs. integration time
                for i = [2:3 5:8]
                    for j = 1 : n
                        thisLength = numel(value{i}{j});
                        if maxLength < thisLength
                            maxLength = thisLength;
                        end
                    end
                end
                maxLength = ceil((maxLength + 2)/ 4) * 4;

                %plot table
                for i = 1 : 8
                    fprintf(sprintf('%s', label{i}));
                    if any(i == [1 4 9])
                        value{i} = num2cell(value{i});
                        if i == 4, f = '%.04f';
                        else, f = '%d';
                        end
                    else
                        f = '%s';
                    end
                    for j = 1 : n
                        thisLength = numel(num2str(value{i}{j}));
                        ntab = ceil((maxLength - thisLength) / 4);
                        fprintf(sprintf([f repmat('\t', [1 ntab])], ...
                            value{i}{j}));
                    end
                    fprintf('\n');
                end
            end
        end
    end
end

