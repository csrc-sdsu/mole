function [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs_impl(k, m, dx, n, dy, o, dz, dc, nc)
    Abcl = 0; Abcr = 0; Abcb = 0; Abct = 0; Abcf = 0; Abcz = 0;

    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);

    if ~isempty(qrl)
        [Abcl0,Abcr0] = addScalarBC1Dlhs(k, m, dx, dc(1:2,1), nc(1:2,1));
        if isempty(qbt)
            In = speye(n);
        else
            In = speye(n+2);
            In(1, 1) = 0;
            In(end, end) = 0;
        end
        if isempty(qzf)
            Io = speye(o);
        else
            Io = speye(o+2);
            Io(1, 1) = 0;
            Io(end, end) = 0;
        end
        Abcl = kron(kron(Io, In), Abcl0);
        Abcr = kron(kron(Io, In), Abcr0);
    end

    if ~isempty(qbt)
        [Abcb0,Abct0] = addScalarBC1Dlhs(k, n, dy, dc(3:4,1), nc(3:4,1));
        if isempty(qrl)
            Im = speye(m);
        else
            Im = speye(m+2);
        end
        if isempty(qzf)
            Io = speye(o);
        else
            Io = speye(o+2);
            Io(1, 1) = 0;
            Io(end, end) = 0;
        end
        Abcb = kron(kron(Io, Abcb0), Im);
        Abct = kron(kron(Io, Abct0), Im);
    end

    if ~isempty(qzf)
        [Abcf0,Abcz0] = addScalarBC1Dlhs(k, o, dz, dc(5:6,1), nc(5:6,1));
        if isempty(qrl)
            Im = speye(m);
        else
            Im = speye(m+2);
        end
        if isempty(qbt)
            In = speye(n);
        else
            In = speye(n+2);
        end
        Abcf = kron(kron(Abcf0, In), Im);
        Abcz = kron(kron(Abcz0, In), Im);
    end
end