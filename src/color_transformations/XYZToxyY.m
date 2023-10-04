function xyY = XYZToxyY( input_XYZ )


for i=1:size(input_XYZ, 2)
    xyY(1, i) = input_XYZ(1, i)./sum( input_XYZ(:, i));
    xyY(2, i) = input_XYZ(2, i)./sum( input_XYZ(:, i));
end

xyY(3, :) = input_XYZ(2, :);