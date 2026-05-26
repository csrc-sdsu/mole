function I = interpolCentersToFacesD2D(k, m, n, dc, nc)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    if nargin == 3
        I = interpolCentersToFacesD2D_impl(k, m, n);
    else
        I = interpolCentersToFacesD2D_impl(k, m, n, dc, nc);
    end
end