% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function BC = robinBC2D(k, m, dx, n, dy, a, b)
% Returns a two-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient

    % 1-D boundary operator
    Bm = robinBC(k, m, dx, a, b);
    Bn = robinBC(k, n, dy, a, b);
    
    Im = speye(m+2);
    
    In = speye(n+2);
    In(1, 1) = 0;
    In(end, end) = 0;
    
    BC1 = kron(In, Bm);
    BC2 = kron(Bn, Im);
    
    BC = BC1 + BC2;
end
