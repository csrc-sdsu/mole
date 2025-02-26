function N = nodal3D(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional operator that approximates the first-order 
% derivatives on a uniform nodal grid
%
% Parameters:
%                k : Order of accuracy
%                m : Number of nodes along x-axis
%               dx : Step size along x-axis
%                n : Number of nodes along y-axis
%               dy : Step size along y-axis
%                o : Number of nodes along z-axis
%               dz : Step size along z-axis
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    Nx = nodal(k, m, dx);
    Ny = nodal(k, n, dy);
    Nz = nodal(k, o, dz);
    
    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);
    
    Sx = kron(kron(Io, In), Nx);
    Sy = kron(kron(Io, Ny), Im);
    Sz = kron(kron(Nz, In), Im);
    
    N = [Sx; Sy; Sz];
end