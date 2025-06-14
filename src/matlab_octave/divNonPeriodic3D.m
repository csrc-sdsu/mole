function D = divNonPeriodic3D(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                o : Number of cells along z-axis
%               dz : Step size along z-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    Im = sparse(m + 2, m);
    Im(2:(m + 2) - 1, :) = speye(m, m);
    
    Dx = divNonPeriodic(k, m, dx);
    
    In = sparse(n + 2, n);
    In(2:(n + 2) - 1, :) = speye(n, n);
    
    Dy = divNonPeriodic(k, n, dy);
    
    Io = sparse(o + 2, o);
    Io(2:(o + 2) - 1, :) = speye(o, o);
    
    Dz = divNonPeriodic(k, o, dz);
    
    Sx = kron(kron(Io, In), Dx);
    Sy = kron(kron(Io, Dy), Im);
    Sz = kron(kron(Dz, In), Im);
    
    D = [Sx Sy Sz];
end
