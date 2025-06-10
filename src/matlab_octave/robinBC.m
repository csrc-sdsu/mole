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
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    A = sparse(m+2, m+2);
    A(1, 1) = a;
    A(end, end) = a;
    
    B = sparse(m+2, m+1);
    B(1, 1) = -b;
    B(end, end) = b;
    
    G = grad(k, m, dx);
    
    BC = A + B*G;
end
