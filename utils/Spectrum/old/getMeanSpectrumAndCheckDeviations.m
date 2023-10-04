function [mean_spectrum mean_t] = ...
    getMeanSpectrumAndCheckDeviations(measurements,name)
%helper funtion that computes mean spectra and collects the scling weight
%of the single measurements, for optional display, in order to identify
%faulty measurements

wvl             = measurements(1).wvl;
nwvl            = numel(wvl);
nmeasurements   = numel(measurements); 
mean_spectrum   = nan(nwvl,nmeasurements);
mean_t          = nan(1,nmeasurements);
scalars         = cell(1,nmeasurements);

for i = 1:nmeasurements
    mean_spectrum(:,i) = mean(measurements(i).spectrum,2);
    if nargout==2, mean_t(i) = mean(measurements(i).t,2); end
    if all(~isnan(mean_spectrum(:,i)))
        scalars{i} = mean_spectrum(:,i) \ measurements(i).spectrum;
    else
        scalars{i} = nan(1,size(measurements(i).spectrum,2));
    end
end

if nargin==2
    figure('Color',[1 1 1],'Name','Weights of single measurements');
    plot([1 size(mean_spectrum,2)],[1 1],'r');
    hold on
    for i = 1:nmeasurements
        plot(i,scalars{i},'.');
    end
    xlim([1 nmeasurements]);
    xlabel('no. measurement');
    ylabel('weight')
    title(name);
end
