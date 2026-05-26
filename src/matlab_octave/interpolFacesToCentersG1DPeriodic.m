function I = interpolFacesToCentersG1DPeriodic(k, m)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolFacesToCentersG1DPeriodic_impl(k, m);
end