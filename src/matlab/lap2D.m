function L = lap2D(k, m, dx, n, dy, dc, nc)
% Returns a two-dimensional mimetic Laplacian operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%    (optional) dc : a0 (4x1 vector for left, right, bottom, top boundaries, resp.)
%    (optional) nc : b0 (4x1 vector for left, right, bottom, top boundaries, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    if nargin ~= 5 && nargin ~= 7
        error('lap2D:InvalidNumArgs', 'lap2D expects 5 or 7 arguments');
    end
    
    % for legacy code
    if nargin == 5
        L = lapNonPeriodic2D(k, m, dx, n, dy);
        return;
    end

    D = div2D(k, m, dx, n, dy, dc, nc);
    G = grad2D(k, m, dx, n, dy, dc, nc);
    
    L = D*G;
end
