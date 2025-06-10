function BC = robinBC3D(k, m, dx, n, dy, o, dz, a, b)
% Returns a three-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                o : Number of cells along z-axis
%               dz : Step size along z-axis
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % 1-D boundary operators
    Bm = robinBC(k, m, dx, a, b);
    Bn = robinBC(k, n, dy, a, b);
    Bo = robinBC(k, o, dz, a, b);
    
    Im = speye(m+2);
    
    In = speye(n+2);
    
    Io = speye(o+2);
    Io(1, 1) = 0;
    Io(end, end) = 0;
    
    In2 = In;
    In2(1, 1) = 0;
    In2(end, end) = 0;
    
    BC1 = kron(kron(Io, In2), Bm);
    BC2 = kron(kron(Io, Bn), Im);
    BC3 = kron(kron(Bo, In), Im);
    
    BC = BC1 + BC2 + BC3;
end
