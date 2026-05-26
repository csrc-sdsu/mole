function I = interpolD3D(m, n, o, c1, c2, c3)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    if isstruct(m) && nargin == 4
        c2 = c1;
        c3 = c1;
    elseif nargin < 6
        c3 = c2;
    end
    I = interpolD3D_impl(m, n, o, c1, c2, c3);
end
