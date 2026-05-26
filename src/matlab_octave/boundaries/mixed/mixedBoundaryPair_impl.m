function [d, n] = mixedBoundaryPair_impl(kind, coeffs, errorIdPrefix)
    switch lower(kind)
        case 'dirichlet'
            d = coeffs;
            n = 0;
        case 'neumann'
            d = 0;
            n = coeffs;
        case 'robin'
            assert(numel(coeffs) == 2, ...
                   'Robin coefficients must be a 2-element vector [a b]');
            d = coeffs(1);
            n = coeffs(2);
        otherwise
            error([errorIdPrefix ':UnknownBoundaryType'], ...
                  'Unknown boundary condition type "%s"', kind);
    end
end