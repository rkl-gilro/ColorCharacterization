classdef CMF < ColorFunc
    %CMF encapsulates color matching functions.
    %
    %   inherited properties
    %       name            Name of color matching function (file)
    %       spectrum        Spectrum object
    %
    %   methods
    %       CMF             Constructor
    %
    %   inherited methods
    %       getFilename     Returns char array (filename of data source)
    %       isValidName     Returns logical scalar (true = file exists)
    %       getValidName    Returns valid values for property name
    %       getAbsorption   Returns m x n float array (absorption rates)
    %
    %   inherited static methods
    %       readSpectrum    Returns Spectrum (read from csv file)
    
    methods
        function obj = CMF(name_)
            %CMF: Constructor.
            %
            %   Input:  char array (name)
            %   Output: CMF object
            
            if nargin == 0, obj.init;
            else, obj.init(name_);
            end
        end
        
        function plot(obj)
            %plot plots property spectrum.
            
            h = obj.spectrum.plot;
            ylabel('tristimulus value');
            legend(h, {'X' 'Y' 'Z'});
        end        
    end
end
