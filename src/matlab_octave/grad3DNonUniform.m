function G = gradNonUniform3D(k, ticks_x, ticks_y, ticks_z, dc, nc)
% Returns a three-dimensional non-uniform mimetic gradient operator
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
%          ticks_z : Physical z-axis cell-center coordinates.
%                    Non-periodic: o+2 entries; periodic: o entries.
%    (optional) dc : a0 [left; right; bottom; top; front; back] Robin coefficient.
%                    Entries 1-2 all-zero -> periodic in x.
%                    Entries 3-4 all-zero -> periodic in y.
%                    Entries 5-6 all-zero -> periodic in z.
%    (optional) nc : b0 [left; right; bottom; top; front; back], same ordering as dc.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 6
        error('gradNonUniform3D:InvalidNumArgs', ...
              'gradNonUniform3D expects 4 or 6 arguments');
    end

    if nargin == 4
        xPer = 0; yPer = 0; zPer = 0;    % legacy: non-periodic all axes
        dc = [1; 1; 1; 1; 1; 1];          % default non-periodic Robin coefficients
        nc = [0; 0; 0; 0; 0; 0];
    else
        xPer = all(dc(1:2) == 0) & all(nc(1:2) == 0);
        yPer = all(dc(3:4) == 0) & all(nc(3:4) == 0);
        zPer = all(dc(5:6) == 0) & all(nc(5:6) == 0);
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

    % Build 1D gradient and grid selector for the z-axis
    if zPer
        o = length(ticks_z);
        Gz = gradNonUniform(k, ticks_z, dc(5:6), nc(5:6));
        Io = speye(o, o);
    else
        o = length(ticks_z) - 2;
        Gz = gradNonUniform(k, ticks_z, dc(5:6), nc(5:6));
        Io = sparse(o + 2, o);
        Io(2:(o+2)-1, :) = speye(o, o);
    end

    % Kronecker assembly:
    %   Sx = kron(kron(Io', In'), Gx) applies Gx along x for each (y,z) layer.
    %   Sy = kron(kron(Io', Gy), Im') applies Gy along y for each (x,z) layer.
    %   Sz = kron(kron(Gz, In'), Im') applies Gz along z for each (x,y) layer.
    Sx = kron(kron(Io', In'), Gx);
    Sy = kron(kron(Io', Gy), Im');
    Sz = kron(kron(Gz, In'), Im');
    G = [Sx; Sy; Sz];
end
