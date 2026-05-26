function [A, b] = addScalarBC1D(A, b, k, m, dx, dc, nc, v)
% PURPOSE
% Separates cases non-periodic and periodic for dealing with boundary data
%
% DESCRIPTION
% Parameters:
% output
%        A0 : Linear operator with boundary conditions added
%        b0 : Right hand side with boundary conditions added
%
% input
%         A : Linear operator without boundary conditions added
%         b : Right hand side without boundary conditions added
%         k : Order of accuracy of the operator
%         m : Number of cells in the x direction
%        dx : Step size
%        dc : a0 (2x1 vector for left and right vertices, resp.)
%        nc : b0 (2x1 vector for left and right vertices, resp.)
%         v : g (2x1 vector for left and right vertices, resp.)
%      grid : Struct carrying at least grid.m, grid.dx, and
%             grid.bc.{dc,nc}.
%
% SYNTAX
% [A, b] = addScalarBC1D(A, b, k, grid, v)
% [A, b] = addScalarBC1D(A, b, k, m, dx, dc, nc, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    if nargin == 5
        if isstruct(m)
            % Preferred grid-signature call shape is addScalarBC1D(A, b, k, grid, v).
            grid = validateGrid(m);
            v = dx;
        elseif isstruct(k)
            % Backward-compatible legacy grid-signature:
            % addScalarBC1D(A, b, grid, k, v).
            grid = validateGrid(k);
            k = m;
            v = dx;
        else
            error('addScalarBC1D:InvalidGridSignature', ...
                  'For 5-input form, use addScalarBC1D(A, b, k, grid, v).');
        end

        m = grid.m;
        dx = grid.dx;
        dc = grid.bc.dc;
        nc = grid.bc.nc;
    end

    ensureMatlabOctaveSubdirs();
    [A, b] = addScalarBC1D_impl(A, b, k, m, dx, dc, nc, v);
end
