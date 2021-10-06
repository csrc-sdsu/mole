function IG = interpGMat3D(k, m, n, o)
% Interpolator for Grad 3D

    Im = sparse(m + 2, m);
    Im(2:(m + 2) - 1, :) = speye(m, m);
    
    Ix = interpGMat(k, m);
    
    In = sparse(n + 2, n);
    In(2:(n + 2) - 1, :) = speye(n, n);
    
    Iy = interpGMat(k, n);
    
    Io = sparse(o + 2, o);
    Io(2:(o + 2) - 1, :) = speye(o, o);
    
    Iz = interpGMat(k, o);
    
    Sx = kron(kron(Io, In), Ix);
    Sy = kron(kron(Io, Iy), Im);
    Sz = kron(kron(Iz, In), Im);
    
    IG = [Sx Sy Sz];
end