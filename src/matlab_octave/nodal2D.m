function N = nodal2D(k, m, dx, n, dy)
% Returns a two-dimensional operator that approximates the first-order 
% derivatives on a uniform nodal grid
%
% Parameters:
%                k : Order of accuracy
%                m : Number of nodes along x-axis
%               dx : Step size along x-axis
%                n : Number of nodes along y-axis
%               dy : Step size along y-axis
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    Nx = nodal(k, m, dx);
    Ny = nodal(k, n, dy);
    
    Im = speye(m, m);
    In = speye(n, n);
    
    N = [kron(In, Nx); kron(Ny, Im)];
end