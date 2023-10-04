classdef Peak
    %Peak encapsulates a spectral peak of en electromagnetic 
    %spectrum.
    %
    %   properties
    %       max         float scalar (max. spectral value)
    %       fwhm        float scalar (full width at half maximum)
    %       center      float scalar (center of FWHM interval)
    %       lb          float scalar (lower boundary of FWHM interval)
    %       ub          float scalar (upper boundary of FWHM interval)
    %   
    %   methods
    %       Peak        Constructor
    
    properties (GetAccess = public, SetAccess = private)
        max
        fwhm
        center
        lb
        ub
    end
    
    
    methods
        function obj = Peak(max_, lb_, ub_)
            %Peak: Constructor.
            %
            %   Input:  float scalar (full width at half maximum)
            %           float scalar (lower boundary at half intensity)
            %           float scalar (wavelength at maximum)

            if ~Misc.is(max_, 'float', 'scalar', 'pos')
                error('Second parameter must be a positive float scalar.');
            elseif ~Misc.is(lb_, 'float', 'scalar', 'pos', {'<', max_})
                error(['Second parameter must be a positive float ' ...
                    'scalar < %f.'], max_);
            elseif ~Misc.is(ub_, 'float', 'scalar', 'pos', {'>' max_})
                error(['Third parameter must be a positive float ' ...
                    'scalar > %f.'], max_);
            end
            
            obj.max = max_;
            obj.fwhm = ub_ - lb_;
            obj.center = (lb_ + ub_) / 2;
            obj.lb = lb_;
            obj.ub = ub_;
        end
    end
    
    methods (Static)
        function obj = fromSpectrum(spectrum, minValue)
            %fromSpectrum returns a Peak array from a Spectrum 
            %object.
            %
            %   Input:  Spectrum object
            %           float scalar (minimal FWHM, def = 5)
            %           float scalar (minimal value at peak, def = .9)
            %   Output: SpectralPeal array
            
            if nargin < 2, minValue = .9; end
            if ~Misc.is(spectrum, 'Spectrum', 'scalar')
                error('First parameter must be a Spectrum object.');
            elseif ~Misc.is(minValue, 'float', 'scalar', 'pos')
                error('Second parameter must be a positive float scalar.');
            end
            
            obj = Peak.empty;
            v = [spectrum.mean.value];
            wvl = spectrum.wavelength;
            valid = true(size(v));
            hasPeak = true;
            while hasPeak
                [vmax, imax] = max(v(valid));
                hasPeak = vmax >= minValue;
                if hasPeak
                    imax = find(cumsum(valid) == imax, 1, 'first');
                    ilb = find(v(1 : imax - 1) <= vmax / 2, 1, 'last');
                    iub = find(v(imax + 1 : end) <= vmax / 2, 1, 'first');
                    if ~isempty(ilb) && ~isempty(iub)
                        iip = ilb + [0, 1];
                        lb = interp1(v(iip), wvl(iip), .5 * vmax);          %lower boundary
                        iip = imax + iub + [-1 0];
                        ub = interp1(v(iip), wvl(iip), .5 * vmax);          %upper boundary
                        obj(end + 1) = Peak(wvl(imax), lb, ub);             %#ok
                        valid(ilb : imax + iub) = false;
                    else
                        hasPeak = false;
                    end
                end
            end
            
            %sort peaks by center in ascending order
            if numel(obj) > 1
                [~, isort] = sort([obj.center]);
                obj = obj(isort);
            end
        end
    end
end
    
    