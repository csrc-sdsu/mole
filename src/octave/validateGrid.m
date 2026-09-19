function grid = validateGrid(grid, allowPartial)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    if nargin < 2
        allowPartial = false;
    end
    grid = validateGrid_impl(grid, allowPartial);
end