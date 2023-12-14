clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Calibration new data setup Unreal
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('Calibration_UnrealStandard_Varjo_23_03_2023.mat');
save_filename = 'Calibration_UnrealUnlit_Varjo_23_03_2023_LUT_dE.mat';

%% Comment or uncomment accordingly
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
        SPECTRA((i-1)*size(primaries, 2) + j,:) = ...
            primaries(i, j).radiance.value;
    end
    plot(xs(:, i), ys(:, i), [cols{i}, 'o'], 'MarkerSize', 12, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', cols{i}, ...
        'LineWidth', .3);

end

yticks([0 0.2 0.4 0.6 0.8])
xticks([0 0.2 0.4 0.6 0.8])

set(gca,  'FontSize', 20, 'fontname','Times New Roman'); 
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


figure
plot(380:780,primaries(1, end).radiance.value ./ ...
    max(primaries(1, end).radiance.value), [cols{1}, '-.'],...
    'LineWidth',2); hold on
plot(380:780,primaries(2, end).radiance.value ./ ...
    max(primaries(2, end).radiance.value), [cols{2}, '-'],...
    'LineWidth',2); hold on
plot(380:780,primaries(3, end).radiance.value ./ ...
    max(primaries(3, end).radiance.value), [cols{3}, '--'],...
    'LineWidth',2); hold on
set(gca,  'FontSize', 15, 'fontname','Times New Roman');
set(gcf,'renderer','Painters');
legend('Red primary','Green primary','Blue primary', ...
    'Interpreter','latex','Location','northeast','FontSize',12);
legend('boxoff')
xlabel('Wavelength (nm)', 'Interpreter','latex');
ylabel('Normalized power', 'Interpreter','latex');
axis([380 780 0 1])
xticks([400 500 600 700])


for i=1:size(Xs, 1)
    additiviy_diff(i,1)= ((Xs(i, 4) - ...
        (Xs(i, 1) + Xs(i, 2) + Xs(i, 3))')./(Xs(i, 4)'));
    additiviy_diff(i,2)= ((Ys(i, 4) - ...
        (Ys(i, 1) + Ys(i, 2) + Ys(i, 3))')./(Ys(i, 4)'));
    additiviy_diff(i,3)= ((Zs(i, 4) - ...
        (Zs(i, 1) + Zs(i, 2) + Zs(i, 3))')./(Zs(i, 4)'));
end
disp('Additivity: ')
disp(num2str(sum(abs(additiviy_diff(~any( isnan( additiviy_diff ) | ...
    isinf( additiviy_diff ), 2 ), :)))))

additiviy_difff= 100*((Xs(end, 4) - ...
    (Xs(end, 1) + Xs(end, 2) + Xs(end, 3)))/Xs(end, 4));
disp(['Additiviy (only white)', num2str(additiviy_difff)])

%% Estimated gamma curves for each channel

for ch=1:3
    monXYZ(ch,:) = [Xs(end, ch) Ys(end, ch) Zs(end, ch)];
end

radiometric = [Xs(:, 4) Ys(:, 4) Zs(:, 4)] * inv(monXYZ);%(xyz_primaries \ rgb_primaries);

%% Perform the validation using the calibration matrix and gamma values
% LOOK AT TEST COLORS

load PredefinedRGB.mat

RGBStest = [PredefinedRGB./255]; 
aux  = [Validation_rand]; 

for ch = 1:3

    RGBStestLinear(:, ch) = interp1(x, radiometric(:, ch), RGBStest(:, ch));
    RGBSwhite(:, ch) = interp1(x, radiometric(:, ch), 1);
    
end

XYZ = RGBStestLinear * monXYZ;
xyY = XYZToxyY(XYZ');

XYZwhite = RGBSwhite * monXYZ;

for i=1:length(aux)
    XYZmeas(i, :) = aux(i).color.XYZ;
end

xyYmeas = XYZToxyY(XYZmeas')';

%% Plot the results
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
dE = deltaE00(lab_meas', lab_est');


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
