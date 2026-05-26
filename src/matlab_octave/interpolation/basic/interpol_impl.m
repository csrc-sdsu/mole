function I = interpol_impl(m, c)
% Canonical implementation for deprecated interpol wrapper.

    if isstruct(m)
        grid = m;
        assert(isfield(grid, 'm'), 'grid.m is required');
        m = double(grid.m);
    end

    assert(m >= 4, 'm >= 4');
    assert(c >= 0 && c <= 1, '0 <= c <= 1');

    if abs(c - 0.5) > eps
        warning('interpol:DeprecatedCoeff', ...
                ['interpol is deprecated; using 2nd-order centers-to-faces ', ...
                 'operator. Coefficient c is ignored.']);
    end

    I = interpolCentersToFacesD1D(2, m);
end