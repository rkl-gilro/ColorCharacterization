function RGB = mtxyYtoRGB( xyY, filename_mat )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% HTC vive calibration using Unreal Engine
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show = 0;
%% Load the curves R, G, B vs X, Y, Z (9 lines in total)
% P(1) is the shift in y axis, P(2) is the slope, and P(3) the flat region
load( filename_mat );

%% Convert the xyY values to XYZ
XYZ = xyYToXYZ( xyY' )';
XYZ_w = [114.13 123.18 141.67];


%% Define matrix M and vector K
M = [PS_XYZ(2,1,1) PS_XYZ(2,2,1) PS_XYZ(2,3,1);PS_XYZ(2,1,2) PS_XYZ(2,2,2) PS_XYZ(2,3,2);PS_XYZ(2,1,3) PS_XYZ(2,2,3) PS_XYZ(2,3,3)];
K = [PS_XYZ(1,1,1)+PS_XYZ(1,2,1)+PS_XYZ(1,3,1);PS_XYZ(1,1,2)+PS_XYZ(1,2,2)+PS_XYZ(1,3,2);PS_XYZ(1,1,3)+PS_XYZ(1,2,3)+PS_XYZ(1,3,3)];

RGB   = pinv(M) * (XYZ - repmat(K', size(XYZ, 1), 1) )';
RGB_w = pinv(M) * (XYZ_w - repmat(K', size(XYZ_w, 1), 1) )';

% RGB   = RGB   ./ sum(RGB);
RGB_w = RGB_w ./ sum(RGB_w);

if show
    a = ones(100,100,3);
    a(:, :, 1) = RGB(1).*a(:, :, 1);
    a(:, :, 2) = RGB(2).*a(:, :, 2);
    a(:, :, 3) = RGB(3).*a(:, :, 3);
    figure;imshow([a a./sum(RGB)])
end

