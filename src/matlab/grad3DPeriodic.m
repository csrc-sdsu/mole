function G = grad3DPeriodic(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional mimetic gradient operator
% when the boundary condition is periodic
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

    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);
    
    Gx = gradPer(k, m, dx);   
    Gy = gradPer(k, n, dy);
    Gz = gradPer(k, o, dz);
    
    Sx = kron(kron(Io, In), Gx);
    Sy = kron(kron(Io, Gy), Im);
    Sz = kron(kron(Gz, In), Im);
    
    G = [Sx; Sy; Sz];
end
