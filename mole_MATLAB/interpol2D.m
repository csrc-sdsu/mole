function I = interpol2D(m, n, c1, c2)
% Returns a two-dimensional interpolator of 2nd-order
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%               c1 : Left interpolation coeff.
%               c2 : Bottom interpolation coeff.

    Ix = interpol(m, c1);
    Iy = interpol(n, c2);
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In', Ix);
    Sy = kron(Iy, Im');
    
    I = [Sx; Sy];
end
