function L = lapGral1D(k, m, dx, dc, nc)
% Returns a one-dimensional mimetic Laplacian operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%               dc : a0 (2x1 vector for left and right vertices, resp.)
%               nc : b0 (2x1 vector for left and right vertices, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    D = divGral1D(k, m, dx, dc, nc);
    G = gradGral1D(k, m, dx, dc, nc);
    
    L = D*G;
end
