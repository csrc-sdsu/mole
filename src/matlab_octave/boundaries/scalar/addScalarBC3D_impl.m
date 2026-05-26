function [A, b] = addScalarBC3D_impl(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)
% Canonical implementation for addScalarBC3D.

    % verify bc sizes and square linear system
    assert(all(size(dc) == [6 1]), 'dc is a 6x1 vector');
    assert(all(size(nc) == [6 1]), 'nc is a 6x1 vector');
    assert(all(size(v) == [6 1]), 'v is a 6x1 vector');
    assert(all(size(A,1) == size(A,2)), 'A is a square matrix');
    assert(all(size(A,2) == numel(b)), 'b size = A columns');

    % A and b changes depend on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);

    if ~isempty(qrl)
        localAssertColumnVector(v{1}, o*n, 'v{1} (left boundary values)', ...
            'addScalarBC3D:InvalidBoundaryValueSize', ...
            'For non-periodic x-boundaries, left/right vectors must be (o*n)-by-1.');
        localAssertColumnVector(v{2}, o*n, 'v{2} (right boundary values)', ...
            'addScalarBC3D:InvalidBoundaryValueSize', ...
            'For non-periodic x-boundaries, left/right vectors must be (o*n)-by-1.');
    end

    if ~isempty(qbt)
        if ~isempty(qrl)
            localAssertColumnVector(v{3}, o*(m+2), 'v{3} (bottom boundary values)', ...
                'addScalarBC3D:InvalidBoundaryValueSize', ...
                'When x is non-periodic, bottom/top vectors must be (o*(m+2))-by-1.');
            localAssertColumnVector(v{4}, o*(m+2), 'v{4} (top boundary values)', ...
                'addScalarBC3D:InvalidBoundaryValueSize', ...
                'When x is non-periodic, bottom/top vectors must be (o*(m+2))-by-1.');
        else
            localAssertColumnVector(v{3}, o*m, 'v{3} (bottom boundary values)', ...
                'addScalarBC3D:InvalidBoundaryValueSize', ...
                'When x is periodic, bottom/top vectors must be (o*m)-by-1.');
            localAssertColumnVector(v{4}, o*m, 'v{4} (top boundary values)', ...
                'addScalarBC3D:InvalidBoundaryValueSize', ...
                'When x is periodic, bottom/top vectors must be (o*m)-by-1.');
        end
    end

    if ~isempty(qzf)
        if ~isempty(qrl)
            if ~isempty(qbt)
                localAssertColumnVector(v{5}, (n+2)*(m+2), 'v{5} (front boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x and y are non-periodic, front/back vectors must be ((n+2)*(m+2))-by-1.');
                localAssertColumnVector(v{6}, (n+2)*(m+2), 'v{6} (back boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x and y are non-periodic, front/back vectors must be ((n+2)*(m+2))-by-1.');
            else
                localAssertColumnVector(v{5}, n*(m+2), 'v{5} (front boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When y is periodic and x is non-periodic, front/back vectors must be (n*(m+2))-by-1.');
                localAssertColumnVector(v{6}, n*(m+2), 'v{6} (back boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When y is periodic and x is non-periodic, front/back vectors must be (n*(m+2))-by-1.');
            end
        else
            if ~isempty(qbt)
                localAssertColumnVector(v{5}, (n+2)*m, 'v{5} (front boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x is periodic and y is non-periodic, front/back vectors must be ((n+2)*m)-by-1.');
                localAssertColumnVector(v{6}, (n+2)*m, 'v{6} (back boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x is periodic and y is non-periodic, front/back vectors must be ((n+2)*m)-by-1.');
            else
                localAssertColumnVector(v{5}, n*m, 'v{5} (front boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x and y are periodic, front/back vectors must be (n*m)-by-1.');
                localAssertColumnVector(v{6}, n*m, 'v{6} (back boundary values)', ...
                    'addScalarBC3D:InvalidBoundaryValueSize', ...
                    'When x and y are periodic, front/back vectors must be (n*m)-by-1.');
            end
        end
    end

    rl = 0; rr = 0; rb = 0; rt = 0; rf = 0; rz = 0; % periodic case

    % get modifications of A for left, right, bottom, top, front, back faces, resp.
    [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc);

    % get rhs entries affected by bcs for left, right, bottom, top, front, back faces, resp.
    if ~isempty(qrl)
        [rl,~,~] = find(Abcl);
        [rr,~,~] = find(Abcr);
        rl = unique(rl);
        rr = unique(rr);
        Abc1 = Abcl + Abcr;
        [rowsbc1,~,~] = find(Abc1);
        [rows1,cols1,s1] = find(A(rowsbc1,:));
        A = A - sparse(rows1, cols1, s1, size(A,1), size(A,2));
        A = A + Abc1;
        b(rowsbc1) = 0;
    end

    if ~isempty(qbt)
        [rb,~,~] = find(Abcb);
        [rt,~,~] = find(Abct);
        rb = unique(rb);
        rt = unique(rt);
        Abc2 = Abct + Abcb;
        [rowsbc2,~,~] = find(Abc2);
        [rows2,cols2,s2] = find(A(rowsbc2,:));
        A = A - sparse(rows2, cols2, s2, size(A,1), size(A,2));
        A = A + Abc2;
        b(rowsbc2) = 0;
    end

    if ~isempty(qzf)
        [rz,~,~] = find(Abcz);
        [rf,~,~] = find(Abcf);
        rf = unique(rf);
        rz = unique(rz);
        Abc3 = Abcf + Abcz;
        [rowsbc3,~,~] = find(Abc3);
        [rows3,cols3,s3] = find(A(rowsbc3,:));
        A = A - sparse(rows3, cols3, s3, size(A,1), size(A,2));
        A = A + Abc3;
        b(rowsbc3) = 0;
    end

    if ~(isempty(qrl) && isempty(qbt) && isempty(qzf))
        b = addScalarBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz);
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