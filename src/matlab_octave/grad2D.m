function G = grad2D(k, m, dx, n, dy, dc, nc)
% Returns a two-dimensional mimetic gradient operator depending on whether
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
        error('grad2D:InvalidNumArgs', 'grad2D expects 5 or 7 arguments');
    end
    
    % for legacy code
    if nargin == 5
        G = gradNonPeriodic2D(k, m, dx, n, dy);
        return;
    end

    % verify bc-type sizes
    assert(all(size(dc) == [4 1]), 'dc is a 4x1 vector');
    assert(all(size(nc) == [4 1]), 'nc is a 4x1 vector');

    % G depends on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    if isempty(qrl)
        Gx = gradPeriodic(k, m, dx);
        Im = speye(m, m);
    else
        Gx = gradNonPeriodic(k, m, dx);
        Im = sparse(m+2, m);
        Im(2:(m+2)-1, :) = speye(m, m);
    end

    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    if isempty(qbt)
        Gy = gradPeriodic(k, n, dy);
        In = speye(n, n);
    else
        Gy = gradNonPeriodic(k, n, dy);
        In = sparse(n+2, n);
        In(2:(n+2)-1, :) = speye(n, n);
    end

    Sx = kron(In', Gx);
    Sy = kron(Gy, Im');
    
    G = [Sx; Sy];
end
