function I = interpolCentersToFacesD1D(k, m)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    I = interpolCentersToFacesD1D_impl(k, m);
end