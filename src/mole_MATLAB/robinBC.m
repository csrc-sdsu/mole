% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function BC = robinBC(k, m, dx, a, b)
% Returns a m+2 by m+2 one-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient

    A = sparse(m+2, m+2);
    A(1, 1) = a;
    A(end, end) = a;
    
    B = sparse(m+2, m+1);
    B(1, 1) = -b;
    B(end, end) = b;
    
    G = grad(k, m, dx);
    
    BC = A + B*G;
end
