function [peak_wvl peak_spectrum] = find_peaks(varargin)

[wvl spectrum polarity minPeakWidth relAmp thr] = setParam(varargin);

n = numel(wvl);
if isequal(polarity,'max')
    [peak_spectrum ipeak] = max(spectrum);
elseif isequal(polarity,'min')
    [peak_spectrum ipeak] = min(spectrum);
end

halfWidth = round(minPeakWidth/2);

if ipeak>halfWidth && ipeak<n-halfWidth && ...
   peak_spectrum > thr && ...
   ((isequal(polarity,'max') && ...
     peak_spectrum >= relAmp * spectrum(ipeak-halfWidth) && ...
     peak_spectrum >= relAmp * spectrum(ipeak+halfWidth)) || ...
    (isequal(polarity,'min') && ...
     peak_spectrum <= relAmp * spectrum(ipeak-halfWidth) && ...
     peak_spectrum <= relAmp * spectrum(ipeak+halfWidth)))

    peak_wvl = wvl(ipeak);
        
else
    peak_wvl = [];
    peak_spectrum = [];
end

i1 = 1:ipeak-1;
i2 = ipeak+1:n;

if numel(i1)>2
    [peak_wvl1 peak_spectrum1] = ...
        find_peaks('wvl',wvl(i1),...
                   'spectrum',spectrum(i1),...
                   'polarity',polarity,...
                   'minPeakWidth',minPeakWidth,...
                   'relAmp',relAmp,...
                   'thr',thr);
    peak_wvl = [peak_wvl peak_wvl1];
    peak_spectrum = [peak_spectrum peak_spectrum1];
end
if numel(i2)>2
    [peak_wvl2 peak_spectrum2] = ...
        find_peaks('wvl',wvl(i2),...
                   'spectrum',spectrum(i2),...
                   'polarity',polarity,...
                   'minPeakWidth',minPeakWidth,...
                   'relAmp',relAmp,...
                   'thr',thr);
    peak_wvl = [peak_wvl peak_wvl2];
    peak_spectrum = [peak_spectrum peak_spectrum2];
end
        
end


%set parameters
function [wvl spectrum polarity minPeakWidth relAmp thr] = setParam(x)
    for i = 1:2:length(x)
        switch x{i}
            case 'wvl'
                wvl = x{i+1};
            case 'spectrum'
                spectrum = x{i+1};
            case 'polarity'
               polarity = x{i+1};
            case 'minPeakWidth'
               minPeakWidth = x{i+1};
            case 'relAmp'
               relAmp = x{i+1};
            case 'thr'
               thr = x{i+1};
            otherwise
                disp(sprintf('Warning! Unknown parameter %s.',x{i}));
        end
    end

    %checks, sanity tests, defaults
    if ~exist('wvl','var')
        error('Error! Wavelengths "wvl" not specified!');
    end
    
    if ~exist('spectrum','var')
        error('Error! Spectral data "spectrum" not specified!');
    end

    if size(spectrum,1)~=numel(wvl)
        Error(['Error! Number of rows in spectrum does not match ' ...
               'number of elemnts in wvl.']);
    end
    
    if ~exist('polarity','var')
        polarity = 'max';
        disp('Polarity was set to max (i.e., looking for maxima).');
    elseif ~(isequal(polarity,'max') || isequal(polarity,'min'))
        disp('Invalid "polarity" parameter (use "min" or "max").');
    end

    if ~exist('minPeakWidth','var')
        minPeakWidth = 15;
        disp(sprintf(['Minimal peak width "minPeakWidth" ' ...
                      'was set to %d.'],minPeakWidth));
    end

    if ~exist('relAmp','var')
        if isequal(polarity,'max')
            relAmp = 1.01;
        else
            relAmp = 0.99;
        end
        disp(sprintf(['Relative amplitude "relAmp" was set ' ...
                      'to %.3f.'], relAmp));
    else
        if isequal(polarity,'max') && relAmp<=1
            error(['Error! Searching for maxima, but relative ' ...
                    'amplitude >= 1.']);
        elseif isequal(polarity,'min') && relAmp>=1
            error(['Error! Searching for minima, but relative ' ...
                    'amplitude <= 1.']);
        end
    end
    
    if ~exist('thr','var')
        prc = 10;
        thr = prctile(spectrum,prc);
        disp(sprintf('Threshold "thr" was set to %f (percentile %d).',...
                     thr,prc));
    end
    

end