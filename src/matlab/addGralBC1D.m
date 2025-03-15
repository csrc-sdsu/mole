function [A, b] = addGralBC1D(A, b, k, m, dx, dc, nc, v)
% Separates cases non-periodic and periodic for dealing with boundary data
%
% Parameters:
% output
%        A0 : Linear operator with boundary conditions added
%        b0 : Right hand side with boundary conditions added
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
        
        [Abcl,Abcr] = addGralBC1Dlhs(k, m, dx, dc, nc);
        A = A + Abcl + Abcr;
        b = addGralBC1Drhs(b, v, vec);
    end
end
