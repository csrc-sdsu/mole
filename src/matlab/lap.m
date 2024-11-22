function L = lap(k, m, dx)
% Returns a m+2 by m+2 one-dimensional mimetic laplacian operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size

    D = div(k, m, dx);
    G = grad(k, m, dx);
    
    L = D*G;
end
