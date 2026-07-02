function grid = makeGrid(varargin)
% Backward-compatible entry point that delegates to v2 implementation.
    ensureMatlabOctaveSubdirs();
    grid = makeGrid_impl(varargin{:});
end