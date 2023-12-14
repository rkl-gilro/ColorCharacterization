%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Calibration new data setup Unreal
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('Calibration_UnrealUnlit_HTCVive_14_03_2023.mat');
save_filename = 'Calibration_UnrealUnlit_HTCVive_14_03_2023_dE.mat';

%% Comment or uncomment accordingly (HTC 5:255)
x = (0:5:255)./255;

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

    lab_aux = xyz2lab([Xs(:, i) Ys(:, i) Zs(:, i)], 'whitepoint', ...
    white.color.XYZ');

    rgb_aux = xyz2rgb([Xs(:, i) Ys(:, i) Zs(:, i)], 'ColorSpace','linear-rgb',...
        'WhitePoint',white.color.XYZ');
    lch_primaries{i} = lab2lch(lab_aux')';

    rgb_aux(rgb_aux > 1) = 1;
    rgb_aux(rgb_aux < 0) = 0;
    rgb_primaries{i} = double(rgb_aux);
    hsv_primaries{i} = rgb2hsv(double(rgb_aux));

end

yticks([0 0.2 0.4 0.6 0.8])
xticks([0 0.2 0.4 0.6 0.8])

set(gca,  'FontSize', 20, 'fontname','Times New Roman', 'Color', 'none');
grid on
set(gcf,'renderer','Painters');


figure
for i=1:size(primaries, 1)
    subplot(1, 4, i)
    
    for j=1:size(primaries, 2)
        
        plot(380:780,primaries(i, j).radiance.value, cols{i}); hold on
        
    end
    set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes');
    grid on
    set(gcf,'renderer','Painters');
end

%% Estimated gamma curves for each channel
for ch=1:3
    monXYZ(ch,:) = [Xs(end, ch) Ys(end, ch) Zs(end, ch)];
end

x = (0:5:255)./255;
N = length(x);

radiometric = [Xs(:, 4) Ys(:, 4) Zs(:, 4)]* inv(monXYZ);

%% Perform the validation using the calibration matrix and gamma values
% LOOK AT TEST COLORS
load PredefinedRGB.mat

RGBStest = [PredefinedRGB./255]; 
aux  = [Validation_rand]; 

for ch = 1:3

    RGBStestLinear(:, ch) = interp1(x, radiometric(:, ch), ...
        RGBStest(:, ch));
    RGBSwhite(:, ch) = interp1(x, radiometric(:, ch), 1);
    
end

XYZNoCalibration = RGBStest * monXYZ;
XYZNoCalibrationwhite = [1 1 1] * monXYZ;
XYZ = RGBStestLinear * monXYZ;
xyY = XYZToxyY(XYZ');
XYZwhite = RGBSwhite * monXYZ;

for i=1:length(aux)
    XYZmeas(i, :) = aux(i).color.XYZ;
end

xyYmeas = XYZToxyY(XYZmeas')';

%% Plot the results
%% NOTE for
figure;plotChromaticity();hold on
plot(xyY(1, :),xyY(2, :),'bo','MarkerSize',10,'LineWidth',2);
plot(xyYmeas(:,1),xyYmeas(:,2),'kx','markersize',12,'linewidth',2)
set(gca,'FontSize',15,'LineWidth',2)
box off
xlabel('x','FontSize',15)
ylabel('y','FontSize',15)


%% Compute deltae2000
lab_meas = xyz2lab(XYZmeas, 'whitepoint', white.color.XYZ');
lab_est  = xyz2lab(XYZ,     'whitepoint', XYZwhite);
labNoCalibration_est  = xyz2lab(XYZNoCalibration,...
    'whitepoint', XYZNoCalibrationwhite); 

dE = deltaE00(lab_meas', lab_est');
dENoCalibration = deltaE00(lab_meas', labNoCalibration_est');


figure;
msize = 20;
for i=1:length(dE)
    plot(i, dE(i), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
end
plot(1:length(dE), ones(1, length(dE)), 'k--');

ylim([0 5])
set(gca, 'FontSize', 22)
xlabel('Colours','FontSize',40)
ylabel('DeltaE00','FontSize',40)


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
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);...
    lab_meas(:, 2)]) min([lab_est(:, 3); lab_meas(:, 3)]) ...
    max([lab_meas(:, 3);lab_est(:, 3)])])

subplot 132;
for i = 2:size(lab_est, 1)
    plot(lab_est(i, 2), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 2), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('a*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 2); lab_meas(:, 2)]) max([lab_est(:, 2);...
    lab_meas(:, 2)]) min([lab_est(:, 1); lab_meas(:, 1)]) ...
    max([lab_meas(:, 1);lab_est(:, 1)])])

subplot 133;
for i = 2:size(lab_est, 1)
    plot(lab_est(i, 3), lab_est(i, 1), 'o', 'color', RGBStest(i, :), ...
        'markerfacecolor', RGBStest(i, :), 'markersize', msize);hold on
    
    plot(lab_meas(i, 3), lab_meas(i, 1), 'kx', 'markersize', msize);hold on
    xlabel('b*','FontSize',15)
    ylabel('L*','FontSize',15)
end
axis equal
axis([min([lab_est(:, 3); lab_meas(:, 3)]) max([lab_est(:, 3);...
    lab_meas(:, 3)]) min([lab_est(:, 1); lab_meas(:, 1)]) ...
    max([lab_meas(:, 1);lab_est(:, 1)])])

%% Save characterization values and deltae errors
if ~isempty(save_filename)
    save(save_filename, 'monXYZ', 'radiometric', ...
        'dE', 'lab_meas', 'lab_est');
end

%% Display errors and estimated parameters
disp 'deltaE00 -> mean, median, std, min and max'
disp(num2str([mean(dE) median(dE) std(dE) min(dE) max(dE)]))

disp 'deltaE00 no calibration -> mean, median, std, min and max'
disp(num2str([mean(dENoCalibration) median(dENoCalibration) ...
    std(dENoCalibration) min(dENoCalibration) max(dENoCalibration)]))