function I = interpolCentersToFacesD3DPeriodic(k, m, n, o)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolCentersToFacesD3DPeriodic_impl(k, m, n, o);
end