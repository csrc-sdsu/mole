function I = interpolD2D(m, n, c1, c2)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    if nargin < 4
        c2 = c1;
    end
    I = interpolD2D_impl(m, n, c1, c2);
end
