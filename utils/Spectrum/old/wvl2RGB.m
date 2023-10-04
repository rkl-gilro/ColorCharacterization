function col = wvl2RGB(wvl)
    col = zeros(numel(wvl),3);
    for i = 1:numel(wvl)
        if wvl(i) >= 380 && wvl(i) < 440
            col(i,:) = [-(wvl(i) - 440) / (440 - 380) 0 1];
        elseif wvl(i) >= 440 && wvl(i) < 490
            col(i,:) = [0 (wvl(i) - 440) / (490 - 440) 1];
        elseif wvl(i) >= 490 && wvl(i) < 510
            col(i,:) = [0 1 -(wvl(i) - 510) / (510 - 490)];
        elseif wvl(i) >= 510 && wvl(i) < 580
            col(i,:) = [(wvl(i) - 510) / (580 - 510) 1 0];
        elseif wvl(i) >= 580 && wvl(i) < 645
            col(i,:) = [1 -(wvl(i) - 645) / (645 - 580) 0];
        elseif wvl(i) >= 645 && wvl(i) <= 780
            col(i,:) = [1 0 0];
        end
    end
end
