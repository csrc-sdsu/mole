function [A, b] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)
% PURPOSE
% This function assumes that the unknown u, which represents the discrete
% solution the continuous second-order 3D PDE operator 
%                                   L U = f, 
% with continuous boundary condition 
%                              a0 U + b0 dU/dn = g,
% are given at the 3D cell centers and boundary face centers. Furthermore,
% all discrete calculations are performed at the 3D cell centers and boundary 
% face centers.
%
% DESCRIPTION
% The function receives as input quantities associated to the discrete
% analog of the continuous problem given by the squared linear system 
%                                 A u = b 
% where A is the discrete analog of L and b is the discrete analog of g,
% both constructed by the user without boundary conditions.
% The function output is the modified square linear system 
%                                 A u = b
% where both A and b include boundary condition information.
%
% The boundary condition is always one of the following forms:
%
% For Dirichlet set: a0 not equal zero and b0 = 0.
% For Neumann set  : a0 = 0 and b0 not equal zero.
% For Robin set    : both a0 and b0 not equal zero.
% For Periodic set : both a0 = 0 and b0 = 0.
%
% For periodic bc, it is assumed that not only u but also du/dn are the same 
% in both extremes of the domain since a second-order PDE is assumed.
%
% Periodic boundary conditions can be applied along some axes and
% non-periodic to some others.
% 
% For consistence with the way boundary operators are calculated to avoid 
% overwriting of the values v, the left and right boundary conditions are
% assumed to be column vectors of n*o components, the bottom and top
% boundary conditions are assumed to be column vectors of (m+2)*o
% components, and the front and back faces are assumed to be vectors of
% (m+2)*(n+2) components. 
%
% The order of these components is as follows:
% For left and right faces, the ordering is the one by columns of the
% matrix where y increase along rows, and z increase along columns.
% For bottom and top faces, the ordering is the one by columns of the
% matrix where x increase along rows, and z increase along columns.
% For front and back faces, the ordering is the one by columns of the
% matrix where x increase along rows, and y increase along columns.
% 
% The code assumes the following assertions:
% assert(k >= 2, 'k >= 2');
% assert(mod(k, 2) == 0, 'k % 2 = 0');
% assert(m >= 2*k+1, ['m >= ' num2str(2*k+1) ' for k = ' num2str(k)]);
%
% Parameters:
% output
%         A : Linear operator with boundary conditions added
%         b : Right hand side with boundary conditions added
%
% input
%         A : Linear operator without boundary conditions added
%         b : Right hand side without boundary conditions added
%         k : Order of accuracy
%         m : Number of horizontal cells
%        dx : Step size of horizontal
%         n : Number of vertical cells
%        dy : Step size of vertical cells
%         o : Number of depth cells
%        dz : Step size of depth cells
%        dc : a0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%        nc : b0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%         v : g (6x1 vector of arrays for left, right, bottom, top, front, back boundaries, resp.)
%      grid : Struct carrying at least grid.m, grid.n, grid.o, grid.dx,
%             grid.dy, grid.dz, and grid.bc.{dc,nc}.
%
% SYNTAX
% [A, b] = addScalarBC3D(A, b, k, grid, v)
% [A, b] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------    
%

    if nargin == 5
        if isstruct(m)
            % Preferred grid-signature call shape is addScalarBC3D(A, b, k, grid, v).
            grid = validateGrid(m);
            v = dx;
        elseif isstruct(k)
            % Backward-compatible legacy grid-signature:
            % addScalarBC3D(A, b, grid, k, v).
            grid = validateGrid(k);
            k = m;
            v = dx;
        else
            error('addScalarBC3D:InvalidGridSignature', ...
                  'For 5-input form, use addScalarBC3D(A, b, k, grid, v).');
        end

        m = grid.m;
        dx = grid.dx;
        n = grid.n;
        dy = grid.dy;
        o = grid.o;
        dz = grid.dz;
        dc = grid.bc.dc;
        nc = grid.bc.nc;
    end

    ensureMatlabOctaveSubdirs();
    [A, b] = addScalarBC3D_impl(A, b, k, m, dx, n, dy, o, dz, dc, nc, v);
end
