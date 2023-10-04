classdef Spectrum < matlab.mixin.Copyable
    %Spectrum is a class to encapsulate electromagnetical spectra. 
    %
    %   properties
    %       wavelength      m x 1 float array
    %       value           m x n float array
    %
    %   public methods
    %       Spectrum        Constructor
    %       count           Returns int scalar (number of columns in value)
    %       setDomain       Crop and interpolate spectrum to meet the 
    %                       demanded wavelength domain
    %       interpolate     Interpolate spectrum with demanded step size
    %       crop            Crop spectrum to demanded wavelength range
    %       mean            Returns Spectrum array (mean)
    %       sd              Returns Spectrum array (standard deviation)
    %       range           Returns Spectrum array (range)
    %       lim             Returns Spectrum array (lower, upper bnd.)
    %       plot            Returns line handle (plots spectrum as line(s))
    %       plotArea        Returns line handle (plots spectrum as patch)
    %
    %   operators
    %       +               Works with arrays
    %       -               Works with arrays
    %       .*              Works with arrays
    %       ./              Works with arrays
    %
    %   static methods
    %       merge           Merges Spectrum array into one Spectrum object
    %       blackbody       Returns Spectrum object (blackbody spectrum for
    %                           a given wavelength array and temperature)   
    %       commonDomain    Crop and interpolate multiple spectra to get
    %                           equal wavelength range and bandwidth
    
    properties (GetAccess = public, SetAccess = protected)
        wavelength
        value                                                               %radiance, reflectance, etc
    end
    
    methods (Access = public)
        function obj = Spectrum(wavelength_, value_)
            %Spectrum: Constructor.
            %
            %   Input:  n x 1 float vector (wavelength [nm])
            %           n x k float matrix (value)
            %   Output: Spectrum object
            
            Spectrum.checkWavelength(wavelength_, 1);
            n = numel(wavelength_);
            if ~Misc.is(value_, 'float',  {'size', 1, n})
                error('Second parameter must be a %d x k float array.', n);
            end
            obj.wavelength = wavelength_(:);
            obj.value = value_;
        end
        
        function x = count(obj)
            %count returns the number of columns of property value.
            %
            %   Output: int array
            
            n = numel(obj);
            x = nan(1, n);
            for i = 1 : n
                x(i) = size(obj(i).value, 2);
            end
            x = reshape(x, size(obj));
        end
        
        function setDomain(obj, wavelength_, method)
            %setDomain crops and interpolates the spectrum. Works with 
            %arrays.
            %
            %   Input:  numeric array (central wvl of spectral bands)
            %           char array (interpolation method, def = linear)
            %   Output: Spectrum array

            if nargin < 3, method = 'linear'; end
            n = numel(obj);
            if n > 1
                for i = 1 : n
                    obj(i).setDomain(wavelength_, method);
                end
            else
                Spectrum.checkWavelength(wavelength_, 1);
                Spectrum.checkIpMethod(method, 2);

                obj.interpolate(1, method);
                obj.crop([min(wavelength_)  max(wavelength_)]);
                obj.interpolate(unique(diff(wavelength_(:))), method);
            end
        end
                
        function interpolate(obj, step, method)
            %interpolate interpolates the spectrum wiht the demanded step 
            %size and method. Works with arrays.
            %
            %   Input:  float scalar (wavelength step size [nm], def = 1)
            %           char array (interpolation method, def = linear)
            %   Output: Spectrum array
            
            if nargin < 3, method = 'linear'; end
            if nargin < 2, step = 1; end
            n = numel(obj);
            if n > 1
                for i = 1 : n
                    obj(i).interpolate(step, method);
                end
            else
                if ~Misc.is(step, 'float', 'pos', 'scalar')
                    error('First parameter must be a positive scalar.');
                else
                    Spectrum.checkIpMethod(method, 2);
                end
                if ~isequal(unique(diff(obj.wavelength)), step)
                    wavelength_ip = (ceil(obj.wavelength(1)) : step : ...
                        floor(obj.wavelength(end)))';
                    obj.value = interp1(obj.wavelength, obj.value, ...
                        wavelength_ip, method);
                    obj.wavelength = wavelength_ip;
                end
            end
        end

        function crop(obj, wvlInterval)
            %crop crops the spectrum to the demanded wavelength range. 
            %Works with arrays.
            %
            %   Input:  float interval (wavelength [min, max])
            %   Output: Spectrum array
    
            n = numel(obj);
            if n > 1
                for i = 1 : n
                    obj(i).crop(wvlInterval);
                end
            else
                if ~Misc.is(wvlInterval, 'float', 'interval')
                    error('Second parameter must be a float interval.');
                end
                if ~Misc.is(wvlInterval, Math.lim(obj.wavelength))
                    warning('Input interval exceeds wavelengths.')
                end

                valid = obj.wavelength >= wvlInterval(1) & ...
                    obj.wavelength <= wvlInterval(2);
                obj.wavelength = obj.wavelength(valid);
                obj.value = obj.value(valid, :);
            end
        end
        
        function x = range(obj)
            %range returns the range of property value. Works with arrays.
            %
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                x = obj.processArray('range');
            else
                x = Spectrum(obj.wavelength, range(obj.value, 2));
            end
        end
                
        function x = lim(obj)
            %lim returns the lower and upper limits of property value.
            %Works with arrays.
            %
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                x = obj.processArray('lim');
            else
                x = Spectrum(obj.wavelength, ...
                    [min(obj.value, [], 2), max(obj.value, [], 2)]);
            end
        end
        
        function x = mean(obj)
            %mean returns the average of property value. Works with arrays.
            %
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                x = obj.processArray('mean');
            else
                x = Spectrum(obj.wavelength, mean(obj.value, 2));
            end
        end

        function x = sd(obj)
            %sd returns the standard deviation of property value. Works
            %with arrays.
            %
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                x = obj.processArray('sd');
            else
                x = Spectrum(obj.wavelength, std(obj.value, 0, 2));
            end
        end
        
        function h = plot(obj, col)
            %plot plots a spectrum. Works with arrays.
            %
            %   Input:  n x 3 float (color)
            %   Output: matlab.graphics.chart.primitive.Line array
            
            n = numel(obj);
            if nargin == 1
                col = lines; 
                col = col(1 : n, :); 
            end
            if ~Misc.is(col, 'float', [0, 1], {'size', [n, 3]})                
                error('Input must be a %d x 3 float array in [0 1].', n);
            end
            
            Misc.dockedFigure; 
            h = matlab.graphics.chart.primitive.Line.empty;
            lim_wvl = [inf, -inf];
            for i = 1 : n
                h = [h, plot(obj(i).wavelength, obj(i).value)];             %#ok
                if i == 1 && i < n, hold on, end
                lim_wvl = [min(lim_wvl(1), obj(i).wavelength(1)), ...
                    max(lim_wvl(2), obj(i).wavelength(end))];
            end
            xlabel('wavelength [nm]');    
            xlim(lim_wvl);
            box on
        end
        
        function h = plotArea(obj, col)
            %plotArea plots the area between the minimum and maximum values
            %for each wavelength. If only a single measurement is 
            %contained, a mountain plot will be shown. Works with arrays.
            %
            %   Output: matlab.graphics.primitive.Patch object
            
            n = numel(obj);
            if n > 1
                if nargin == 1
                    col = lines; 
                    col = col(1 : n, :); 
                end
                if ~Misc.is(col, 'float', [0, 1], {'size', [n, 3]})
                    error(['Input must be a %d x 3 float array in ' ...
                        '[0 1].'], n);
                end
                h = matlab.graphics.primitive.Patch.empty;
                for i = 1 : n
                    h(i) = obj(i).plotArea(col(i, :));
                    hold on
                end
            else
                if nargin == 1, col = lines(1); end
                if ~Misc.is(col, 'float', [0, 1], {'size', [n, 3]})
                    error('Input must be a 1 x 3 float array in [0 1].');
                end
                if obj.count == 1
                    tmp = [obj.value, zeros(size(obj.value, 1), 1)];
                elseif obj.count > 2
                    tmp = obj.lim.value;
                end
                h = patch(obj.wavelength([1 : end end : -1 : 1]), ...
                    [tmp(:, 1); tmp(end : -1 : 1, 2)], ...
                    col, 'LineStyle', 'none','FaceAlpha', .5);
                xlabel('wavelength [nm]');
            end
            axis tight
            box on
        end
        
        function y = plus(obj, x)
            %plus implements addition, i.e., operator + can be used.
            %Operates on a copy. Works with arrays. 
            %
            %   Input:  float scalar OR Spectrum object
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                y = obj.processArray('plus', x);
            else
                [a, b] = obj.getOperands(x);
                y = Spectrum(a.wavelength, a.value + b);
            end
        end
        
        function y = minus(obj, x)
            %minus implements subtraction, i.e., operator - can be used. 
            %Operates on a copy. Works with arrays. 
            %
            %   Input:  float scalar OR Spectrum object
            %   Output: Spectrum array
            
            n = numel(obj);
            if n > 1
                y = obj.processArray('minus', x);
            else
                [a, b] = obj.getOperands(x);
                y = Spectrum(a.wavelength, a.value - b);
            end
        end
        
        function y = times(obj, x)
            %times implements element-wise multiplication, i.e., operator 
            %.* can be used. Operates on a copy. Works with arrays. 
            %
            %   Input:  float scalar OR Spectrum object
            
            n = numel(obj);
            if n > 1
                y = obj.processArray('times', x);
            else
                [a, b] = obj.getOperands(x);
                y = Spectrum(a.wavelength, a.value .* b);
            end
        end
        
        function y = rdivide(obj, x)
            %rdivide implements element-wise division, i.e., operator ./ 
            %can be used. Operates on a copy. Works with arrays. 
            %
            %   Input:  float scalar OR Spectrum object
            
            n = numel(obj);
            if n > 1
                y = obj.processArray('rdivide', x);
            else
                [a, b] = obj.getOperands(x);
                y = Spectrum(a.wavelength, a.value ./ b);
            end
        end
    end
    
    methods (Access = private)
        function y = processArray(obj, fun, x)                              %#ok
            %processArray executes a given function name for a Spectrum
            %array.
            %
            %   Input:  char array (function name)
            %           arbitrary parameter (optional)
            %   Output: Spectrum array
            
            if nargin == 3, param = 'x'; 
            else, param = ''; 
            end
            dim = size(obj);
            n = numel(obj);
            if n > 1
                y = Spectrum.empty;
                for i = 1 : n
                    y(i) = eval(sprintf('obj(i).%s(%s)', fun, param));
                end
                y = reshape(y, dim);
            end
        end
        
        function [a, b] = getOperands(obj, x)
            %getOperands returns operands for operators +, -, .*, and ./.
            %
            %   Input:  float scalar OR Spectrum object (right operand)
            %   Output: Spectrum object (left operand)
            %           float scalar OR array (right operand)

            if ~((Misc.is(x, 'Spectrum', 'scalar') && x.count == 1) || ...
                    Misc.is(x, 'float', 'scalar'))
                error(['Input must be a float scalar or a Spectrum ' ...
                    'object with one measurement.']);
            end

            a(1) = obj.copy;                                                %copy to prevent that object is altered by commonDomain
            if isa(x, 'Spectrum')
                a(2) = x.copy;
                if ~isequal(a(1).wavelength, a(2).wavelength)
                    warning('Spectrum:getOperands:wvlNotEqual', ...
                        'Wavelengths are not equal.');
                    a = Spectrum.commonDomain(a);
                end
                b = repmat(a(2).value, [1, a(1).count]);
                a = a(1);
            else
                b = x;
            end
        end
    end
    
    methods (Static)
        function x = merge(obj)
            %merge merges a Spectrum array into a single Spectrum object.
            %Changes property wavelength if it differs between objects.
            %
            %   Input:  Spectrum array
            %   Output: Spectrum object
            
            if numel(obj) > 1
                obj = Spectrum.commonDomain(obj);
                value_ = obj(1).value;
                for i = 2 : numel(obj)
                    value_(:, end + (1 : obj(i).count)) = obj(i).value;
                end
                x = Spectrum(obj(1).wavelength, value_);
            else
                x = obj;
            end
        end
        
        function x = blackbody(wavelength_, T)
            %blackbody returns the blackbody spectrum for a given 
            %wavelength array and temperature.
            %
            %   Input:  numeric array (wavelength [nm])
            %           float scalar (temperature [deg K])
            %   Output: Spectrum object
            
            Spectrum.checkWavelength(wavelength_);
            if Misc.is(T, 'float', 'scalar', [-273.15, Inf])
                error(['Second parameter must be a float scalar >= ' ...
                    '-273.15.']);
            end
            wavelength_ = wavelength_ * 10^-9;
            h = 6.626070040 * 1e-34;
            c = 299792458;
            k_B = 1.38064852 * 1e-23;
            tmp = 2 * h * c ^ 2 ./ ...
                ((exp(h * c ./ (wvl * k_B * T)) - 1) .* wvl .^ 5);          %Plancks law = black body radiation
            x = Spectrum(wavelength_, tmp ./ sum(tmp));
        end

        function spectrum = commonDomain(spectrum, method)
            %commonDomain crops and interpolates spectra so that the same
            %wavelength range and bandwidth is used.
            %
            %   Input:  Spectrum array
            %           char array (nearest, linear (def.), cubic, spline)
            %   Output: Spectrum array
            
            validMethod = {'nearest', 'linear', 'cubic', 'spline'};
            if nargin < 2, method = validMethod{2}; end
            
            if ~Misc.is(spectrum, 'Spectrum', '~isempty')
                error(['First parameter must be a non-empty Spectrum ' ...
                    'array.']);
            else
                Spectrum.checkIpMethod(method, 2);
            end
            
            n = numel(spectrum);
            if n == 1, return; end
            
            %find common range
            minwvl = spectrum(1).wavelength(1);
            maxwvl = spectrum(1).wavelength(end);
            for i = 2 : n
                minwvl = max(spectrum(i).wavelength(1), minwvl);
                maxwvl = min(spectrum(i).wavelength(end), maxwvl);
            end
            
            %interpolation necessity
            ip_necessary = false;
            wvl = cell(1, n);
            for i = 1 : n
                valid = spectrum(i).wavelength >= minwvl & ...
                    spectrum(i).wavelength <= maxwvl;
                wvl{i} = spectrum(i).wavelength(valid);
                if i > 1 && ~isequal(wvl{1}, wvl{i})
                    ip_necessary = true;
                    break
                end
            end
            
            %interpolation step
            if ip_necessary
                %minimal wavelength step size
                step = inf;
                for i = 1 : n
                    tmp = unique(diff(wvl{i}));
                    if tmp < step, step = tmp; end                     
                end

                %maximally possible step size
                ip_step = 1;
                cancelled = false;
                for j = 2 : step
                    for i = 1 : n
                        if ~all(ismember(wvl{i}, (minwvl : j : maxwvl)'))
                            cancelled = true;
                            break;
                        end
                    end
                    if ~cancelled, ip_step = j;
                    else, break; end
                end
            end
                
            for i = 1 : n
                if ip_necessary
                   spectrum(i).interpolate(ip_step, method);
                end
                spectrum(i).crop([minwvl maxwvl]);
            end
        end
    end
    
    methods (Static, Hidden)
        function checkWavelength(x, i)
            %checkWavelength throws an error if input is not a numeric
            %1-dim vector with equidistant step size.
            %
            %   Input:  float array (wavelength [nm])
            %           int scalar (num. of parameter in calling function)
            
            if nargin == 1, c = 'Input';
            else, c = sprintf('%s parameter', Misc.ordinalNumber(i));
            end
            
            if ~(Misc.is(x, 'float', {'dim', 2}, '~isnan', 'pos') &&  ...
                    (any(size(x) == 1) && numel(x) == 1 || ...
                    (x(2) > x(1) && numel(unique(diff(x))) == 1)))
                error(['%s must be a positive 1-dim float scalar or ' ...
                    'an array with equidistant, ascending values.'], c);
            end
        end
        
        function checkIpMethod(x, i)
            %checkIpMethod thorws an error if the given sting does not
            %represent a supported interpolation method.
            %
            %   Input:  char array (interpolation method)
            %           int scalar (num. of parameter in calling function)
                        
            if nargin == 1, c = 'Input';
            else, c = sprintf('%s parameter', Misc.ordinalNumber(i));
            end
            
            ipm = {'nearest', 'linear', 'cubic', 'spline'};
            if ~Misc.isInCell(x, ipm)
                error('%s must be %s.', c, Misc.cellToList(ipm));
            end
        end
    end
end
