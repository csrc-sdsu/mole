function I = interpolFacesToCentersG1D(k, m)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolFacesToCentersG1D_impl(k, m);
end