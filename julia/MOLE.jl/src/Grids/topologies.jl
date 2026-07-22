#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

abstract type AbstractGrid end

"""
    BoundaryMetadata{T}

Stores the boundary-condition metadata associated with a computational grid.

`BoundaryMetadata` is used by [`Grid`](@ref) and contains the coefficients
required to define scalar boundary conditions, together with flags indicating
whether each coordinate direction is periodic.

# Fields

- `dc::Vector{T}`: Dirichlet coefficients for each boundary.
- `nc::Vector{T}`: Neumann coefficients for each boundary.
- `isPeriodic::Vector{Bool}`: Periodicity flags for each coordinate direction.
- `hasData::Bool`: Indicates whether boundary-condition information has been
  explicitly provided.

The expected lengths of `dc` and `nc` depend on the grid dimension:

| Dimension | Length |
|:----------|:------:|
| 1D | 2 |
| 2D | 4 |
| 3D | 6 |

The length of `isPeriodic` is equal to the number of spatial dimensions.

# Examples

```julia
bc = BoundaryMetadata(
    dc = [1.0, 1.0],
    nc = [0.0, 0.0],
    isPeriodic = [false],
    hasData = true,
)
```

A periodic one-dimensional grid can be represented by zero Dirichlet and
Neumann coefficients:

```julia
bc = BoundaryMetadata(
    dc = [0.0, 0.0],
    nc = [0.0, 0.0],
    isPeriodic = [true],
    hasData = true,
)
```
"""
Base.@kwdef struct BoundaryMetadata{T}
    dc::Vector{T} = T[]
    nc::Vector{T} = T[]
    isPeriodic::Vector{Bool} = Bool[]
    hasData::Bool = false
end

"""
    Grid{T} <: AbstractGrid

Stores the geometric and boundary-condition metadata for a computational grid.

A `Grid` is the central data object used by the MOLE 2.0 grid API. It records
the grid dimension, topology, cell counts, grid spacings, coordinate arrays,
and boundary-condition metadata. Operators should treat `Grid` objects as
read-only inputs.

# Fields

- `dim::Int`: Spatial dimension of the grid.
- `topology::Symbol`: Grid topology, such as `:uniform`, `:periodic`, or `:curvilinear`.
- `m`, `n`, `o`: Number of cells in the x-, y-, and z-directions.
- `dx`, `dy`, `dz`: Grid spacing in the x-, y-, and z-directions.
- `nodes::NamedTuple`: Nodal coordinate arrays.
- `faces::NamedTuple`: Face coordinate arrays.
- `centers::NamedTuple`: Cell-center coordinate arrays.
- `bc::BoundaryMetadata{T}`: Boundary-condition metadata.

# Examples

```julia
grid = makeGrid(m = 64, dx = 1/64)

grid.dim
grid.topology
grid.nodes
```
"""
Base.@kwdef struct Grid{T} <: AbstractGrid
    dim::Int
    topology::Symbol

    m::Union{Nothing, Int} = nothing
    n::Union{Nothing, Int} = nothing
    o::Union{Nothing, Int} = nothing

    dx::Union{Nothing, T} = nothing
    dy::Union{Nothing, T} = nothing
    dz::Union{Nothing, T} = nothing

    nodes::NamedTuple = NamedTuple()
    faces::NamedTuple = NamedTuple()
    centers::NamedTuple = NamedTuple()

    bc::BoundaryMetadata{T} = BoundaryMetadata{T}()
end
