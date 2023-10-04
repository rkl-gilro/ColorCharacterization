function values_out = lch2lab(values_in)

% Convert from degrees to radians
% values_in(3, :) = (pi/180).* values_in(3, :);
values_in(3, :) = values_in(3, :);

values_out(1, :) = values_in(1, :);

for i=1:size(values_in, 2)
    values_out(2, i) = values_in(2, i).*cos(values_in(3, i));
    values_out(3, i) = values_in(2, i).*sin(values_in(3, i));
end
