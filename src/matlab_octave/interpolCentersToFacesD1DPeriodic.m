function I = interpolCentersToFacesD1DPeriodic(k, m)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolCentersToFacesD1DPeriodic_impl(k,m);
end