function L = lapOp(grid, k)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    L = lapOp_impl(grid, k);
end