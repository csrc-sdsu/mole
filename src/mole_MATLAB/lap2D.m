function L = lap2D(k, m, dx, n, dy)
% Returns a two-dimensional mimetic laplacian operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis

    D = div2D(k, m, dx, n, dy);
    G = grad2D(k, m, dx, n, dy);
    
    L = D*G;
end
