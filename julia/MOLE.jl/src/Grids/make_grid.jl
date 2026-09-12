#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

"""
    makeGrid(grid::Grid; allowPartial::Bool = true)
    makeGrid(; allowPartial::Bool = true, kwargs...)

Construct and validate a computational grid.

`makeGrid` is the primary constructor for `Grid` objects. It accepts either an
existing `Grid` instance or keyword arguments describing the computational
domain. The resulting grid is validated, normalized, and enriched with derived
metadata such as the spatial dimension, topology, coordinate arrays, and
boundary-condition information.

# Arguments

- `grid::Grid`: An existing grid to validate and normalize.
- `allowPartial::Bool=true`: If `true`, allows partially specified grids to be
  created without requiring all fields. This is primarily intended for
  incremental grid construction or internal use.

When called with keyword arguments, commonly used parameters include:

- `m`, `n`, `o`: Number of cells in each spatial direction.
- `dx`, `dy`, `dz`: Grid spacing in each spatial direction.
- `topology`: Grid topology (e.g. `:uniform`, `:periodic`, `:curvilinear`).
- `nodes`: User-supplied nodal coordinates for curvilinear grids.
- `bc`: Boundary-condition metadata.

# Returns

A validated [`Grid`](@ref) object.

# Examples

Construct a one-dimensional uniform grid:

```julia
grid = makeGrid(
    m = 100,
    dx = 0.01,
)
```

Construct a two-dimensional uniform grid:

```julia
grid = makeGrid(
    m = 64,
    n = 64,
    dx = 1/64,
    dy = 1/64,
)
```

Construct a curvilinear grid from user-defined nodal coordinates:

```julia
grid = makeGrid(
    m = m,
    n = n,
    topology = :curvilinear,
    nodes = (X = X, Y = Y),
)
```

# Notes

`makeGrid` delegates the validation and normalization of all inputs to
[`validateGrid`](@ref).
"""
function makeGrid(grid::Grid; allowPartial::Bool = true)
    return validateGrid(grid; allowPartial = allowPartial)
end

function makeGrid(; allowPartial::Bool = true, kwargs...)
    raw = Dict{Symbol, Any}(kwargs)
    return validateGrid(raw; allowPartial = allowPartial)
end
