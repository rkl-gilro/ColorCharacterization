%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Calibration new data setup Unreal
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('Calibration_UnrealStandard_Varjo_23_03_2023.mat');
save_calibration = 'Calibration_UnrealStandard_Varjo_23_03_2023_xyz.mat';

save_filename = 'Calibration_UnrealStandard_Varjo_23_03_2023_dE.mat';

%% Comment or uncomment accordingly (HTC 5:255)
x = (0:5:255)./255;
% x = (5:5:255)./255;

%% Standard: it couldn't get measurements from 13 50 54 61 63 RGB values ...

primaries(1, :) = [Red];
primaries(2, :) = [Green];
primaries(3, :) = [Blue];
primaries(4, :) = [Gray];

white = [White]; 


figure
plotChromaticity();hold on
cols = {'r', 'g', 'b', 'k'};
for i=1:size(primaries, 1)
    
    for j=1:size(primaries, 2)
        aux0 = [primaries(i, j).color.xyY];
        aux1 = [primaries(i, j).color.XYZ];
        Ys(j, i) = aux0(3) ;
        xs(j, i) = aux0(1) ;
        ys(j, i) = aux0(2) ;
        Xs(j, i) = aux1(1) ;
        Zs(j, i) = aux1(3) ;
        SPECTRA((i-1)*size(primaries, 2) + j,:) = primaries(i, j).radiance.value;
    end
    plot(xs(:, i), ys(:, i), [cols{i}, 'o'], 'MarkerSize', 12, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, 'LineWidth', .3); %
end

yticks([0 0.2 0.4 0.6 0.8])
xticks([0 0.2 0.4 0.6 0.8])

set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
grid on
set(gcf,'renderer','Painters');


figure
for i=1:size(primaries, 1)
    subplot(1, 4, i)
    
    for j=1:size(primaries, 2)
        
        plot(380:780,primaries(i, j).radiance.value, cols{i}); hold on
        
    end
    set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
    grid on
    set(gcf,'renderer','Painters');
end

%% Estimated gamma curves for each channel
starts=[1 30 1; 1 30 1;1 5 1];
for ch = 1:3
    y = Ys(:,ch)';
    
    pos = round(length(y)/3);
    pos1 = round(length(y)/5);
    
    for k = 1:length(y)-1
        d(k) = (y(k+1)-y(k))/(x(k+1)-x(k));
    end
   
    for k = 1:length(y)-1
        if d(k) < 1
            p3 = x(k+1);
            break
        end
    end
    
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    lb = [double(y(1)), 1, 0];
    ub = [double(y(1)), 250, 1];
    
    options = optimoptions(@fmincon,'Display', 'none');
    
    starts(ch, :) = double([y(1) (y(pos)-y(pos1))/(x(pos)-x(pos1)) p3]);
    x0 = starts(ch, :);
    fun = @(p) line2min(p,double(x),double(y));
    PS(:,ch) = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
    
    
end


cols={'r','g','b','k'};
linew = 3;
marksize = 10;
name_channels = {'Red', 'Green', 'Blue'};
figure;
for ch=1:3

    subplot(1,2,1)
    hold on
    
    plot(x,Ys(:, ch),...
        [cols{ch} 'o'],'markerFaceColor',cols{ch}, 'markersize', marksize);
    
    plot(x,linefun(PS(:,ch), x),[cols{ch} '-'],'LineWidth',linew);
    
    text(x(end-10), (PS(2,ch)*x(end-1).^PS(1,ch)/1.3), name_channels{ch}, ...
        'FontSize', 30, 'fontname','TeXGyreTermes')
    box off
    leg = legend({'Measured', 'Estimated'}, 'Location','northwest', 'FontSize',30,'Color',[0 0 0]);
    set(leg,'Box','off')
    
    xlabel('Normalized Intensity Values','FontSize',15)
    ylabel('Luminance (cd/m^{2})','FontSize',15)
    
    set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
    set(gcf,'renderer','Painters');
end

subplot(1,2,2)
plot(x, sum([Ys(:, 1) Ys(:, 2) Ys(:, 3)],2), 'k--','LineWidth',linew);hold on
plot(x, Ys(:, 4), 'ko','markerFaceColor','k','markersize', marksize, ...
     'DisplayName', char('Additivity'));
 text(x(end-10), (PS(2,ch)*x(end-1).^PS(1,ch)/1.3), 'Achromatic', ...
        'FontSize', 30, 'fontname','TeXGyreTermes')
leg = legend({'Additivity', 'Measured'}, 'Location','northwest', 'FontSize',30,'Color',[1. 1. 1.]);
set(leg,'Box','off')
box off
xlabel('Normalized Intensity Values','FontSize',15)
ylabel('Luminance (cd/m^{2})','FontSize',15)
set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
set(gcf,'renderer','Painters');


starts=[1 30 1; 1 30 1;0 5 1];
% startsC=cat(3,starts,starts,[1 30 1; 0 20 .8;0 150 1]);
COLOR=cat(3,Xs,Ys,Zs);

for co = 1:3
    for ch = 1:4
        if  ch < 4
            
            y=COLOR(:,ch,co);
            
            pos = round(length(y)/3);
            pos1 = round(length(y)/5);
            
            for k = 1:length(y)-1
                d(k) = (y(k+1)-y(k))/(x(k+1)-x(k));
            end
           
            for k = 1:length(y)-1
                if d(k) < 1
                    p3 = x(k+1);
                    break
                end
            end
            A = [];
            b = [];
            Aeq = [];
            beq = [];
            
            lb = [double(y(1)), .01, 0];
            ub = [double(y(1)), 250, 1];
            
            options = optimoptions(@fmincon,'Display', 'none');
            
            startsC(ch,:,co) = double([y(1) (y(pos)-y(pos1))/(x(pos)-x(pos1)) p3]);
            
            x0 = startsC(ch,:,co);

            fun = @(p) line2min(p, double(x), double(y));
            PS_XYZ(:,ch,co) = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        end
        
    end
end


figure;
cols={'r','g','b','k'};
for co = 1:3
    for ch = 1:4
        if  ch < 4
            subplot(3,4,ch+(co-1)*4)
            
            y=COLOR(:,ch,co);
            
            plot(x,COLOR(:,ch,co),[cols{ch} 'o'],'linewidth',2);hold on
            plot(x,linefun(PS_XYZ(:,ch,co),x),[cols{ch} '--'],'LineWidth',2);hold on
        end
        
    end
end

save(save_calibration, 'PS_XYZ');
%% Perform the validation using the calibration matrix and gamma values
% LOOK AT TEST COLORS

load PredefinedRGB.mat
%(1:27, :)
RGBStest = [PredefinedRGB./255]; %  [rand; medidas./255]; % 1:27 for Standard!!!
aux  = [Validation_rand]; %  [M_rand M_val]; %

[XYZ, xyY] = mtRGB2XYZ(RGBStest, save_calibration);
[XYZwhite, xyYwhite] = mtRGB2XYZ([1 1 1], save_calibration);
for i=1:length(aux)
    XYZmeas(i, :) = aux(i).color.XYZ;
end

xyYmeas = XYZToxyY(XYZmeas')';

%% Plot the results
%% NOTE for
figure;plotChromaticity();hold on
% plot(xyY([1:5, 7:31 , 33:end],1),xyY([1:5, 7:31 , 33:end],2),'bo','MarkerSize',10,'LineWidth',2);
% plot(xyYmeas([1:5, 7:31 , 33:end],1),xyYmeas([1:5, 7:31 , 33:end],2),'kx','markersize',12,'linewidth',2)
plot(xyY(:,1),xyY(:,2),'bo','MarkerSize',10,'LineWidth',2);
plot(xyYmeas(:,1),xyYmeas(:,2),'kx','markersize',12,'linewidth',2)
set(gca,'FontSize',15,'LineWidth',2)
box off
xlabel('x','FontSize',15)
ylabel('y','FontSize',15)


%% Compute deltae2000
lab_meas = xyz2lab(XYZmeas, 'whitepoint', ...
    white.color.XYZ'); % ./max(ValoresXYZ(3*N+1, :))
lab_est  = xyz2lab(XYZ,     'whitepoint', ...
    XYZwhite); % ./max(XYZ(1, :))
dE = deltaE00(lab_meas', lab_est');
dENoCalibration = deltaE00(lab_meas', rgb2lab(PredefinedRGB./255,"WhitePoint",[1 1 1],"ColorSpace","linear-rgb")');

% disp(dE);

figure;
msize = 20;
for i=1:length(dE)
    if ~(i == 6 || i == 32)
        plot(i, dE(i), 'o', 'color', RGBStest(i, :), ...
            'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    end
end
plot(1:length(dE), ones(1, length(dE)), 'k--');
xlabel('Colours','FontSize',15)
ylabel('DeltaE00','FontSize',15)
ylim([0 5])
ind = find(dE > 1);


msize=15;
figure;
subplot 131;
for i = 2:size(lab_est, 1)
    plot(lab_est(i, 2), lab_est(i, 3), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 2), lab_meas(i, 3), 'kx', 'markersize', msize);hold on
    xlabel('a*','FontSize',15)
    ylabel('b*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);lab_meas(:, 2)])...
    min([lab_est(:, 3); lab_meas(:, 3)]) max([lab_meas(:, 3);lab_est(:, 3)])])

subplot 132;
for i = 2:size(lab_est, 1)
    plot(lab_est(i, 2), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 2), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('a*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);lab_meas(:, 2)])...
    min([lab_est(:, 1); lab_meas(:, 1)]) max([lab_meas(:, 1);lab_est(:, 1)])])

subplot 133;
for i = 2:size(lab_est, 1)
    plot(lab_est(i, 3), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 3), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('b*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 3); lab_meas(:, 3)]) max([lab_est(:, 3);lab_meas(:, 3)])...
    min([lab_est(:, 1); lab_meas(:, 1)]) max([lab_meas(:, 1);lab_est(:, 1)])])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot only dE bigger than 1
radii = 1;
figure;
subplot 131;
for i0 = 1:length(ind)
    i = ind(i0);
    %     plot(lab_est(i, 2), lab_est(i, 3), 'o', 'color', RGBStest(i, :), ...
    %         'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    viscircles([lab_est(i, 2), lab_est(i, 3)],radii,'Color',RGBStest(i, :));...
        hold on
    
    plot(lab_meas(i, 2), lab_meas(i, 3), 'kx', 'markersize', msize);hold on
    xlabel('a*','FontSize',15)
    ylabel('b*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);lab_meas(:, 2)])...
    min([lab_est(:, 3); lab_meas(:, 3)]) max([lab_meas(:, 3);lab_est(:, 3)])])

subplot 132;
for i0 = 1:length(ind)
    i = ind(i0);
    %     plot(lab_est(i, 2), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
    %         'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    viscircles([lab_est(i, 2), lab_est(i, 1)],radii,'Color',RGBStest(i, :));...
        hold on
    plot(lab_meas(i, 2), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('a*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);lab_meas(:, 2)])...
    min([lab_est(:, 1); lab_meas(:, 1)]) max([lab_meas(:, 1);lab_est(:, 1)])])

subplot 133;
for i0 = 1:length(ind)
    i = ind(i0);
    viscircles([lab_est(i, 3), lab_est(i, 1)],radii,'Color',RGBStest(i, :));...
        hold on
    %     plot(lab_est(i, 3), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
    %         'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 3), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('b*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 3); lab_meas(:, 3)]) max([lab_est(:, 3);lab_meas(:, 3)])...
    min([lab_est(:, 1); lab_meas(:, 1)]) max([lab_meas(:, 1);lab_est(:, 1)])])


if ~isempty(save_filename)
    save(save_filename, 'PS_XYZ', 'dE', 'lab_meas', 'lab_est');
end

%% Display errors and estimated parameters
PS_XYZ
[mean(dE) median(dE) max(dE)]
