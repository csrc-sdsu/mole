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
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

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
