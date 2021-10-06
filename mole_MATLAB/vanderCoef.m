function C = vanderCoef(x)
    V = inv(fliplr(vander(x)));
    C = V(1, :); % Coefficients for the interiors
end