function ID = interpDMat3D(k, m, n, o)
% Interpolator for Div 3D

    Im = sparse(m + 2, m);
    Im(2:(m + 2) - 1, :) = speye(m, m);
    
    Ix = interpDMat(k, m);
    
    In = sparse(n + 2, n);
    In(2:(n + 2) - 1, :) = speye(n, n);
    
    Iy = interpDMat(k, n);
    
    Io = sparse(o + 2, o);
    Io(2:(o + 2) - 1, :) = speye(o, o);
    
    Iz = interpDMat(k, o);
    
    Sx = kron(kron(Io', In'), Ix);
    Sy = kron(kron(Io', Iy), Im');
    Sz = kron(kron(Iz, In'), Im');
    
    ID = [Sx; Sy; Sz];
end