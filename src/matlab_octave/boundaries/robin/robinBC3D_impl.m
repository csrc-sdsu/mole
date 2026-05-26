function BC = robinBC3D_impl(k, m, dx, n, dy, o, dz, a, b)
    [dc, nc] = robinBoundaryCoefficients_impl(a, b, 6);
    [Abcl, Abcr, Abcb, Abct, Abcf, Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc);
    BC = Abcl + Abcr + Abcb + Abct + Abcf + Abcz;
end