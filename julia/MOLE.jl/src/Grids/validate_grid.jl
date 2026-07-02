#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

"""
    validateGrid(grid::Grid; allowPartial=false)
    validateGrid(raw::AbstractDict{Symbol,<:Any}; allowPartial=false)

Validate and normalize a computational grid.

`validateGrid` verifies that a grid definition is internally consistent,
infers missing metadata when possible, and returns a fully normalized
[`Grid`](@ref) object. Depending on the supplied information, it determines the
spatial dimension and grid topology, validates boundary-condition data, and
generates the coordinate arrays associated with nodes, faces, and cell centers.

This function is called internally by [`makeGrid`](@ref), but may also be
used directly to validate existing grid objects or dictionaries containing
grid definitions.

# Arguments

- `grid::Grid`: A grid object to validate and normalize.
- `raw::AbstractDict{Symbol,<:Any}`: A dictionary containing grid parameters.
- `allowPartial::Bool=false`: If `true`, incomplete grid definitions are
  accepted without requiring all fields needed for coordinate generation.

# Validation

Depending on the inferred spatial dimension, `validateGrid` checks the
consistency of:

- grid dimensions (`m`, `n`, `o`)
- grid spacing (`dx`, `dy`, `dz`)
- grid topology (`:uniform`, `:periodic`, `:curvilinear`)
- boundary-condition metadata
- user-supplied nodal coordinates for curvilinear grids

When sufficient information is available, coordinate arrays for nodes, faces,
and cell centers are generated automatically.

# Returns

A validated and normalized [`Grid`](@ref) object.

# Throws

- `ArgumentError` if required fields are missing.
- `ArgumentError` if grid dimensions or spacings are invalid.
- `ArgumentError` if boundary-condition metadata is inconsistent.
- `ArgumentError` if supplied curvilinear coordinate arrays have incompatible
  dimensions.

# Examples

Validate a one-dimensional grid definition:

```julia
grid = validateGrid(Dict(
    :m => 100,
    :dx => 0.01,
))
```

Validate an existing grid object:

```julia
grid = makeGrid(m=64, dx=1/64)

grid = validateGrid(grid)
```

Validate a partially specified grid:

```julia
grid = validateGrid(
    Dict(:m => 100);
    allowPartial = true,
)
```

# Notes

Most users should construct grids using [`makeGrid`](@ref), which calls
`validateGrid` automatically. Direct use of `validateGrid` is primarily intended
for internal routines, advanced workflows, or validation of externally
constructed grid definitions.
"""
function validateGrid(grid::Grid; allowPartial::Bool = false)
    raw = Dict{Symbol, Any}()

    raw[:dim] = grid.dim
    raw[:topology] = grid.topology

    for name in (:m, :n, :o, :dx, :dy, :dz)
        value = getfield(grid, name)
        value !== nothing && (raw[name] = value)
    end

    !isempty(grid.nodes) && (raw[:nodes] = grid.nodes)
    !isempty(grid.faces) && (raw[:faces] = grid.faces)
    !isempty(grid.centers) && (raw[:centers] = grid.centers)
    raw[:bc] = grid.bc

    return validateGrid(raw; allowPartial = allowPartial)
end

function validateGrid(raw::AbstractDict{Symbol, <:Any}; allowPartial::Bool = false)
    bc_raw = get(raw, :bc, Dict{Symbol, Any}())

    if haskey(raw, :dc) && !_has_bc_field(bc_raw, :dc)
        bc_raw = _set_bc_field(bc_raw, :dc, raw[:dc])
    end

    if haskey(raw, :nc) && !_has_bc_field(bc_raw, :nc)
        bc_raw = _set_bc_field(bc_raw, :nc, raw[:nc])
    end

    dim = get(raw, :dim, _infer_dim(raw))
    topology = Symbol(get(raw, :topology, _infer_topology(raw)))

    dim == 1 && return _normalize_1d(raw, bc_raw, topology; allowPartial = allowPartial)
    dim == 2 && return _normalize_2d(raw, bc_raw, topology; allowPartial = allowPartial)
    dim == 3 && return _normalize_3d(raw, bc_raw, topology; allowPartial = allowPartial)

    throw(ArgumentError("grid.dim must be 1, 2, or 3"))
end

function _infer_dim(raw)
    if any(haskey(raw, k) for k in (:o, :dz, :Z))
        return 3
    elseif any(haskey(raw, k) for k in (:n, :dy, :Y))
        return 2
    else
        return 1
    end
end

function _infer_topology(raw)
    if any(haskey(raw, k) for k in (:X, :Y, :Z)) ||
       (haskey(raw, :nodes) && all(k -> haskey(raw[:nodes], k), (:X, :Y)))
        return :curvilinear
    elseif any(haskey(raw, k) for k in (:x, :y, :z))
        return :nonuniform
    else
        return :uniform
    end
end

function _require(raw, names, allowPartial, msg)
    for name in names
        if !haskey(raw, name) && !allowPartial
            throw(ArgumentError("$msg: missing grid.$name"))
        end
    end
end

function _normalize_1d(raw, bc_raw, topology; allowPartial)
    _require(raw, (:m,), allowPartial, "validateGrid:MissingField1D")

    if haskey(raw, :m) && haskey(raw, :dx)
        m = _validate_positive_int(raw[:m], "grid.m")
        dx = _validate_positive_spacing(raw[:dx], "grid.dx")

        bc = _normalize_bc(bc_raw, 2)
        isperiodic = bc.hasData ? [all(bc.dc .^ 2 .+ bc.nc .^ 2 .== 0)] : [false]
        bc = BoundaryMetadata(
            dc = bc.dc,
            nc = bc.nc,
            isPeriodic = isperiodic,
            hasData = bc.hasData,
        )

        nodes, faces, centers = _coordinates_1d(m, dx)
        grid_topology = only(bc.isPeriodic) ? :periodic : :uniform

        return Grid(
            dim = 1,
            topology = grid_topology,
            m = m,
            dx = dx,
            nodes = nodes,
            faces = faces,
            centers = centers,
            bc = bc,
        )
    end

    if !allowPartial && topology == :uniform
        throw(
            ArgumentError(
                "validateGrid:MissingUniform1D: uniform 1-D grid requires m and dx",
            ),
        )
    end

    return Grid(dim = 1, topology = topology)
end

function _normalize_2d(raw, bc_raw, topology; allowPartial)
    _require(raw, (:m, :n), allowPartial, "validateGrid:MissingField2D")

    if topology == :curvilinear
        if haskey(raw, :m) && haskey(raw, :n)
            return _normalize_curvilinear_2d(raw, bc_raw)
        end
        return Grid(dim = 2, topology = :curvilinear)
    end

    if all(haskey(raw, k) for k in (:m, :n, :dx, :dy))
        m = _validate_positive_int(raw[:m], "grid.m")
        n = _validate_positive_int(raw[:n], "grid.n")
        dx = _validate_positive_spacing(raw[:dx], "grid.dx")
        dy = _validate_positive_spacing(raw[:dy], "grid.dy")

        bc = _normalize_bc(bc_raw, 4)
        isperiodic =
            bc.hasData ?
            [
                all(bc.dc[1:2] .^ 2 .+ bc.nc[1:2] .^ 2 .== 0),
                all(bc.dc[3:4] .^ 2 .+ bc.nc[3:4] .^ 2 .== 0),
            ] : [false, false]

        bc = BoundaryMetadata(
            dc = bc.dc,
            nc = bc.nc,
            isPeriodic = isperiodic,
            hasData = bc.hasData,
        )
        nodes, faces, centers = _coordinates_2d(m, n, dx, dy)
        grid_topology = any(bc.isPeriodic) ? :periodic : :uniform

        return Grid(
            dim = 2,
            topology = grid_topology,
            m = m,
            n = n,
            dx = dx,
            dy = dy,
            nodes = nodes,
            faces = faces,
            centers = centers,
            bc = bc,
        )
    end

    if !allowPartial && topology == :uniform
        throw(
            ArgumentError(
                "validateGrid:MissingUniform2D: uniform 2-D grid requires m, n, dx, and dy",
            ),
        )
    end

    return Grid(dim = 2, topology = topology)
end

function _normalize_3d(raw, bc_raw, topology; allowPartial)
    _require(raw, (:m, :n, :o), allowPartial, "validateGrid:MissingField3D")

    if all(haskey(raw, k) for k in (:m, :n, :o, :dx, :dy, :dz))
        m = _validate_positive_int(raw[:m], "grid.m")
        n = _validate_positive_int(raw[:n], "grid.n")
        o = _validate_positive_int(raw[:o], "grid.o")

        dx = _validate_positive_spacing(raw[:dx], "grid.dx")
        dy = _validate_positive_spacing(raw[:dy], "grid.dy")
        dz = _validate_positive_spacing(raw[:dz], "grid.dz")

        bc = _normalize_bc(bc_raw, 6)
        isperiodic =
            bc.hasData ?
            [
                all(bc.dc[1:2] .^ 2 .+ bc.nc[1:2] .^ 2 .== 0),
                all(bc.dc[3:4] .^ 2 .+ bc.nc[3:4] .^ 2 .== 0),
                all(bc.dc[5:6] .^ 2 .+ bc.nc[5:6] .^ 2 .== 0),
            ] : [false, false, false]

        bc = BoundaryMetadata(
            dc = bc.dc,
            nc = bc.nc,
            isPeriodic = isperiodic,
            hasData = bc.hasData,
        )
        nodes, faces, centers = _coordinates_3d(m, n, o, dx, dy, dz)
        grid_topology = any(bc.isPeriodic) ? :periodic : :uniform

        return Grid(
            dim = 3,
            topology = grid_topology,
            m = m,
            n = n,
            o = o,
            dx = dx,
            dy = dy,
            dz = dz,
            nodes = nodes,
            faces = faces,
            centers = centers,
            bc = bc,
        )
    end

    if !allowPartial && topology == :uniform
        throw(
            ArgumentError(
                "validateGrid:MissingUniform3D: uniform 3-D grid requires m, n, o, dx, dy, and dz",
            ),
        )
    end

    return Grid(dim = 3, topology = topology)
end

function _normalize_curvilinear_2d(raw, bc_raw)
    m = _validate_positive_int(raw[:m], "grid.m")
    n = _validate_positive_int(raw[:n], "grid.n")

    if !haskey(raw, :nodes)
        throw(
            ArgumentError(
                "validateGrid:CurvilinearMissingNodes: curvilinear grid requires nodes.X and nodes.Y",
            ),
        )
    end

    nodes = raw[:nodes]

    if !(haskey(nodes, :X) && haskey(nodes, :Y))
        throw(
            ArgumentError(
                "validateGrid:CurvilinearMissingNodes: curvilinear grid requires nodes.X and nodes.Y",
            ),
        )
    end

    expected = (m + 1, n + 1)

    if size(nodes.X) != expected || size(nodes.Y) != expected
        throw(
            ArgumentError(
                "validateGrid:SizeMismatch: curvilinear nodes.X/Y must have size $expected",
            ),
        )
    end

    faces, centers = _coordinates_curvilinear_2d(nodes)
    bc = _normalize_bc(bc_raw, 4)

    return Grid(
        dim = 2,
        topology = :curvilinear,
        m = m,
        n = n,
        nodes = nodes,
        faces = faces,
        centers = centers,
        bc = bc,
    )
end

function _normalize_bc(bc_raw, expected)
    has_dc = _has_bc_field(bc_raw, :dc)
    has_nc = _has_bc_field(bc_raw, :nc)

    if !has_dc && !has_nc
        return BoundaryMetadata{Float64}()
    end

    if has_dc != has_nc
        throw(ArgumentError("grid.bc.dc and grid.bc.nc must be provided together"))
    end

    dc = _bc_field(bc_raw, :dc)
    nc = _bc_field(bc_raw, :nc)

    if isempty(dc) && isempty(nc)
        return BoundaryMetadata{Float64}()
    end

    dc = _normalize_bc_vector(dc, expected, "grid.bc.dc")
    nc = _normalize_bc_vector(nc, expected, "grid.bc.nc")

    return BoundaryMetadata(dc = dc, nc = nc, isPeriodic = Bool[], hasData = true)
end

function _normalize_bc_vector(values, expected, name)
    values isa Number && return fill(float(values), expected)

    if !(values isa AbstractVector)
        throw(ArgumentError("$name must be a scalar or vector"))
    end

    vals = float.(collect(values))

    length(vals) == 1 && return fill(only(vals), expected)

    if length(vals) != expected
        throw(ArgumentError("$name must be a scalar or a vector of length $expected"))
    end

    return vals
end

_has_bc_field(bc::BoundaryMetadata, name::Symbol) = !isempty(getfield(bc, name))
_has_bc_field(bc::AbstractDict, name::Symbol) = haskey(bc, name)
_has_bc_field(bc::NamedTuple, name::Symbol) = haskey(bc, name)
_has_bc_field(_, _) = false

_bc_field(bc::BoundaryMetadata, name::Symbol) = getfield(bc, name)
_bc_field(bc::AbstractDict, name::Symbol) = bc[name]
_bc_field(bc::NamedTuple, name::Symbol) = getfield(bc, name)

function _set_bc_field(bc::AbstractDict, name::Symbol, value)
    out = Dict{Symbol, Any}(bc)
    out[name] = value
    return out
end

function _set_bc_field(bc::NamedTuple, name::Symbol, value)
    return merge(bc, (; name => value))
end

function _set_bc_field(bc::BoundaryMetadata, name::Symbol, value)
    values = name == :dc ? value : bc.dc
    normals = name == :nc ? value : bc.nc
    return BoundaryMetadata(dc = collect(float.(values)), nc = collect(float.(normals)))
end

function _validate_positive_int(value, name)
    value = Int(value)

    if value <= 0
        throw(ArgumentError("$name must be a positive integer"))
    end

    return value
end

function _validate_positive_spacing(value, name)
    value = float(value)

    if value <= 0
        throw(ArgumentError("$name must be positive"))
    end

    return value
end
