function I = interpolD2D_impl(m, n, c1, c2)
% Canonical implementation for deprecated interpolD2D wrapper.

    if isstruct(m)
        grid = m;
        c2 = c1;
        c1 = n;
        assert(isfield(grid, 'm'), 'grid.m is required');
        assert(isfield(grid, 'n'), 'grid.n is required');
        m = double(grid.m);
        n = double(grid.n);
    end

    assert(c1 >= 0 && c1 <= 1, '0 <= c1 <= 1');
    assert(c2 >= 0 && c2 <= 1, '0 <= c2 <= 1');
    if abs(c1 - 0.5) > eps || abs(c2 - 0.5) > eps
        warning('interpolD2D:DeprecatedCoeff', ...
                ['interpolD2D is deprecated; using 2nd-order faces-to-centers ', ...
                 'operator. Coefficients c1 and c2 are ignored.']);
    end

    I = interpolFacesToCentersG2D(2, m, n);
end