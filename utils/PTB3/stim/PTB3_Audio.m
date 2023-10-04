classdef PTB3_Audio < handle
    %PTB3_Audio encapsulates properties and methods to display audio with 
    %low latency via PTB3. Base class is handle.
    %
    %   properties
    %       iDev            int scalar (device index, machine specific)
    %       hDev            int scalar (device handle)
    %       hBuf            int scalar (buffer handle)
    %       wave            double array (waveform, dim: channel, time)
    %
    %   methods
    %       PTB3_Audio      Constructor
    %       make            Sets properties hDev and hBuf (call first)
    %       play            Returns float scalar (start time; non-blocking)
    %       stop            Stops playback
    %       close           Deletes buffer and closes audio device
    %       sampleRate      Returns float scalar (sample rate in Hz)
    %       duration_sec    Returns float scalar (duration of wave in sec)
    
    properties (GetAccess = public, SetAccess = private)
        iDev
        hDev
        hBuf
        wave
    end
    
    methods
        function obj = PTB3_Audio(iDev_, wave_)
            %PTB3_Audio: Constructor. Does not check if device index exists
            %so that object can be generated on a different machine. Call
            %PTB3_Audio.getValidDevices on the target machine to find the
            %valid device indices.
            %
            %   Input:  int scalar (audio device index)
            %           float array (waveform)
            %   Output: PTB3_Audio object
            
            if ~Misc.is(iDev_, 'int', 'scalar', {'>=', 0})
                error('First parameter must be a int scalar >= 0.');
            elseif ~Misc.is(wave_, 'float', [-1, 1], {'dim', 2})
                error(['Second parameter must be a float matrix in ' ...
                    '[-1, 1].']);
            end
            
            obj.iDev = iDev_;
            obj.wave = wave_;
        end
        
        function make(obj)
            %make opens the device (if not open) and sets property hDev, 
            %and creates the audio buffer with property wave and sets
            %property hBuf.
                       
            InitializePsychSound;                                           %initialize low latency: must happen before first PsychPortAudio call
            device = PsychPortAudio('GetDevices');
            if ~any(obj.iDev == [device.DeviceIndex])
                error(['Device with index %d wplays not found on this ' ...
                    'machine.'], obj.iDev);
            end

            %check if target device is already open
            i = 0;                                                          %running device index
            obj.hDev = [];                                                  %handle of target device
            search = true;                                                  %true = an(other) open device was found
            while search
                try
                    status = PsychPortAudio('GetStatus', i);
                    if status.OutDeviceIndex == obj.iDev
                        obj.hDev = i;                                       %set property hDev if device was found
                        search = false;
                    else
                        i = i + 1;
                    end
                catch
                    search = false;
                end
            end
            
            %open it if necessary and set property hDev (device handle)
            if isempty(obj.hDev)
                obj.hDev = PsychPortAudio('Open', obj.iDev);
            end
            
            %create buffer and set property hBuf with buffer handle
            obj.hBuf = PsychPortAudio('CreateBuffer', obj.hDev, obj.wave);
        end

        function t = play(obj, t)
            %play plays the sound at the given time (immediately per
            %default).
            %
            %   Input:  float scalar (targeted play time)
            %   Output: float scalar (actual play time)
            
            if nargin < 2, t = 0; end
            if ~Misc.is(t, 'float', 'scalar', '~isnan')
                error('Input must be a non-Nan float scalar.');
            end
            
            if isempty(obj.hDev)
                obj.make;
                warning(['Call make before calling play hte first ' ...
                    'time to reduce latency time.']);
            end
            
            PsychPortAudio('FillBuffer', obj.hDev, obj.hBuf);
            t = PsychPortAudio('Start', obj.hDev, [], t, 1);
        end
        
        function stop(obj)
            %stop stops the playback.
            
            if ~isempty(obj.hDev)
                PsychPortAudio('Stop', obj.hDev);
            else
                error(['Property hDev not defined, there is no ' ...
                    'running playback that could be stopped.']);
            end
        end
        
        function close(obj)
            %close tdeletes the buffer handle and closes the audio device.
            
            if ~isempty(obj.hDev)
                PsychPortAudio('DeleteBuffer', obj.hBuf);
                PsychPortAudio('Close', obj.hDev);
            else
                error(['Property hDev not defined, there is no ' ...
                    'audio device that could be closed.']);
            end
        end
        
        function x = sampleRate(obj)
            %sampleRate returns the sample rate in Hz.
            %
            %   Output: float scalar
            
            if isempty(obj.hDev), obj.make; end
            status = PsychPortAudio('GetStatus', obj.hDev);
            x = status.SampleRate;
        end
        
        function x = duration_sec(obj)
            %duration_sec returns the duration of property wave in seconds.
            %
            %   Output: float scalar
            
            x = size(obj.wave, 2) / obj.sampleRate;
        end
    end
    
    methods (Static)
        function x = getValidDevices
            %getValidDevices returns a struct array with all audio devices
            %that can be opened with PTB3. The structs contain field
            %DeviceIndex, which is the first argument of the constructor of
            %PTB3_Audio.
            %
            %   Output: Struct array
            
            InitializePsychSound;
            x = PsychPortAudio('GetDevices');
            n = numel(x);
            valid = false(1, n);
            for i = 1 : n
                try
                    h = PsychPortAudio('Open', x(i).DeviceIndex);
                    PsychPortAudio('Close', h);
                    valid(i) = true;
                catch 
                end
            end
            x = x(valid);
            
            fprintf('\nValid devices:\n')
            for i = 1 : sum(valid)
                fprintf('Index %d: %s\n', x(i).DeviceIndex, ...
                    x(i).DeviceName);
            end
        end
    end
end