function IG = interpGMat2D(k, m, n)
% Interpolator for Grad 2D

    Ix = interpGMat(k, m);
    Iy = interpGMat(k, n);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    IG = [Sx Sy];
end