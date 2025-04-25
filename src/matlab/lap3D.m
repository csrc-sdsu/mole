function L = lap3D(k, m, dx, n, dy, o, dz, dc, nc)
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
%    (optional) dc : a0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%    (optional) nc : b0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    if nargin ~= 7 && nargin ~= 9
        error('lap3D:InvalidNumArgs', 'lap3D expects 7 or 9 arguments');
    end
    
    % for legacy code
    if nargin == 7
        L = lapNonPeriodic3D(k, m, dx, n, dy, o, dz);
        return;
    end

    D = div3D(k, m, dx, n, dy, o, dz, dc, nc);
    G = grad3D(k, m, dx, n, dy, o, dz, dc, nc);
    
    L = D*G;
end
