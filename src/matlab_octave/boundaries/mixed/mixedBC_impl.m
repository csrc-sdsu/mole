function BC = mixedBC_impl(k, m, dx, left, coeffs_left, right, coeffs_right)
    [dl, nl] = mixedBoundaryPair_impl(left, coeffs_left, 'mixedBC');
    [dr, nr] = mixedBoundaryPair_impl(right, coeffs_right, 'mixedBC');

    dc = [dl; dr];
    nc = [nl; nr];
    [Al, Ar] = addScalarBC1Dlhs(k, m, dx, dc, nc);
    BC = Al + Ar;
end