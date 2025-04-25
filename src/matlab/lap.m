function L = lap(k, m, dx, dc, nc)
% Returns a one-dimensional mimetic Laplacian operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%    (optional) dc : a0 (2x1 vector for left and right vertices, resp.)
%    (optional) nc : b0 (2x1 vector for left and right vertices, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    if nargin ~= 3 && nargin ~= 5
        error('lap:InvalidNumArgs', 'lap expects 3 or 5 arguments');
    end
    
    % for legacy code
    if nargin == 3
        L = lapNonPeriodic(k, m, dx);
        return;
    end

    D = div(k, m, dx, dc, nc);
    G = grad(k, m, dx, dc, nc);
    
    L = D*G;
end
