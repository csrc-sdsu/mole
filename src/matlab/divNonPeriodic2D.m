function D = divNonPeriodic2D(k, m, dx, n, dy)
% Returns a two-dimensional mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    Dx = divNonPeriodic(k, m, dx);
    Dy = divNonPeriodic(k, n, dy);
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In, Dx);
    Sy = kron(Dy, Im);
    
    D = [Sx Sy];
end
