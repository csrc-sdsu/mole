function [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs_impl(k, m, dx, n, dy, dc, nc)
    Abcl = 0; Abcr = 0; Abcb = 0; Abct = 0;

    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);

    if ~isempty(qrl)
        [Abcl0,Abcr0] = addScalarBC1Dlhs(k, m, dx, dc(1:2,1), nc(1:2,1));
        if isempty(qbt)
            In = speye(n);
        else
            In = speye(n+2);
            In(1, 1) = 0;
            In(end, end) = 0;
        end
        Abcl = kron(In, Abcl0);
        Abcr = kron(In, Abcr0);
    end

    if ~isempty(qbt)
        [Abcb0,Abct0] = addScalarBC1Dlhs(k, n, dy, dc(3:4,1), nc(3:4,1));
        if isempty(qrl)
            Im = speye(m);
        else
            Im = speye(m+2);
        end
        Abcb = kron(Abcb0, Im);
        Abct = kron(Abct0, Im);
    end
end