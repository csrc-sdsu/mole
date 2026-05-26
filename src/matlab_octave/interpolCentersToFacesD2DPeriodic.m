function I = interpolCentersToFacesD2DPeriodic(k, m, n)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolCentersToFacesD2DPeriodic_impl(k, m, n);
end