function G = grad2DPeriodic(k, m, dx, n, dy)
% Returns a two-dimensional mimetic gradient operator
% when the boundary condition is periodic
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

    Gx = gradPeriodic(k, m, dx);
    Gy = gradPeriodic(k, n, dy);
    
    Im = speye(m, m);
    In = speye(n, n);
    
    Sx = kron(In, Gx);
    Sy = kron(Gy, Im);
    
    G = [Sx; Sy];
end
