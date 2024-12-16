function N = nodal2D(k, m, dx, n, dy)
% Returns a two-dimensional operator that approximates the first-order 
% derivatives on a uniform nodal grid
%
% Parameters:
%                k : Order of accuracy
%                m : Number of nodes along x-axis
%               dx : Step size along x-axis
%                n : Number of nodes along y-axis
%               dy : Step size along y-axis
    
    Nx = nodal(k, m, dx);
    Ny = nodal(k, n, dy);
    
    Im = speye(m, m);
    In = speye(n, n);
    
    N = [kron(In, Nx); kron(Ny, Im)];
end