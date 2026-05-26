function [dc, nc] = robinBoundaryCoefficients_impl(a, b, count)
    dc = a * ones(count, 1);
    nc = b * ones(count, 1);
end