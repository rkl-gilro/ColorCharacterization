% clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% HMD colour characterisation
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('Calibation_Unity6_CS2000_Quest3_Unmanaged3_20_03_2025.mat');
% save_filename = 'Unity6_CS2000_Hololens2__27_03_2025model.mat';
black_level = 1;

primaries(1, :) = [Red];
primaries(2, :) = [Green];
primaries(3, :) = [Blue];
primaries(4, :) = [Gray];

white = [White]; 

x = (0:5:255)./255;
N = length(x);

if black_level
    allblacks_xyz = zeros(size(primaries, 1),3);
    for i=1:size(primaries, 1)
        allblacks_xyz(i, :) = primaries(i, 1).color.XYZ;
    end
    black_levelxyz = mean(allblacks_xyz);
end


%% Defin xyY, xyz, and spectra %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:size(primaries, 1)
    
    for j=1:size(primaries, 2)
        aux0 = [primaries(i, j).color.xyY];
        aux1 = [primaries(i, j).color.XYZ];
        Ys(j, i) = aux0(3) ;
        xs(j, i) = aux0(1) ;
        ys(j, i) = aux0(2) ;
        Xs(j, i) = aux1(1) ;
        Zs(j, i) = aux1(3) ;
        SPECTRA((i-1)*size(primaries, 2) + j,:) = ...
            primaries(i, j).radiance.value;
    end
    
end

%% Plot measurements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot xy chromaticities of primaries
figure;
plotChromaticity();hold on
cols = {'r', 'g', 'b', 'k'};
for i=1:size(primaries, 1)
    if black_level
        xyz_aux = [Xs(:, i) Ys(:, i) Zs(:, i)] - black_levelxyz;
        xyY_aux = XYZToxyY(xyz_aux');

        plot(xyY_aux(1, :), xyY_aux(2, :), [cols{i}, 'o'], 'MarkerSize', 12, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);
    else
        plot(xs(:, i), ys(:, i), [cols{i}, 'o'], 'MarkerSize', 12, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);
    end
end
yticks([0 0.2 0.4 0.6 0.8])
xticks([0 0.2 0.4 0.6 0.8])

set(gca,  'FontSize', 20, 'fontname','Times New Roman',...
    'Color', [1. 1. 1.]);
grid on
set(gcf,'renderer','Painters');

% Plot Y luminance and additivity
figure;
plotChromaticity();hold on
cols = {'r', 'g', 'b', 'k'};
for i=1:size(primaries, 1)
    subplot(1,4,i)
    if black_level
        plot(x, Ys(:, i)- black_levelxyz(2), [cols{i}, '-o'], ...
            'MarkerSize', 6, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);hold on
    else
        plot(x, Ys(:, i), [cols{i}, '-o'], 'MarkerSize', 6, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);hold on
    end
    xticks([0 0.2 0.4 0.6 0.8])
    grid on
end
if black_level
    plot(x, sum(Ys(:, 1:3) - black_levelxyz(2),2), [cols{i}, '--'],...
        'MarkerSize', 6, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);
else
    plot(x, sum(Ys(:, 1:3),2), [cols{i}, '--'], 'MarkerSize', 6, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);
end
xticks([0 0.2 0.4 0.6 0.8])
ylabel('Luminance Y (cd/m^2)')
set(gca,  'FontSize', 20, 'fontname','Times New Roman');
grid on
set(gcf,'renderer','Painters');

% Plot spectra of all primary ranges
figure;
for i=1:size(primaries, 1)
    subplot(1, 4, i)
    
    for j=1:size(primaries, 2)
        
        plot(380:780,primaries(i, j).radiance.value, cols{i}); hold on
        
    end
    xlabel('Wavelength (nm)', 'Interpreter','latex');
    ylabel('Power', 'Interpreter','latex');
    set(gca,  'FontSize', 24, 'fontname','TeXGyreTermes');
    grid on
    set(gcf,'renderer','Painters');
end

% Plot normalize spectra in a single plot (only maximum intensities)
figure
for i=1:size(primaries, 1)
    plot(380:780,primaries(i, end).radiance.value ./ ...
    max(primaries(i, end).radiance.value), [cols{i}, '-.'],...
    'LineWidth',2); hold on
end
set(gca,  'FontSize', 15, 'fontname','Times New Roman');
set(gcf,'renderer','Painters');
legend('Red primary','Green primary','Blue primary', ...
    'Interpreter','latex','Location','northeast','FontSize',12);
legend('boxoff')
xlabel('Wavelength (nm)', 'Interpreter','latex');
ylabel('Normalized power', 'Interpreter','latex');
axis([380 780 0 1])
xticks([400 500 600 700])

% Plot spectra in a single plot  (only maximum intensities)
figure
for i=1:size(primaries, 1)
    plot(380:780,primaries(i, end).radiance.value, [cols{i}, '-.'],...
    'LineWidth',2); hold on
end
set(gca,  'FontSize', 15, 'fontname','Times New Roman');
set(gcf,'renderer','Painters');
legend('Red primary','Green primary','Blue primary', ...
    'Interpreter','latex','Location','northeast','FontSize',12);
legend('boxoff')
xlabel('Wavelength (nm)', 'Interpreter','latex');
ylabel('Power (Watt/m^2 sr nm)', 'Interpreter','latex');
axis([380 780 0 Inf])
xticks([400 500 600 700])


%% Define the model: matrix + LUTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Matrix
for ch=1:3
    if black_level
        monXYZ(ch,:) = ...
        [Xs(end, ch) Ys(end, ch) Zs(end, ch)] - black_levelxyz;
    else
         monXYZ(ch,:) = ...
        [Xs(end, ch) Ys(end, ch) Zs(end, ch)];
    end
end

%% LUT with non-linearities
if black_level
    radiometric = ([Xs(:, 4) Ys(:, 4) Zs(:, 4)] - black_levelxyz)*...             % 
        inv(monXYZ);
else
    radiometric = ([Xs(:, 4) Ys(:, 4) Zs(:, 4)])* inv(monXYZ);
end

%% Perform the validation of  the model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOOK AT TEST COLORS
load PredefinedRGB;

RGBStest = PredefinedRGB./255;
aux  = [Validation_rand];
for i=1:length(aux)
    XYZmeas(i, :) = aux(i).color.XYZ;
end

for ch = 1:3
    RGBStestLinear(:, ch) = ...
        interp1(x, radiometric(:, ch), RGBStest(:, ch));
    RGBSwhite(:, ch) = interp1(x, radiometric(:, ch), 1);
end

if black_level
    XYZ = RGBStestLinear * monXYZ + black_levelxyz;
    XYZwhite = RGBSwhite * monXYZ + black_levelxyz;
else
    XYZ = RGBStestLinear * monXYZ;
    XYZwhite = RGBSwhite * monXYZ;
end

xyY = XYZToxyY(XYZ')';
xyYmeas = XYZToxyY(XYZmeas')';

%% Compute deltae2000
lab_meas = xyz2lab(XYZmeas, 'whitepoint', white.color.XYZ'); 

lab_est  = xyz2lab(XYZ,  'whitepoint', XYZwhite);
lab_nocalib  = rgb2lab(RGBStest, 'whitepoint', [1 1 1], ...
    'ColorSpace','linear-rgb');

dE = deltaE00(lab_meas', lab_est');
dE_nocalib = deltaE00(lab_meas', lab_nocalib');

%% Plot validation results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;% xy chromaticity diagram
plotChromaticity();hold on
plot(xyY(:,1),xyY(:,2),'ko','MarkerSize',10,'LineWidth',2);
plot(xyYmeas(:,1),xyYmeas(:,2),'kx','markersize',12,'linewidth',2)
set(gca,'FontSize',15,'LineWidth',2)
box off
xlabel('x','FontSize',15)
ylabel('y','FontSize',15)
set(gca,  'FontSize', 30, 'fontname','TeXGyreTermes');
grid on
set(gcf,'renderer','Painters');


msize=15;
figure;% Lab colour space
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


%% Display errors and estimated parameters
disp 'deltaE00 -> mean, median, std, min and max'
disp(num2str([mean(dE) median(dE) std(dE) min(dE) max(dE)]))

disp 'deltaE00 no calibration -> mean, median, std, min and max'
disp(num2str([mean(dE_nocalib) median(dE_nocalib) ...
    std(dE_nocalib) min(dE_nocalib) max(dE_nocalib)]))

%% Save characterization values and deltae errors
try
    save(save_filename, 'monXYZ', 'radiometric', ...
        'dE', 'lab_meas', 'lab_est', 'dE_nocalib');
catch
    disp('No file name given for saving results');
end

