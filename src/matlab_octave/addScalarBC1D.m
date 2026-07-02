function [A, b] = addScalarBC1D(A, b, k, m, dx, dc, nc, v)
% PURPOSE
% This function assumes that the unknown u, which represents the discrete
% solution of the continuous second-order 1D PDE
%                                   L u = f,
% with continuous boundary condition
%                              a0 u + b0 du/dn = g,
% is given at the 1D cell centers and boundary face centers. Furthermore,
% all discrete calculations are performed at the 1D cell centers and boundary
% face centers.
%
% DESCRIPTION
% The function receives as input quantities associated with the discrete
% analog of the continuous problem given by the square linear system
%                                 A u = b
% where A is the discrete analog of L and b is the discrete analog of g,
% both constructed by the user without boundary conditions.
% The function output is the modified square linear system
%                                 A u = b
% where both A and b include boundary condition information.
%
% The boundary condition is always one of the following forms:
%
% For Dirichlet set: a0 not equal to zero and b0 = 0.
% For Neumann set  : a0 = 0 and b0 not equal to zero.
% For Robin set    : both a0 and b0 not equal to zero.
% For Periodic set : both a0 = 0 and b0 = 0.
%
% For periodic bc, it is assumed that not only u but also du/dn are the
% same at both ends of the domain since a second-order PDE is assumed.
%
% dc, nc, and v are each 2x1 vectors ordered [left; right], giving a0, b0,
% and g respectively at the left and right boundary of the 1D domain.
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
%         m : Number of cells
%        dx : Step size
%        dc : a0 (2x1 vector for left and right vertices, resp.)
%        nc : b0 (2x1 vector for left and right vertices, resp.)
%         v : g (2x1 vector for left and right vertices, resp.)
%
% SYNTAX
% [A, b] = addScalarBC1D(A, b, k, m, dx, dc, nc, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
% 

    % verify bc sizes and square linear system
    assert(all(size(dc) == [2 1]), 'dc is a 2x1 vector');
    assert(all(size(nc) == [2 1]), 'nc is a 2x1 vector');
    assert(size(A,1) == size(A,2), 'A is a square matrix');
    assert(size(A,2) == numel(b), 'b size = A columns');

    q = find(dc.*dc + nc.*nc,1);

    if ~isempty(q)
        % verify non-periodic boundata data size
        assert(all(size(v) == [2 1]), 'v is a 2x1 vector');
    
        % remove first and last rows of A
        vec = sparse(2,1);
        vec(1) = 1;
        vec(2) = size(A,1);
    
        [rows,cols,s] = find(A(vec,:));
        A = A - sparse(vec(rows), cols, s, size(A,1), size(A,2));
    
        % remove first and last coefficients of right-hand-side vector b
        b(vec) = 0;
        
        [Abcl,Abcr] = addScalarBC1Dlhs(k, m, dx, dc, nc);
        A = A + Abcl + Abcr;
        b = addScalarBC1Drhs(b, v, vec);
    end
end
