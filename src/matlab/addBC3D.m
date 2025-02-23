function [A, b] = addBC3D(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)
% This function assumes that the unknown u, which represents the discrete
% solution the continuous second-order 3D PDE operator 
%                                   L U = f, 
% with continuous boundary condition 
%                              a0 U + b0 dU/dn = g,
% are given at the 3D cell centers and boundary face centers. Furthermore,
% all discrete calculations are performed at the 3D cell centers and boundary 
% face centers.
%
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
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % verify bc sizes and square linear system
    assert(all(size(dc) == [6 1]), 'dc is a 6x1 vector');
    assert(all(size(nc) == [6 1]), 'nc is a 6x1 vector');
    assert(all(size(v) == [6 1]), 'v is a 6x1 vector');
    cellsz = cellfun(@size,v,'uni',false);
    assert(all(cellsz{1} == [o*n 1]), 'v{1} is a (o*n)x1 vector'); % left
    assert(all(cellsz{2} == [o*n 1]), 'v{2} is a (o*n)x1 vector'); % right
    assert(all(cellsz{3} == [o*(m+2) 1]), 'v{3} is a (o*(m+2))x1 vector'); % bottom
    assert(all(cellsz{4} == [o*(m+2) 1]), 'v{4} is a (o*(m+2))x1 vector'); % top
    assert(all(cellsz{5} == [(n+2)*(m+2) 1]), 'v{5} is a ((n+2)*(m+2))x1 vector'); % front
    assert(all(cellsz{6} == [(n+2)*(m+2) 1]), 'v{6} is a ((n+2)*(m+2))x1 vector'); % back
    assert(all(size(A,1) == size(A,2)), 'A is a square matrix');
    assert(all(size(A,2) == numel(b)), 'b size = A columns');

    % get modifications of A for left, right, bottom, top, front, back faces, resp.
    [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc);

    % get rhs entries affected by bcs for left, right, bottom, top, front, back faces, resp.
    [rl,~,~] = find(Abcl); 
    [rr,~,~] = find(Abcr); 
    [rb,~,~] = find(Abcb); 
    [rt,~,~] = find(Abct); 
    [rf,~,~] = find(Abcf); 
    [rz,~,~] = find(Abcz); 
    rl = unique(rl);
    rr = unique(rr);
    rb = unique(rb);
    rt = unique(rt);
    rf = unique(rf);
    rz = unique(rz);

    % remove rows from matrix A
    Abc = Abcl + Abcr + Abcb + Abct + Abcz + Abcf;
    [rowsbc,~,~] = find(Abc);
    rowsbc = unique(rowsbc);
    [rows,cols,s] = find(A(rowsbc,:));
    A = A - sparse(rows, cols, s, size(A,1), size(A,2));
    % update matrix A with boundary information
    A = A + Abc;

    % remove b entries associated to bcs
    b(rowsbc) = 0;
    % update b with boundary information
    b = addBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz);
end
