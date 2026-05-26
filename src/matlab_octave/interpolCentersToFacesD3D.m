function I = interpolCentersToFacesD3D(k, m, n, o, dc, nc)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    if nargin == 4
        I = interpolCentersToFacesD3D_impl(k, m, n, o);
    else
        I = interpolCentersToFacesD3D_impl(k, m, n, o, dc, nc);
    end
end