function I = interpol(m, c)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpol_impl(m, c);
end
