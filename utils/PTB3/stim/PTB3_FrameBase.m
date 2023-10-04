classdef (Abstract) PTB3_FrameBase < handle
    %PTB3_FrameBase is an abstract base class for classes PTB3_Frame and 
    %PTB3_Sequence.
    %
    %   properties
    %       duration_sec    float scalar (duration in sec)
    %
    %   abstract methods
    %       draw            Draws object
    
    properties (GetAccess = public, SetAccess = protected)
        duration_sec
    end
    
    methods
        draw(obj)
    end
end