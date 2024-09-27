function D = div2DNonUniform(k, xticks, yticks)
% Returns a two-dimensional non-uniform mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                xticks : Edges' ticks (x-axis)
%                yticks : Edges' ticks (y-axis)

    Dx = divNonUniform(k, xticks);
    Dy = divNonUniform(k, yticks);
    
    m = size(Dx, 1) - 2;
    n = size(Dy, 1) - 2;
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In, Dx);
    Sy = kron(Dy, Im);
    
    D = [Sx Sy];
end
