function [A, b] = addScalarBC2D_impl(A, b, k, m, dx, n, dy, dc, nc, v)
% Canonical implementation for addScalarBC2D.

    % verify bc sizes and square linear system
    assert(all(size(dc) == [4 1]), 'dc is a 4x1 vector');
    assert(all(size(nc) == [4 1]), 'nc is a 4x1 vector');
    assert(all(size(v) == [4 1]), 'v is a 4x1 vector');
    assert(all(size(A,1) == size(A,2)), 'A is a square matrix');
    assert(all(size(A,2) == numel(b)), 'b size = A columns');

    % A and b changes depend on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);

    % verify bc data sizes for non-periodic boundary condition
    if ~isempty(qrl)
        localAssertColumnVector(v{1}, n, 'v{1} (left boundary values)', ...
            'addScalarBC2D:InvalidBoundaryValueSize', ...
            'For non-periodic left/right BCs in 2-D, expected n-by-1.');
        localAssertColumnVector(v{2}, n, 'v{2} (right boundary values)', ...
            'addScalarBC2D:InvalidBoundaryValueSize', ...
            'For non-periodic left/right BCs in 2-D, expected n-by-1.');
    end

    if ~isempty(qbt)
        if ~isempty(qrl)
            localAssertColumnVector(v{3}, m+2, 'v{3} (bottom boundary values)', ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'When x is non-periodic, bottom/top vectors include boundary nodes and must be (m+2)-by-1.');
            localAssertColumnVector(v{4}, m+2, 'v{4} (top boundary values)', ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'When x is non-periodic, bottom/top vectors include boundary nodes and must be (m+2)-by-1.');
        else
            localAssertColumnVector(v{3}, m, 'v{3} (bottom boundary values)', ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'When x is periodic, bottom/top vectors must be m-by-1 (interior x-cells only).');
            localAssertColumnVector(v{4}, m, 'v{4} (top boundary values)', ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'When x is periodic, bottom/top vectors must be m-by-1 (interior x-cells only).');
        end
    end

    rl = 0; rr = 0; rb = 0; rt = 0; % periodic case

    % get modifications of A for left, right, bottom, top edges, resp.
    [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc);

    % get rhs entries affected by bcs for left, right, bottom, top edges, resp.
    if ~isempty(qrl)
        [rl,~,~] = find(Abcl);
        [rr,~,~] = find(Abcr);
        rl = unique(rl);
        rr = unique(rr);
        % remove rows of A associated to boundary
        Abc1 = Abcl + Abcr;
        [rowsbc1,~,~] = find(Abc1);
        [rows1,cols1,s1] = find(A(rowsbc1,:));
        A = A - sparse(rows1, cols1, s1, size(A,1), size(A,2));
        % update matrix A with boundary information
        A = A + Abc1;
        % remove b entries associated to bcs
        b(rowsbc1) = 0;
    end

    if ~isempty(qbt)
        [rb,~,~] = find(Abcb);
        [rt,~,~] = find(Abct);
        rb = unique(rb);
        rt = unique(rt);
        % remove rows of A associated to boundary
        Abc2 = Abct + Abcb;
        [rowsbc2,~,~] = find(Abc2);
        [rows2,cols2,s2] = find(A(rowsbc2,:));
        A = A - sparse(rows2, cols2, s2, size(A,1), size(A,2));
        % update matrix A with boundary information
        A = A + Abc2;
        % remove b entries associated to bcs
        b(rowsbc2) = 0;
    end

    % update b with boundary information
    if ~(isempty(qrl) && isempty(qbt))
        b = addScalarBC2Drhs(b, dc, nc, v, rl, rr, rb, rt);
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