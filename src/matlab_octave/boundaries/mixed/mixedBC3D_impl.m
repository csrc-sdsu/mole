function BC = mixedBC3D_impl(k, m, dx, n, dy, o, dz, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back)
    [dl, nl] = mixedBoundaryPair_impl(left, coeffs_left, 'mixedBC3D');
    [dr, nr] = mixedBoundaryPair_impl(right, coeffs_right, 'mixedBC3D');
    [db, nb] = mixedBoundaryPair_impl(bottom, coeffs_bottom, 'mixedBC3D');
    [dt, nt] = mixedBoundaryPair_impl(top, coeffs_top, 'mixedBC3D');
    [df, nf] = mixedBoundaryPair_impl(front, coeffs_front, 'mixedBC3D');
    [dzc, nzc] = mixedBoundaryPair_impl(back, coeffs_back, 'mixedBC3D');

    dc = [dl; dr; db; dt; df; dzc];
    nc = [nl; nr; nb; nt; nf; nzc];
    [Abcl, Abcr, Abcb, Abct, Abcf, Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc);
    BC = Abcl + Abcr + Abcb + Abct + Abcf + Abcz;
end