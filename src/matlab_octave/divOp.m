function D = divOp(grid, k)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    D = divOp_impl(grid, k);
end