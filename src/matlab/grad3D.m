function G = grad3D(k, m, dx, n, dy, o, dz, dc, nc)
% Returns a three-dimensional mimetic gradient operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
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
        error('grad3D:InvalidNumArgs', 'grad3D expects 7 or 9 arguments');
    end
    
    % for legacy code
    if nargin == 7
        G = gradNonPeriodic3D(k, m, dx, n, dy, o, dz);
        return;
    end

    % verify bc-type sizes
    assert(all(size(dc) == [6 1]), 'dc is a 6x1 vector');
    assert(all(size(nc) == [6 1]), 'nc is a 6x1 vector');

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

    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);
    if isempty(qzf)
        Gz = gradPeriodic(k, o, dz);
        Io = speye(o, o);
    else
        Gz = gradNonPeriodic(k, o, dz);
        Io = sparse(o+2, o);
        Io(2:(o+2)-1, :) = speye(o, o);
    end
    
    Sx = kron(kron(Io', In'), Gx);
    Sy = kron(kron(Io', Gy), Im');
    Sz = kron(kron(Gz, In'), Im');
    
    G = [Sx; Sy; Sz];
end
