function G = gradNonUniform2D(k, ticks_x, ticks_y, dc, nc)
% Returns a two-dimensional non-uniform mimetic gradient operator
% depending on boundary condition type per axis:
%                          a0 U + b0 dU/dn = g.
%
% Parameters:
%                k : Order of accuracy
%          ticks_x : Physical x-axis cell-center coordinates.
%                    Non-periodic: m+2 entries (includes ghost nodes).
%                    Periodic: m entries (interior cell centers only).
%          ticks_y : Physical y-axis cell-center coordinates.
%                    Non-periodic: n+2 entries; periodic: n entries.
%    (optional) dc : a0 [left; right; bottom; top] Robin coefficient.
%                    Entries 1-2 all-zero -> periodic in x.
%                    Entries 3-4 all-zero -> periodic in y.
%    (optional) nc : b0 [left; right; bottom; top], same ordering as dc.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 3 && nargin ~= 5
        error('gradNonUniform2D:InvalidNumArgs', ...
              'gradNonUniform2D expects 3 or 5 arguments');
    end

    if nargin == 3
        xPer = 0; yPer = 0;        % legacy: non-periodic both axes
        dc = [1; 1; 1; 1];         % default non-periodic Robin coefficients
        nc = [0; 0; 0; 0];
    else
        xPer = all(dc(1:2) == 0) & all(nc(1:2) == 0);
        yPer = all(dc(3:4) == 0) & all(nc(3:4) == 0);
    end

    % Build 1D gradient and grid selector for the x-axis
    if xPer
        m = length(ticks_x);
        Gx = gradNonUniform(k, ticks_x, dc(1:2), nc(1:2));
        Im = speye(m, m);
    else
        m = length(ticks_x) - 2;
        Gx = gradNonUniform(k, ticks_x, dc(1:2), nc(1:2));
        Im = sparse(m + 2, m);
        Im(2:(m+2)-1, :) = speye(m, m);
    end

    % Build 1D gradient and grid selector for the y-axis
    if yPer
        n = length(ticks_y);
        Gy = gradNonUniform(k, ticks_y, dc(3:4), nc(3:4));
        In = speye(n, n);
    else
        n = length(ticks_y) - 2;
        Gy = gradNonUniform(k, ticks_y, dc(3:4), nc(3:4));
        In = sparse(n + 2, n);
        In(2:(n+2)-1, :) = speye(n, n);
    end

    % Kronecker assembly: Sx applies Gx along x for each y-layer;
    %                     Sy applies Gy along y for each x-column.
    Sx = kron(In', Gx);
    Sy = kron(Gy, Im');
    G = [Sx; Sy];
end
