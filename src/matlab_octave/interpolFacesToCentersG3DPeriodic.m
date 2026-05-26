function I = interpolFacesToCentersG3DPeriodic(k, m, n, o)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolFacesToCentersG3DPeriodic_impl(k, m, n, o);
end