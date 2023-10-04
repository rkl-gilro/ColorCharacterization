function testTex
%testTEx tests how longit takes to create textures for the tetrachromatic
%setup online.
Screen('Preference', 'SkipSyncTests', 1);
load(FileBase.appendToRoot('tetra\current\calibration\stim\data\28-Jun-2020_20-30-14\TetraFlicker_L15_28-Jun-2020_20-30-14.mat'));
nFrame = 60;                                                                %60 Hz is the video fps (projector is 120 Hz, which is achieved by using two color channels per (monochromatic) projector, which are shown successively)
phase = linspace(0, 2 * pi, nFrame * 2);
c = zeros(4, 120); 
c(4, :) = sin(phase) * .15;
spatial = obj.getSpatialCalib;
obj.load('stimNonComp');

try
    Screen('Preference', 'SkipSyncTests', 1);
    w = Screen('OpenWindow', 0);
    
%     n = 100;
%     t = nan(2, n);
%     tex = nan(4, nFrame);
%     for i = 1 : n
%         t0 = GetSecs;
%         rgb = obj.getGray(true, c);
%         t(1, i) = GetSecs - t0;
%         tFrame = 1/59;
%         for iProj = 1 : 4
%             for j = 1 : nFrame
%                 tex(iProj, j) = Screen('MakeTexture', w, ...
%                     rgb{iProj}(:, :, :, j), 0, 4);
%             end
%         end
%         t(2, i) = GetSecs - (t0 + t(1, i));
%         Screen('Close', tex);
%     end

    n = 10;
    t = nan(2, n);
    for i = 1 : n
        t0 = GetSecs;
        rgb = obj.getGray(true, c);
        t(1, i) = GetSecs - t0;
        screen = zeros(1, 4);
        tFrame = 1/59;
        frame = PTB3_Frame.empty;
        tex = PTB3_Texture.empty;
        for j = 1 : nFrame
            for iProj = 1 : 4
                tex(iProj) = PTB3_Texture(screen(iProj), ...
                    rgb{iProj}(:, :, :, j), spatial.rect(iProj));
            end
            frame(j) = PTB3_Frame(tex, tFrame);
        end
        frame.make;
        t(2, i) = GetSecs - (t0 + t(1, i));
        if i < n, frame.close; end
    end


%     n = 1;
%     t = nan(4, n);
%     for i = 1 : n
%         t0 = GetSecs;
%         rgb = obj.getGray(true, c);
%         t(1, i) = GetSecs - t0;
%         screen = zeros(1, 4);
%         tFrame = 1/59;
%         seq = PTB3_Sequence(screen, rgb, tFrame, spatial.rect);
%         seq.make;
%         t(2, i) = GetSecs - (t0 + t(1, i));6
%         if i < n, seq.close; end
%     end
    
    m = mean(t, 2) * 1e3;
    sd = std(t, [], 2) * 1e3; 
    fprintf(['RGB computation: %.3f +- %.3f msec\n' ...
        'Texture generation: %.3f +- %.3f msec\n'], ...
        m(1), sd(1), m(2), sd(2));
    Misc.dockedFigure;
    for i = 1 : 2, subplot(1, 3, i), hist(t(i, :), 10); end
    subplot(1, 3, 3), plot(t' * 1e3); hold on
    ylabel('msec');
    

frame.draw;    
    
% seq.draw;    
    
    %show channels successiveley as sanity test
%     for iProj = 1 : 4
%         Screen('FillRect', w(iProj).h, [0, 0, 0, 0]);
% Screen('FillRect', w, [0, 0, 0, 0]);
%     end
%     Screen('Flip', w(1).h, 0, [], [], 1);
% Screen('Flip', w, 0, [], [], 1);
%     for i = 1 : nFrame
%         for iProj = 1 : 4
% %             Screen('DrawTexture', w(iProj).h, tex(iProj, i), [], ...
% %                 obj.spectralCalib.spatialCalib.rect(iProj).xywh);
% Screen('DrawTexture', w, tex(iProj, i), [], ...
%     obj.spectralCalib.spatialCalib.rect(iProj).xywh);
%         end
%         Screen('Flip', w(1).h, 0, [], [], 1);
% Screen('Flip', w, 0, [], [], 1);
%     end    
    Screen('CloseAll');
catch ME
    Screen('CloseAll');
    rethrow(ME)
end

%with Dell XPS required time for MakeTexture is about 750 ms
end