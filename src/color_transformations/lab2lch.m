function values_out = lab2lch(values_in)

values_out(1, :) = values_in(1, :);
values_out(2, :) = sqrt(values_in(2, :).^2 + values_in(3, :).^2);

% Convert from radians to degrees
for i=1:size(values_in,2)
    
    if values_in(2, i) == 0
        values_in(2, i) = 1;
    end
%     values_out(3, i) = (180/pi).*atan2(values_in(3, i), values_in(2, i));
    values_out(3, i) = atan2(values_in(3, i), values_in(2, i));
    
%     if values_out(3, i) < 0
%         values_out(3, i) = values_out(3, i) + 360;
%     end
    

end