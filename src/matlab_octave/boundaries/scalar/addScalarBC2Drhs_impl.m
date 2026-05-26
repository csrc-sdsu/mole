function b = addScalarBC2Drhs_impl(b, dc, nc, v, rl, rr, rb, rt)
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
end