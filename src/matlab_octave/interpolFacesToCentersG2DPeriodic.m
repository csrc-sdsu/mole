function I = interpolFacesToCentersG2DPeriodic(k, m, n)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolFacesToCentersG2DPeriodic_impl(k, m, n);
end