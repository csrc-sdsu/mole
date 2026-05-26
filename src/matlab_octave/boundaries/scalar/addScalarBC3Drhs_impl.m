function b = addScalarBC3Drhs_impl(b, dc, nc, v, rl, rr, rb, rt, rf, rz)
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    if ~isempty(qrl)
        b(rl,1) = v{1};
        b(rr,1) = v{2};
    end

    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    if ~isempty(qbt)
        b(rb,1) = v{3};
        b(rt,1) = v{4};
    end

    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);
    if ~isempty(qzf)
        b(rf,1) = v{5};
        b(rz,1) = v{6};
    end
end