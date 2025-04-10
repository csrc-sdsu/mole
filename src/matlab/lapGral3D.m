function L = lapGral3D(k, m, dx, n, dy, o, dz, dc, nc)
% Returns a three-dimensional mimetic Laplacian operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
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

    D = divGral3D(k, m, dx, n, dy, o, dz, dc, nc);
    G = gradGral3D(k, m, dx, n, dy, o, dz, dc, nc);
    
    L = D*G;
end
