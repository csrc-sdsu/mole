function [A, b] = addBC1D(A, b, k, m, dx, dc, nc, v)
% This function assumes that the unknown u, which represents the discrete
% solution the continuous second-order 1D PDE operator 
%                                   L U = f, 
% with continuous boundary condition 
%                              a0 U + b0 dU/dn = g,
% are given at the 1D cell centers and vertices. Furthermore, all discrete 
% calculations are performed at the 1D cell centers and vertices.
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

    % verify bc sizes and square linear system
    assert(all(size(dc) == [2 1]), 'dc is a 2x1 vector');
    assert(all(size(nc) == [2 1]), 'nc is a 2x1 vector');
    assert(all(size(v) == [2 1]), 'v is a 2x1 vector');
    assert(size(A,1) == size(A,2), 'A is a square matrix');
    assert(size(A,2) == numel(b), 'b size = A columns');

    % remove first and last rows of A
    vec = sparse(2,1);
    vec(1) = 1;
    vec(2) = size(A,1);

    [rows,cols,s] = find(A(vec,:));
    A = A - sparse(vec(rows), cols, s, size(A,1), size(A,2));

    % remove first and last coefficients of right-hand-side vector b
    b(vec) = 0;
    
    [Abcl,Abcr] = addBC1Dlhs(k, m, dx, dc, nc);
    A = A + Abcl + Abcr;
    b = addBC1Drhs(b, dc, nc, v, vec);
end
