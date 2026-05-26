function [A, b] = addScalarBC1D_impl(A, b, k, m, dx, dc, nc, v)
% Canonical implementation for addScalarBC1D.

    % verify bc sizes and square linear system
    assert(all(size(dc) == [2 1]), 'dc is a 2x1 vector');
    assert(all(size(nc) == [2 1]), 'nc is a 2x1 vector');
    assert(size(A,1) == size(A,2), 'A is a square matrix');
    assert(size(A,2) == numel(b), 'b size = A columns');

    q = find(dc.*dc + nc.*nc,1);

    if ~isempty(q)
        % verify non-periodic boundata data size
        localAssertColumnVector(v, 2, 'v (1-D boundary values)', ...
            'addScalarBC1D:InvalidBoundaryValueSize', ...
            'For non-periodic BCs in 1-D, expected a 2-by-1 vector [left; right].');

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

function localAssertColumnVector(values, expectedRows, label, errId, context)
    actual = size(values);
    if ~all(actual == [expectedRows 1])
        error(errId, ...
              '%s expected size [%d 1], got [%d %d]. %s', ...
              label, expectedRows, actual(1), actual(2), context);
    end
end