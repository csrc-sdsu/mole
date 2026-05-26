function [Al, Ar] = addScalarBC1Dlhs_impl(k, m, dx, dc, nc)
    Al = sparse(m+2, m+2);
    Ar = sparse(m+2, m+2);
    if dc(1,1) ~= 0; Al(1,1) = dc(1,1); end
    if dc(2,1) ~= 0; Ar(end,end) = dc(2,1); end

    Bl = sparse(m+2, m+1);
    Br = sparse(m+2, m+1);
    Gl = gradNonPeriodic(k, m, dx);
    Gr = gradNonPeriodic(k, m, dx);
    if nc(1,1) ~= 0; Bl(1,1) = -nc(1,1); end
    if nc(2,1) ~= 0; Br(end,end) = nc(2,1); end

    Al = Al + Bl*Gl;
    Ar = Ar + Br*Gr;
end