function XYZ = xyYToXYZ( input_xyY)


for i=1:size(input_xyY, 2)
    XYZ(1, i) = (input_xyY(1, i)/input_xyY(2, i)) * input_xyY(3, i);
    XYZ(3, i) = ((1-input_xyY(2, i)-input_xyY(1, i))/input_xyY(2, i))*input_xyY(3, i) ;
end

XYZ(2, :) = input_xyY(3, :);