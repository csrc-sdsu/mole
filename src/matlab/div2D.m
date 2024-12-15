function D = div2D(k, m, dx, n, dy)
% Returns a two-dimensional mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis

    Dx = div(k, m, dx);
    Dy = div(k, n, dy);
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In, Dx);
    Sy = kron(Dy, Im);
    
    D = [Sx Sy];
end
