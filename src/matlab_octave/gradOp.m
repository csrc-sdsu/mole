function G = gradOp(grid, k)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    G = gradOp_impl(grid, k);
end