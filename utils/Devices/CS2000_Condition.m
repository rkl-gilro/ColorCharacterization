classdef CS2000_Condition
    %CS2000_Condition encapsulates all measurement conditions of the 
    %Konica Minolta CS-2000 that are necessary to fully reproduce the
    %instrument's settings.
    %
    %   properties
    %       speed               CS2000_Speed object
    %       sync                CS2000_Sync object
    %       lens                CS2000_Lens object
    %       externalND          CS2000_ExternalND object
    %       angle               CS2000_Angle object
    %       calib               CS2000_Calib object
    %
    %   methods
    %       CS2000_Condition    Constructor
    
    properties (GetAccess = public, SetAccess = private)
        speed
        sync
        lens
        externalND
        angle
        calib
    end
    
    methods
        function obj = CS2000_Condition(speed_, sync_, lens_, ...
                externalND_, angle_, calib_)
            %CS2000_Condition: Constructor.
            %
            %   Input:  CS2000_Speed object
            %           CS2000_Sync object
            %           CS2000_Lens object
            %           CS2000_ExternalND object
            %           CS2000_Angle object
            %           CS2000_Calib object
            %   Output: CS2000_Condition object

            if ~Misc.is(speed_, 'CS2000_Speed', 'scalar')
                error('First parameter must be a CS2000_Speed object.');
            elseif ~Misc.is(sync_, 'CS2000_Sync', 'scalar')
                error('Second parameter must be a CS2000_Sync object.');
            elseif ~Misc.is(lens_, 'CS2000_Lens', 'scalar')
                error('Third parameter must be a CS2000_Lens object.');
            elseif ~Misc.is(externalND_, 'CS2000_ExternalND', 'scalar')
                error(['Fourth parameter must be a CS2000_ExternalND ' ...
                    'object.']);
            elseif ~Misc.is(angle_, 'CS2000_Angle', 'scalar')
                error('Fifth parameter must be a CS2000_Angle object.');
            elseif ~Misc.is(calib_, 'CS2000_Calib', 'scalar')
                error('Sixth parameter must be a CS2000_Calib object.');
            end
            
            obj.speed = speed_;
            obj.sync = sync_;
            obj.lens = lens_;
            obj.externalND = externalND_;
            obj.angle = angle_;
            obj.calib = calib_;
        end
    end
end

