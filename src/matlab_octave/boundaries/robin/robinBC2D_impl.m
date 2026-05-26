function BC = robinBC2D_impl(k, m, dx, n, dy, a, b)
    [dc, nc] = robinBoundaryCoefficients_impl(a, b, 4);
    [Abcl, Abcr, Abcb, Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc);
    BC = Abcl + Abcr + Abcb + Abct;
end