classdef CS2000 < handle
    %CS2000 provides a Matlab interface to communicate with the Konica 
    %Minolta CS-2000. All functions are based on the Communication 
    %Specifications Rev. 1.00 from March 13, 2009 (KMSE CS-A0E3-01.02E).
    %
    %
    %   properties 
    %       s                       char array (serial port)
    %       device                  CS2000_Device object (device info)
    %
    %
    %   public methods 
    %       CS2000                  Constructor. Establishes connection,
    %                                   reads device info, disables meas.
    %                                   switch, powers off display
    %       open                    Establishes connection
    %       close                   Disconnects device
    %       isResponding            Returns logical scalar
    %
    %       measure                 Returns CS2000_Measurement object 
    %                                   (triggers a measurement and reads 
    %                                   measurement data)
    %       measureFilter           Returns Filter object (measures filter 
    %                                   transmission)
    %
    %       enableSwitch            Enables measurement switch
    %       disableSwitch           Disables measurement switch
    %
    %       enableRemote            Enables Remote Mode
    %       disableRemote           Disables Remote Mode
    %
    %       getCondition            Returns CS2000_Condition object
    %       setCondition            Writes measuring conditions
    %       getSync                 Returns CS2000_Sync object
    %       setSync                 Writes synchronization settings
    %       getSpeed                Returns CS2000_Speed object
    %       setSpeed                Writes speed mode settings
    %       getLens                 Returns CS2000_Lens object
    %       setLens                 Writes close-up lens settings
    %       getExternalND           Returns CS2000_ExternalND object
    %       setExternalND           Writes external ND filter settings
    %       getAngle                Returns CS2000_Angle object
    %
    %       getSample               Returns CS2000_Measurement object
    %                                   (sample = meas. stored on device)
    %       deleteSample            Deletes sample
    %       deleteAllSamples        Deletes all samples
    %       saveAsSample            Saves last measurement as sample
    %
    %       getChannel              Returns int scalar (index of 
    %                                   calibration channel)
    %       setChannel              Sets index of calibration channel
    %       getCalib                Returns CS2000_Calib object
    %       setCalib                Sets calibration data
    %       deleteCalib             Deletes calibration data
    %
    %       displayOn               Powers on display backlight
    %       displayOff              Powers off display backlight
    %
    %       getDevice               Returns CS2000_Device object (info)
    %       getTimeFactoryCalib     Returns DateTime object (factory cal.)
    %       getNameFactoryCalib     Returns char array (factory cal. date)
    %
    %       send                    Returns cell array of char arrays 
    %                                   (sends command, returns response)
    %
    %
    %   static methods
    %       getWavelength           Returns n x 1 float (wavelength in nm)
    %
    %
    %   Call the help of individual functions for details on the input and
    %   output parameters, and check the manual and communication
    %   specification document for background information.
    %
    %
    %   Example 
    %       cs2000 = CS2000;
    %       x = cs2000.measure;
    %       x.radiance.plot;
    
    
    properties (GetAccess = public, SetAccess = private)
        s
        device
    end
    
    
    methods (Access = public)
        function obj = CS2000(port)
            %CS2000: Constructor. Establishes connection, disables
            %measurement switch, turns off display, reads device info. 
            %Reports if external ND filter, close-up lens, or user 
            %calibration is set.
            %
            %   Input:  char array with communcation port id (optional)
            %   Output: CS2000 object
            
            if nargin < 1
                if ispc, port = 'COM3';
                elseif ismac || isunix, port = '/dev/tty.usbmodem1421';
                end
            end
            
            fprintf('Initializing CS2000... ');
            obj.open(port);
            obj.enableRemote;
            obj.disableSwitch;
            obj.displayOff;
            fprintf('done.\n');

            obj.device = obj.getDevice;

            obj.device.print;
            fprintf(['External ND filter:\t\t%s\n' ...
                'Close-up lens:\t\t\t%s\n' ...
                'Calibration channel:\t%d ' ...
                '(0: factory, 1-10: user)\n'], ...
                obj.getExternalND.char, obj.getLens.char, obj.getChannel);
        end
        
        function open(obj, port)
            %open establishes the USB connection to the device.
            %
            %   Input:  char array with communication port id

            Misc.closeSerial(port);

            obj.s = serial(port);
            obj.s.BaudRate = 9600;
            obj.s.Terminator = 'LF';
            obj.s.InputBufferSize = 1024;
            obj.s.BytesAvailableFcnMode = 'terminator';
            obj.s.Timeout = 600;                                            %maximum measurement time of CS2000 is 240 sec.
            
            fopen(obj.s);
        end
        
        function close(obj)
            %close disconnects device.

            obj.displayOn;
            obj.enableSwitch;
            obj.disableRemote;
            fclose(obj.s);
        end
        
        function x = isResponding(obj)
            %isResponding returns true if CS2000 is responding.
            %
            %   Output: logical scalar
            
            try
                obj.getDevice;
                x = true;
            catch
                x = false;
            end
        end
        
        
        %MEASURE
        function x = measure(obj, num, name)
            %measure triggers a measurement and reads measurement data.
            %
            %   Input:  int scalar (number of measurement repetitons)
            %           char array (name)
            %   Output: CS2000_Measurement object
            
            if nargin < 3, name = ''; end
            if nargin < 2, num = 1; end                                     %number of measurements
            
            if ~Misc.is(num, 'pos', 'int', 'scalar')
                error('First parameter must be a positive int scalar.');
            elseif ~ischar(name)
                error('Second parameter must be a char array.');
            end
            
            %measure
            c = '';
            condition = obj.getCondition;                                   %read full measuring conditions
            fprintf('Measuring... ');
            
            for i = 1 : num
                if num > 1
                    fprintf(repmat('\b', [1, numel(c)]));
                    c = sprintf('%d of %d', i, num);
                    fprintf(c);
                end
                t(i) = DateTime(clock);                                     %#ok
                str2double(obj.send('MEAS,1'));
                tmp = cell2mat(strread(fscanf(obj.s), '%s', ...
                    'delimiter', ','));                                     %#ok
                if ~isequal(tmp, 'OK00')
                    if isempty(tmp)
                        [~, warnID] = lastwarn;
                        if isequal(warnID, ...
                                'MATLAB:serial:fscanf:unsuccessfulRead')
                            error('CS2000:TimeOut', ...
                                'Time out while waiting for response.');
                        else
                            error('CS2000:NoResponse', ...
                                'No response from device.');
                        end
                    else
                        error('CS2000:UnknownResponse', ...
                            'Unknown response %s.', tmp);
                    end
                end

                radiance(i) = obj.getRadiance;                              %#ok. Read spectrum
                color(i) = obj.getColor;                                    %#ok. Read color data
                report(i) = obj.getReport;                                  %#ok. Read measurement conditions
            end
            
            fprintf([repmat('\b', [1, numel(c)]) 'done.\n']);
            
            %construct output
            x = CS2000_Measurement(name, t, condition, obj.device, ...
                report, radiance, color);
        end
        
        function filter = measureFilter(obj)
            %measureFilter measures a filter's transmission spectrum.
            %
            %   Output: Filter object
            
            name = input('Filter name: ', 's');
            manufacturer = input('Manufacturer: ', 's');
            n = Menu.basic(['\nTo estimate the filter spectrum, a ' ...
                'target is measured without and with filter.\nNumber ' ...
                'of measurements per condition'], 'prompt', ': ', ...
                'default', 20);
            
            fprintf('\n');
            input('Press Enter to measure WITHOUT filter.', 's');
            a = obj.measure(n);
            input('Press Enter to measure WITH filter.', 's');
            b = obj.measure(n);
            filter = Filter(name, manufacturer, b.radiance.mean.divide(...
                a.radiance.mean));
            
            %plot
            Misc.dockedFigure;
            subplot(131)
            hold on
            a.radiance.plot;
            ylabel('radiance');
            title('target without filter');
            
            subplot(132)
            hold on
            b.radiance.plot;
            ylabel('radiance');
            title('target with filter');
            
            subplot(133)
            hold on
            filter.transmission.plot;
            ylabel('transmission');
            ylim([0 1]);
            title(sprintf('Filter %s (%s)', filter.name, ...
                filter.manufacturer));
            
            %save
            if Menu.basic('\nSave filter spectrum', 'prompt', '? ', ...
                    'response', 'yn', 'default', 'y')
                fprintf('Select folder: ');
                folder = Menu.folder(Misc.getPath('Filter.m'));

                filename = Menu.basic('\nFilename', 'prompt', ': ', ...
                    'default', sprintf('%s_%s', ...
                    filter.manufacturer, filter.name));
                tmp = sprintf('%s/%s.mat', folder, filename);
                
                fprintf('Saving %s... ', tmp);
                save(tmp, 'filter');
                fprintf('done.\n');                
            end
        end

        
        %MEASUREMENT SWITCH
        function enableSwitch(obj)
            obj.send('MSWE,1');                                             %enable Measurement Switch
        end

        function disableSwitch(obj)
            obj.send('MSWE,0');                                             %disable Measurement Switch
        end
        
        
        %REMOTE MODE
        function enableRemote(obj)
            obj.send('RMTS,1');
        end
        
        function disableRemote(obj)
            obj.send('RMTS,0');
        end        
        
        
        %CONDITIONS
        function x = getCondition(obj)
            %getCondition reads measuring conditions.
            %
            %   Output: CS2000_Condition object
            
            x = CS2000_Condition(obj.getSpeed, obj.getSync, ...
                obj.getLens, obj.getExternalND, obj.getAngle, ...
                obj.getCalib);                                              %if called after measurement (wo applying changes to settings in between) the get functions retrieve more information (except of getSpeed, where integrationTime_sec can be rounded to seconds for certain modi)
        end
        
        function setCondition(obj, x)
            %setCondition sets measuring conditions.
            %
            %   Input:  CS2000_Condition object
            
            if ~Misc.is(x, 'CS2000_Condition', 'scalar')
                error('Input must be a CS2000_Condition object.');
            end

            %check measurement angle first
            while ~isequal(obj.getAngle, x.angle)
                input(sprintf(['\nSet measurement angle to %s and ' ...
                    'press Enter.'], x.angle.char), 's');
            end
            
            original = obj.getCondition;
            if ~isequal(x, original)
                if ~isequal(x.speed, original.speed)
                    obj.setSpeed(x.speed);
                end
                if ~isequal(x.sync, original.sync)
                    obj.setSync(x.sync);
                end
                if ~isequal(x.lens, original.lens)
                    obj.setLens(x.lens);
                end
                if ~isequal(x.externalND, original.externalND)
                    obj.setExternalND(x.externalND);
                end
                if ~isequal(x.calib, original.calib)
                    obj.setCalib(x.calib);
                end
                fprintf('Condition was set successfully.\n');
            else
                fprintf('Condition is up-to-date.\n');
            end
        end
        
        function x = getSync(obj)
            %getSync reads currently set synchronization mode from
            %instrument.
            %
            %   Output: CS200_Sync object
            
            tmp = str2double(obj.send('SCMR'));
            if tmp(1) == 1, x = CS2000_Sync(tmp(1), tmp(2) / 100);          %1 = internal sync -> freq is defined as well
            else, x = CS2000_Sync(tmp);
            end
        end

        function setSync(obj, x)
            %setSync sets the synchronization mode. 
            %
            %   Input:  CS2000_Sync object
            
            if ~Misc.is(x, 'CS2000_Sync', 'scalar')
                error('Input must be a CS2000_Sync object.');
            end
            
            if x.int == 1
                obj.send(sprintf('SCMS,%d,%d', ...
                    x.int, round(x.freq_Hz * 100)));
            else
                obj.send(sprintf('SCMS,%d', x.int));
            end
        end

        function x = getSpeed(obj)
            %getSpeed reads currently set speed mode from instrument.
            %
            %   Output: CS2000_Speed object
            
            tmp = str2double(obj.send('SPMR'));
            if any(tmp(1) == 2:4)
                x = CS2000_Speed(tmp(1), CS2000_InternalND(tmp(3)), ...
                    tmp(2));
            else
                x = CS2000_Speed(tmp(1), CS2000_InternalND(tmp(2)));
            end 
        end

        function setSpeed(obj, x)
            %setSpeed sets the speed mode. 
            %
            %   Input:  CS2000_Speed object
            
            if ~Misc.is(x, 'CS2000_Speed', 'scalar')
                error('Input must be a CS2000_Speed object.');
            end

            if any(x.int == 2:4)
                if x.int == 3
                    obj.send(sprintf('SPMS,%d,%09d,%d', x.int, ...
                        x.integrationTime_sec * 1e6, x.internalND.int));
                else                    
                    obj.send(sprintf('SPMS,%d,%02d,%d', x.int, ...
                        x.integrationTime_sec, x.internalND.int));
                end
            else
                obj.send(sprintf('SPMS,%d,%d', x.int, x.internalND.int));
            end
        end
        
        function x = getLens(obj)
            %getLens reads close-up lens status and spectral compensation 
            %factors.
            %
            %   Output: CS2000_Lens object

            value = str2double(obj.send('LNSR'));
            
            if value ~= 0
                wavelength = CS2000.getWavelength;
                n = numel(wavelength);
                tmp = nan(n, 3);

                for i = 1 : 3                                               %angle
                    for j = 1 : numel(wavelength)
                        tmp(i, j) = Math.hexToSingle(obj.send(sprintf(...
                            'ALFR%d,%03d', i - 1, j - 1)));                 %read compensation factors
                    end
                    compensation(i) = Spectrum(wavelength, tmp);            %#ok
                end
            end
            
            if value == 0, x = CS2000_Lens(value);
            else, x = CS2000_Lens(value, compensation);
            end
        end
        
        function setLens(obj, x)
            %setLens sets status and spectral compensation factors of 
            %close-up lens.
            %
            %   Input:  CS2000_Lens object

            if ~Misc.is(x, 'CS2000_Lens', 'scalar')
                error('Input must be a CS2000_Lens object.');
            end

            obj.send(sprintf('LNSS,%d', x.int));                            %set lens status
            
            if x.int ~= 0
                for i = 1 : 3                                               %angle
                    fac = Math.singleToHex(x.compensation(i).value);
                    for j = 1 : numel(x.wavelength)
                        obj.send(sprintf('ALFS%d,%03d,%s', i - 1, ...
                            j - 1, fac(j, :)));                             %set compensation factor
                    end
                end
            end            
        end
        
        function x = getExternalND(obj)
            %getExternalND reads if and which external ND filter is set to
            %be used.
            %
            %   Output: CS2000_ExternalND object

            value = str2double(obj.send('NDFR'));                           %read external ND filter identifier
            
            if value ~= 0
                wavelength = CS2000.getWavelength;
                n = numel(wavelength);
                tmp = nan(n, 3);

                for i = 1 : 3                                               %angle
                    for j = 1 : numel(wavelength)
                        tmp(j, i) = Math.hexToSingle(obj.send(sprintf(...
                            'NFCR%d,%d,%03d', i - 1, value, j - 1)));       %read compensation factors
                    end
                    compensation(i) = Spectrum(wavelength, tmp);            %#ok
                end
            end
            
            if value == 0
                x = CS2000_ExternalND(value);
            else
                x = CS2000_ExternalND(value, compensation);
            end
        end

        function setExternalND(obj, x)
            %setExternalND sets which external ND filter is to be used (if
            %any).
            %
            %   Input:  CS2000_ExternalND object

            if ~Misc.is(x, 'CS2000_ExternalND', 'scalar')
                error('Input must be of CS2000_ExternalND object.');
            end
            
            obj.send('NDFS,%d', x.int);                                     %set status

            if x.int ~= 0
                for i = 1 : 3                                               %angle
                    fac = Math.singleToHex(x.compensation(i).value);
                    for j = 1 : numel(x.wavelength)
                        obj.send(sprintf('NFCS%d,%d,%03d,%s', i - 1, ...
                            x.int, j - 1, fac(j, :)));                      %set compensation factor
                    end
                end
            end
        end
        
        function x = getAngle(obj)
            %getAngle reads the adjusted measurement angle.
            %
            %   Output: CS2000_Angle object

            x = CS2000_Angle(str2double(obj.send('STSR')));
        end
            
  
        %STORED DATA
        function x = getSample(obj, idx)
            %getSample reads a sample (stored measurement) from the
            %CS-2000.
            %
            %   Input:  int array (sample indices in [0 99])
            %   Output: CS2000_Measurement object
            
            n = numel(idx);
            if ~Misc.is(idx, 'int', [0, 99])
                error('Input must be an int array in [0 99].');
            end
            
            for i = 1 : n
                fprintf('Sample %d\n', idx(i));
                report = obj.getReport(idx(i));
                radiance = obj.getRadiance(idx(i));
                color = obj.getColor(idx(i));
                x(i) = CS2000_Sample(idx(i), obj.device, report, ...
                    radiance, color);                                       %#ok
                if i < n, fprintf('\n'); end
            end
        end
        
        function deleteSample(obj, idx)
            %getSample deletes stored measurement from the CS-2000's 
            %memory.
            %
            %   Input:  int scalar (sample index in [0 99])
            
            if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                error('Input must be an int scalar in [0 99].');
            end
            obj.send(sprintf('STDD,%02d', idx));
        end
        
        function deleteAllSamples(obj)
            %getSample deletes all measurements from the CS-2000's memory.
            
            obj.send('STAD');
        end

        function saveAsSample(obj, idx)
            %getSample saves last measurement in instrument memory.
            %
            %   Input:  int scalar (sample index in [0 99])

            if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                error('Input must be an int scalar in [0 99].');
            end
            obj.send(sprintf('STDS,%02d', idx));
        end
        
        
        %CALIBRATION
        function x = getChannel(obj)
            %getChannel reads the calibration channel index.
            %
            %   Output: int scalar (index of calibration channel; 
            %               0 = factory calibration)
            
            x = str2double(obj.send('UCCR'));
        end
        
        function setChannel(obj, x)
            %setChannel sets the calibration channel index. 
            %
            %   Input:  int scalar (index of calibration channel, [0 10], 
            %               0 corresponds to the factory calibration)
            
            if ~Misc.is(x, 'int', 'scalar', [0, 10])
                error('Input must be an int scalar in [0 10].');
            end
            obj.send(sprintf('UCCS,%02d', x));
        end
        
        function x = getCalib(obj, channel)
            %getCalib reads calibration data of specified calibration
            %channel.
            %
            %   Input:  int scalar (channel index in [0 10])
            %   Output: CS2000_Calib object

            if nargin < 2, channel = obj.getChannel; end
            if ~Misc.is(channel, 'int', 'scalar', [0, 10])
                error('Input must be an int scalar in [0 10].');
            end
            
            wavelength = CS2000.getWavelength;
            n = numel(wavelength);
            
            if channel == 0
                x = CS2000_Calib(channel, obj.getFactoryCalibName);
            else
                band = nan(n, 1);
                level = nan(n, 1);
                for i = 1 : n
                    band(i) = Math.hexToSingle(obj.send(sprintf(...
                        'UCPR,0,%02d,%03d', channel, i - 1)));
                    level(i) = Math.hexToSingle(obj.send(sprintf(...
                        'UCPR,1,%02d,%03d', channel, i - 1)));
                end

                name = cell2mat(obj.send(sprintf('UCPR,2,%02d', channel)));
                while numel(name) > 0 && name(end) == ' '
                    name = name(1 : end - 1); 
                end
                x = CS2000_Calib(channel, name, ...
                    Spectrum(wavelength, band), ...
                    Spectrum(wavelength, level));
            end
        end

        function setCalib(obj, calib)
            %setCalib sets a calibration (data and channel).
            %
            %   Input:  CS2000_Calib object

            if ~Misc.is(calib, 'CS2000_Calib', 'scalar')
                error('Input must be a CS2000_Calib object.');
            end
            
            if calib.channel == 0
                if ~isequal(calib.name, obj.getFactoryCalibName)
                    error('Factory calib name does not match.');            %factory calib does not provide band / level data. Thus, only the channel is set. Different factory calibs can be distingusihed by the name of the factory calib, which is equivalent to the factory calib's date
                end
                fprintf('Writing factory calibration %s... ', calib.name);
                obj.setChannel(calib.channel);
            else
                fprintf('Writing user calibration %s... ', calib.name);
                field = {'band', 'level'};
                n = numel(CS2000.getWavelength);
                        
                for j = 1 : 2
                    tmp = Math.singleToHex(calib.(field{j}).value);
                    for i = 1 : n
                        obj.send(sprintf('UCPS,%d,%02d,%03d,%s', ...
                            j - 1, calib.channel, i - 1, tmp(i, :)));
                    end
                end
                name = [calib.name ...
                    repmat(' ', [1, 10 - numel(calib.name)])];              %if less than 10 chars, add spaces to name
                obj.send(sprintf('UCPS,2,%02d,%s', calib.channel, name));   %write name
                obj.send('UCPS,3');
                obj.setChannel(calib.channel);                              %set channnel (= calibration is active)
            end
            fprintf('done.\n');
        end    
        
        function deleteCalib(obj, x)
            %deleteCalib deletes the user calibration with the given index
            %from the CS2000's memory. 
            %
            %   Input:  int scalar (channel index in [1 10])
            
            if ~Misc.is(x, 'int', 'scalar', [1, 10])
                error('First parameter must be an int scalar in [1 10].');  %channel 0 contains factory calibration, which cannot be deleted
            end            
            obj.send('UCCD,%d', x); 
        end
        
        function calibFilter(obj, channel, filter)
            %calibFilter calibrates the CS2000 for an external filter.
            %
            %   Input:  int scalar (calibration channel, optional)
            %           Filter object (optional)
            
            if nargin < 2
               channel = Menu.basic('Calibration channel (1-9): ', ...
                   'response', {'interval', [1, 9]});
            end
            if nargin < 3, filter = obj.measureFilter; end
            
            if ~Misc.is(channel, 'int', 'scalar', [0, 10])
                error('First parameter must be an int scalar in [0 10].');
            elseif ~Misc.is(filter, 'Filter', 'scalar')
                error('Second parameter must be a Filter object.');
            end
            
            def = filter.name;
            if numel(def) > 10, def = def(1 : 10); end
            name = Menu.basic('Calibration name (max. 10 char)', ...
                'prompt', ': ', 'default', def);
            wvl = CS2000.getWavelength;
            calib = CS2000_Calib(channel, name, Spectrum(wvl, wvl), ...
                Spectrum(wvl, 1 ./ filter.transmission.value));
            
            %save dialog
            if Menu.basic('Save calibration', 'prompt', '? ', ...
                    'response', 'yn', 'default', 'y')
                fprintf('Select folder: ');
                folder = Menu.folder(Misc.getPath('CS2000.m'));
                
                filename = Menu.basic('\nFilename', 'prompt', ': ', ...
                    'default', calib.name);
                tmp = sprintf('%s/%s.mat', folder, filename);
                
                fprintf('Saving %s... ', tmp);
                save(tmp, 'calib');
                fprintf('done.\n');
            end            
            
            obj.setCalib(calib);
        end
        
        
            
        %DISPLAY BACKLIGHT
        function displayOn(obj)
            %displayOn powers on the instrument display.
            
            obj.send('BALS,1,1');
        end
        
        function displayOff(obj)
            %displayOff powers off the instrument display.
            
            obj.send('BALS,0,0');
        end
        
        
        %INFO
        function x = getDevice(obj)
            %getDevice reads the device information.
            %
            %   Output: CS2000_Device object
            
            tmp = obj.send('IDDR');
            x = CS2000_Device(...
                tmp{1}(1 : find(tmp{1} == ' ', 1, 'first') - 1), ...
                str2double(tmp{2}), str2double(tmp{3}), ...
                obj.getTimeFactoryCalib);
        end
        
        function x = getTimeFactoryCalib(obj)
            %getDateFactoryCalib reads date and time of factory 
            %calibration (calibration channel 0).
            %
            %   Output: DateTime object
            
            tmp = obj.send('DTCR');
            x = DateTime(str2double({tmp{1}(1 : 4), tmp{1}(5 : 6) ...
                tmp{1}(7 : 8), tmp{2}(1 : 2), tmp{2}(3 : 4), ...
                tmp{2}(5 : 6)}));
        end

        function x = getFactoryCalibName(obj)
            %getFactoryCalibName returns date of factory calib as char 
            %array (YYYY/MM/DD).
            %
            %   Output: char array
            
            time = obj.getTimeFactoryCalib;
            x = sprintf('%d/%d/%d', time.vec(1 : 3));
        end                

        
        %SEND COMMAND AND READ RESPONSE
        function data = send(obj, command)
            %send sends a command and reads the response.
            %
            %   Input:  char array (command)
            %   Output: cell array (of char arrays)
            
            if nargin == 2, fprintf(obj.s, command); end
            data = strread(fscanf(obj.s), '%s', 'delimiter', ',');          %#ok
            CS2000.errorCheck(data{1});
            data = data(2 : end);
        end
    end

    
    methods (Static)
        function x = getWavelength
            %getWavelength returns a column vector that corresponds to the
            %wavelength domain of the CS2000.
            %
            %   Output: n x 1 float (wavelength in nm)
            
            x = (380 : 780)';
        end
    end
    
    
    methods (Access = private)
        function x = getReport(obj, idx)
            %getReport reads report about conditions of last or a
            %stored measurement.
            %
            %   Input:  int scalar (sample index, optional)
            %   Output: CS2000_Report object
            
            if nargin == 1
                command = 'MEDR,0,0,1';
            else
                if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                    error('Input must be an int scalar in [0 99].');
                end
                command = sprintf('STDR,%02d,0,0,1', idx);
            end
            
            tmp = str2double(obj.send(command));
            tmp(3) = tmp(3) * 1e-6;                                         %convert integration time to sec
            x = CS2000_Report(tmp);
        end
        
        function x = getRadiance(obj, idx)
            %getRadiance reads radiance data from instrument, either from
            %the last measurement (default), or from a stored measurement.
            %
            %   Input:  int scalar (sample index, optional)
            %   Output: Spectrum object
            
            if nargin == 1
                command = 'MEDR,1,1';
            else 
                if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                    error('Input must be an int scalar in [0 99].');
                end
                command = sprintf('STDR,%02d,1,1', idx);
            end
                
            wavelength = CS2000.getWavelength;
            value = nan(numel(wavelength), 1);
            iwvl = 0;
            for i = 1 : 4
                tmp = Math.hexToSingle(...
                    obj.send(sprintf('%s,%d', command, i)));
                value(iwvl + (1 : numel(tmp))) = tmp;
                iwvl = iwvl + numel(tmp);
            end
            x = Spectrum(wavelength, value);
        end
        
        function x = getColor(obj, idx)
            %getColor reads colorimetric data from instrument, either from
            %the last measurement (default), or from a stored measurement.
            %
            %   Input:  int scalar (sample index, optional)
            %   Output: CS2000_Color object

            if nargin == 1
                command = 'MEDR,2,1,0';
            else 
                if ~Misc.is(idx, 'int', 'scalar', [0, 99])
                    error('Input must be an int scalar in [0 99].');
                end
                command = sprintf('STDR,%02d,2,1,00', idx);
            end

            x = CS2000_Color(Math.hexToSingle(obj.send(command)));
        end
    end
      
    methods (Static, Hidden)
        function errorCheck(strErrorCode)
            %errorCheck translates an device error code into an matlab
            %warning or error.
            %
            %   Input:  char array (device error code)
            
            id = [0, 2, 5, 10, 17, 20, 30, 51, 52, 71, 81, 82, 83, 84, 99];
            ER.id = ...
                {'CS2000:InvalCommand', ...
                'CS2000:MeasInProgress', ...
                'CS2000:NoCompVal', ...
                'CS2000:OverMeasRange', ...
                'CS2000:InvalParam', ...
                'CS2000:NoData', ...
                'CS2000:MemError', ...
                'CS2000:TempAbnorm', ...
                'CS2000:TempAbnorm', ...
                'CS2000:SyncRange', ...
                'CS2000:ShutterAbnorm', ...
                'CS2000:NdMalfunc', ...
                'CS2000:MeasAngle', ...
                'CS2000:FanAbnorm', ...
                'CS2000:ProgAbnorm', ...
                'CS2000:UnknownError'};
            ER.msg = ...
                {'Invalid command string received.', ...
                'Measurement in progress.', ...
                'No compensation values.', ...
                'Over measurement range.', ...
                'Invalid Parameter.', ...
                'No data available.', ...
                'Instrument internal memory error.', ...
                'Temperature abnormality.', ...
                'Temperature abnormality.', ...
                'Outside synchronization signal range.', ...
                'Shutter operation abnormality.', ...
                'Internal ND filter operation malfunction.', ...
                'Measurement angle abnormality. Check the knob.', ...
                'Cooling fan abnormality.', ...
                'Program abnormality', ...
                'An unknown error occured.'};
            
            this_id = str2double(strErrorCode(3 : 4));
            
            if isequal(strErrorCode(1 : 2), 'ER')
                [found, i] = ismember(this_id, id);
                if found, error(ER.id{i}, ER.msg{i});
                else, error(ER.id{end}, ER.msg{end});
                end
            elseif ~isequal(strErrorCode(1 : 2), 'OK')
                error(ER.id{end}, ER.msg{end});
            end
        end
    end
end
