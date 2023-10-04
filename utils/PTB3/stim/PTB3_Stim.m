classdef (Abstract) PTB3_Stim < handle
    %PTB3_Stim is an abstract base class class for classes that encapsulate 
    %stimuli of psychophysical experiments. Its purpose is to define the 
    %abstract method makeTexture to force its implementation in all 
    %subclasses. Base class is handle.
    %
    %   abstract methods
    %       makeTexture     Returns PTB3_FrameBase array

    methods (Abstract)
        makeTexture(obj)
    end
end