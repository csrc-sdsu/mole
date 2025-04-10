function D = divGral3D(k, m, dx, n, dy, o, dz, dc, nc)
% Returns a three-dimensional mimetic divergence operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%               dc : a0 (2x1 vector for left and right vertices, resp.)
%               nc : b0 (2x1 vector for left and right vertices, resp.)
%                o : Number of cells along z-axis
%               dz : Step size along z-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % verify bc-type sizes
    assert(all(size(dc) == [6 1]), 'dc is a 6x1 vector');
    assert(all(size(nc) == [6 1]), 'nc is a 6x1 vector');

    % D depends on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    if isempty(qrl)
        Dx = divPeriodic(k, m, dx);
        Im = speye(m, m);
    else
        Dx = div(k, m, dx);
        Im = sparse(m+2, m);
        Im(2:(m+2)-1, :) = speye(m, m);
    end

    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    if isempty(qbt)
        Dy = divPeriodic(k, n, dy);
        In = speye(n, n);
    else
        Dy = div(k, n, dy);
        In = sparse(n+2, n);
        In(2:(n+2)-1, :) = speye(n, n);
    end

    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);
    if isempty(qzf)
        Dz = divPeriodic(k, o, dz);
        Io = speye(o, o);
    else
        Dz = div(k, o, dz);
        Io = sparse(o+2, o);
        Io(2:(o+2)-1, :) = speye(o, o);
    end
    
    Sx = kron(kron(Io, In), Dx);
    Sy = kron(kron(Io, Dy), Im);
    Sz = kron(kron(Dz, In), Im);
    
    D = [Sx Sy Sz];
end
