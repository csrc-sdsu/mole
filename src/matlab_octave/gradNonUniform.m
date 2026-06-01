function G = gradNonUniform(k, ticks, dc, nc)
% Returns a one-dimensional non-uniform mimetic gradient operator
% depending on boundary condition type:
%                          a0 U + b0 dU/dn = g.
%
% Parameters:
%                k : Order of accuracy
%            ticks : Physical cell-center coordinates.
%                    Non-periodic: m+2 entries (includes ghost nodes).
%                    Periodic: m entries (interior cell centers only).
%    (optional) dc : a0 [left; right] Robin coefficient; all-zero -> periodic.
%    (optional) nc : b0 [left; right] Robin coefficient; all-zero -> periodic.
%
% Output: non-periodic -> (m+1)x(m+2); periodic -> mxm.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 && nargin ~= 4
        error('gradNonUniform:InvalidNumArgs', ...
              'gradNonUniform expects 2 or 4 arguments');
    end

    if nargin == 2
        periodic = 0;   % legacy: always non-periodic
    else
        periodic = all(dc == 0) & all(nc == 0);
    end

    ticks = ticks(:);   % forcing ticks to be a column vector

    if periodic
        m = length(ticks);
        G_ref = gradPeriodic(k, m, 1);
    else
        m = length(ticks) - 2;
        G_ref = grad(k, m, 1);
    end

    rows = size(G_ref, 1);
    J = spdiags((G_ref * ticks).^-1, 0, rows, rows);
    G = J * G_ref;
end
