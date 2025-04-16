function D = div2D(k, m, dx, n, dy, dc, nc)
% Returns a two-dimensional mimetic divergence operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
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
        error('div2D:InvalidNumArgs', 'div2D expects 5 or 7 arguments');
    end
    
    % for legacy code
    if nargin == 5
        D = divNonPeriodic2D(k, m, dx, n, dy);
        return;
    end

    % verify bc-type sizes
    assert(all(size(dc) == [4 1]), 'dc is a 4x1 vector');
    assert(all(size(nc) == [4 1]), 'nc is a 4x1 vector');

    % D depends on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    if isempty(qrl)
        Dx = divPeriodic(k, m, dx);
        Im = speye(m, m);
    else
        Dx = divNonPeriodic(k, m, dx);
        Im = sparse(m+2, m);
        Im(2:(m+2)-1, :) = speye(m, m);
    end

    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    if isempty(qbt)
        Dy = divPeriodic(k, n, dy);
        In = speye(n, n);
    else
        Dy = divNonPeriodic(k, n, dy);
        In = sparse(n+2, n);
        In(2:(n+2)-1, :) = speye(n, n);
    end

    Sx = kron(In, Dx);
    Sy = kron(Dy, Im);
    
    D = [Sx Sy];
end
