function L = lap3D(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional mimetic laplacian operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                o : Number of cells along z-axis
%               dz : Step size along z-axis

    D = div3D(k, m, dx, n, dy, o, dz);
    G = grad3D(k, m, dx, n, dy, o, dz);
    
    L = D*G;
end
