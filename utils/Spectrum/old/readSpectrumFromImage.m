function spectrum = readSpectrumFromImage(filename, wvlrange, amprange, channel, flag_log_wvl, flag_log_amp, flag_plot, type)
    if nargin<5, flag_log_wvl  = false;  end
    if nargin<6, flag_log_amp  = false;  end
    if nargin<7, flag_plot     = false;  end
    if nargin<8, type          = 'line'; end
    
    %extract color channel
    I = double(imread(filename));
    I = I(:,:,channel)-sum(I(:,:,(1:3)~=channel),3);
    I(I<0) = 0;
    
    amp = nan(1,size(I,2));
    if isequal(type,'line')
        for i=1:size(I,2), amp(i) = mean(find(I(:,i)>0)); end
    elseif isequal(type,'bar')
        for i=1:size(I,2)
            tmp = find(I(:,i)>0,1,'first'); 
            if isempty(tmp)
                amp(i) = NaN;
            else
                amp(i) = tmp;
            end
        end
    else
        error('Error! Unknown graph type. Choose line or bar.');
    end
    
    amp = (size(I,1)-amp)/size(I,1)*(amprange(2)-amprange(1))+amprange(1);

    if flag_log_amp
        amp = exp(amp);
    end

    if flag_log_wvl
        wvl = exp(linspace(log(wvlrange(1)), log(wvlrange(2)), size(I,2)));
    else
        wvl = linspace(wvlrange(1), wvlrange(2), size(I,2));
    end
    
    spectrum = [wvlrange(1):wvlrange(2); ...
                interp1(wvl,amp,wvlrange(1):wvlrange(2),'linear')]';
    
    %get nan intervals
    valid = ~isnan(spectrum);
    nans = [];
    j = 1;
    for i = 1:size(spectrum,1)-1
        if valid(i,2) && ~valid(i+1,2)
            nans(j,1) = i;
        elseif ~isempty(nans) && ~valid(i,2) && valid(i+1,2)
            nans(j,2) = i+1;
            j = j+1;
        end
    end
    if numel(nans)>1
        if nans(end,2)==0, nans = nans(1:end-1,:); end

        %fill nans with linearly interpolated values
        for i=1:size(nans,1)
            spectrum(nans(i,1):nans(i,2),2) = ...
                linspace(spectrum(nans(i,1),2),...
                         spectrum(nans(i,2),2),...
                         diff(nans(i,:))+1);
        end
    end    

    if flag_plot
        close all
        figure, hold on
        plot(spectrum(:,1),spectrum(:,2));
        xlabel('nm'); ylabel('energy');
        title(filename); 
        
        %mark interpolated values
        if numel(nans)>1
            hold on
            for i=1:size(nans,1)
                plot(spectrum(nans(i,1)+1:nans(i,2)-1,1),...
                     spectrum(nans(i,1)+1:nans(i,2)-1,2),'r');
            end
        end
    end
end