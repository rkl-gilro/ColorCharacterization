function [name spectrum] = readAllSpectra(folder)

close all
figure, hold on

content = dir(folder);
name = {};
spectrum = {};
for i=3:numel(content)
    if isequal(content(i).name(end-3:end),'.png') || ...
       isequal(content(i).name(end-3:end),'.PNG')
        name{end+1} = content(i).name;
        bracket_open = find(name{end}=='[');
        bracket_close = find(name{end}==']');
        equal = find(name{end}=='=');
        wvlrange = str2num(name{end}(bracket_open(1):bracket_close(1)));
        amprange = str2num(name{end}(bracket_open(2):bracket_close(2)));
        channel = str2num(name{end}(equal(end)+1));
        spectrum{end+1} = readSpectrumFromImage([folder name{end}],wvlrange,amprange,channel);
        
        color = zeros(3,1);
        color(channel)=1;
        plot(spectrum{end}(:,1),spectrum{end}(:,2),'color',color);
        xlabel('nm'); ylabel('energy');
    end
end

legend(name);
