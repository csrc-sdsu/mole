function BC = robinBC_impl(k, m, dx, a, b)
    [dc, nc] = robinBoundaryCoefficients_impl(a, b, 2);
    [Abcl, Abcr] = addScalarBC1Dlhs(k, m, dx, dc, nc);
    BC = Abcl + Abcr;
end