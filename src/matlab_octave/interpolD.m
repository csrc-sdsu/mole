function I = interpolD(m, c)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolD_impl(m, c);
end
