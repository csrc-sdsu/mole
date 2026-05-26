function N = nodalOp(grid, k)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    N = nodalOp_impl(grid, k);
end