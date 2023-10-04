%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Calibration new data setup Unity Unlit
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('Calibration_UnityUnlit_CS2000_Pimax_30_03_2023.mat');
save_filename = ['Calibration_UnityUnlit_CS2000_Pimax_dE_30_03_2023.mat'];

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
x = (0:5:255)./255;
N = length(x);
for ch=1:3
    y = Ys(:, ch)';                       
    
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    options = optimoptions(@fmincon,'Display', 'none');
    if ch ==1 
        lb = [1.5,0.1,double(y(1)), 0];
        ub = [2.5,250,double(y(1)), 1];
        x0 = [2 1 double(y(1)) 1];
        
        fun = @(p) fun2minlin_shift(p,double(x),double(y));
        PS(:,ch) = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
    else
        lb = [1.5,0.1,double(y(1))];
        ub = [2.5,250,double(y(1))];
        x0 = [2 1 double(y(1))];
        fun = @(p) fun2min_shift(p,double(x),double(y));
        PS(:,ch) = [fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options) 1];
    end
    
    % relative error
    est_err(ch) = sum((1-(gammalinFun2(PS(:, ch),x)/y)).^2);
end

%% Plot the estimated curves and the measured luminance values
figure;
Gammas = PS(1,:);
Clipp = PS(4,:);
cols={'r','g','b','k'};
linew = 3;
marksize = 10;
name_channels = {'Red', 'Green', 'Blue'};
for ch=1:3

    subplot(1,2,1)
    hold on
    
    plot(x,Ys(:, ch),...
        [cols{ch} 'o'],'markerFaceColor',cols{ch}, 'markersize', marksize);
    
    plot(x,gammalinFun2(PS(:,ch), x),[cols{ch} '-'],'LineWidth',linew);
    
    text(x(end-10), (PS(2,ch)*x(end-1).^PS(1,ch)), name_channels{ch}, ...
        'FontSize', 30, 'fontname','TeXGyreTermes')
    box off
    leg = legend({'Measured', 'Estimated'}, 'Location','northwest');
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
leg = legend({'Additivity', 'Measured'}, 'Location','best', 'FontSize',30);
set(leg,'Box','off')
box off
xlabel('Normalized Intensity Values','FontSize',15)
ylabel('Luminance (cd/m^{2})','FontSize',15)
set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
set(gcf,'renderer','Painters');

%% Perform the validation using the calibration matrix and gamma values
% LOOK AT TEST COLORS
load PredefinedRGB;
for ch=1:3
    monXYZ(ch,:) = [Xs(end, ch) Ys(end, ch) Zs(end, ch)];
end

RGBStest = PredefinedRGB./255;
aux  = [Validation_rand];
for i=1:length(aux)
    XYZmeas(i, :) = aux(i).color.XYZ;
end

for ch = 1:3
    RGBStestLinear(:, ch) = RGBStest(:, ch).^Gammas(ch);
    RGBStestLinear(RGBStest(:, ch) > Clipp(ch), ch) = Clipp(ch).^Gammas(ch);
end

%XYZNoCalibration=RGBStest*monXYZ;
XYZ = RGBStestLinear * monXYZ;
XYZwhite = [1 1 1] *monXYZ;

xyY = XYZToxyY(XYZ')';

xyYmeas = XYZToxyY(XYZmeas')';

%% Plot the results
figure;plotChromaticity();hold on
plot(xyY(:,1),xyY(:,2),'ko','MarkerSize',10,'LineWidth',2);
plot(xyYmeas(:,1),xyYmeas(:,2),'kx','markersize',12,'linewidth',2)
set(gca,'FontSize',15,'LineWidth',2)
box off
xlabel('x','FontSize',15)
ylabel('y','FontSize',15)
set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes', 'Color', [1. 1. 1.]); %
grid on
set(gcf,'renderer','Painters');

%% Compute deltae2000
lab_meas = xyz2lab(XYZmeas, 'whitepoint', ...
    white.color.XYZ'); % ./max(ValoresXYZ(3*N+1, :))
lab_est  = xyz2lab(XYZ,     'whitepoint', ...
    XYZwhite); % ./max(XYZ(1, :))

dE = deltaE00(lab_meas', lab_est');
dENoCalibration = deltaE00(lab_meas', rgb2lab(PredefinedRGB./255,"WhitePoint",[1 1 1],"ColorSpace","linear-rgb")');
disp(dE)

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
    save(save_filename, 'monXYZ', 'Gammas', 'dE', 'lab_meas', 'lab_est');
end

%% Display errors and estimated parameters
est_err
PS
[mean(dE) median(dE) max(dE)]


