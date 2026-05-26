function BC = mixedBC2D_impl(k, m, dx, n, dy, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top)
    [dl, nl] = mixedBoundaryPair_impl(left, coeffs_left, 'mixedBC2D');
    [dr, nr] = mixedBoundaryPair_impl(right, coeffs_right, 'mixedBC2D');
    [db, nb] = mixedBoundaryPair_impl(bottom, coeffs_bottom, 'mixedBC2D');
    [dt, nt] = mixedBoundaryPair_impl(top, coeffs_top, 'mixedBC2D');

    dc = [dl; dr; db; dt];
    nc = [nl; nr; nb; nt];
    [Abcl, Abcr, Abcb, Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc);
    BC = Abcl + Abcr + Abcb + Abct;
end