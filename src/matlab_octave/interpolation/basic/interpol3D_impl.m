function I = interpol3D_impl(m, n, o, c1, c2, c3)
% Canonical implementation for deprecated interpol3D wrapper.

    if isstruct(m)
        grid = m;
        c3 = c2;
        c2 = c1;
        c1 = o;
        assert(isfield(grid, 'm'), 'grid.m is required');
        assert(isfield(grid, 'n'), 'grid.n is required');
        assert(isfield(grid, 'o'), 'grid.o is required');
        m = double(grid.m);
        n = double(grid.n);
        o = double(grid.o);
    end

    assert(c1 >= 0 && c1 <= 1, '0 <= c1 <= 1');
    assert(c2 >= 0 && c2 <= 1, '0 <= c2 <= 1');
    assert(c3 >= 0 && c3 <= 1, '0 <= c3 <= 1');
    if abs(c1 - 0.5) > eps || abs(c2 - 0.5) > eps || abs(c3 - 0.5) > eps
        warning('interpol3D:DeprecatedCoeff', ...
                ['interpol3D is deprecated; using 2nd-order centers-to-faces ', ...
                 'operator. Coefficients c1, c2, and c3 are ignored.']);
    end

    I = interpolCentersToFacesD3D(2, m, n, o);
end