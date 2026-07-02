# MATLAB/Octave v2.0 Structure (In Progress)

This document tracks the v2.0 refactor of the MATLAB/Octave source tree.
The refactor is incremental and keeps legacy entry points working while
introducing a grid-first API.

## Grid-First API

The new preferred calling pattern is to pass a `grid` struct and `k`:

- `G = grad(grid, k)`
- `D = div(grid, k)`
- `L = lap(grid, k)`
- `N = nodal2D(grid, k)`
- `[J, Xe, Xn, Ye, Yn] = jacobian2D(grid, k)`
- `[A, b] = addScalarBC2D(A, b, k, grid, v)`

Legacy signatures are still supported.

Use `makeGrid` to construct grid structs and `validateGrid` for explicit
validation:

- `grid = makeGrid('m', 100, 'dx', 0.01)`
- `grid = makeGrid('m', 64, 'n', 64, 'dx', 1/64, 'dy', 1/64, 'bc', bc)`
- `grid = validateGrid(grid)`

## Current Canonical Fields

- Core: `dim`, `type`, `m`, `n`, `o`, `dx`, `dy`, `dz`
- Coordinates: `x`, `y`, `z`, `X`, `Y`, `Z`
- Boundary conditions: `bc.dc`, `bc.nc`, `bc.isPeriodic`
- Optional shape hint: `shape` (`nodal` or cell-based default)
- Optional nodal override: `nodeCounts.m`, `nodeCounts.n`, `nodeCounts.o`

## Target Directory Layout

- `api/`
- `operators/gradient/`
- `operators/divergence/`
- `operators/laplacian/`
- `operators/curl/`
- `operators/nodal/`
- `interpolation/basic/`
- `interpolation/transfers/`
- `interpolation/internal/`
- `boundaries/scalar/`
- `boundaries/legacy/` (deprecated compatibility wrappers)
- `boundaries/curvilinear/`
- `boundaries/mimetic/`
- `geometry/grids/`
- `geometry/metrics/`
- `geometry/templates/`
- `weights/`
- `internal/indexing/`
- `internal/common/`
- `utils/`

## Implementation Status

Completed in code:

- Grid normalizers for 1-D, 2-D, 3-D under `private/` are now
  compatibility shims that delegate to `validateGrid`
- `makeGrid` and `validateGrid` added
- `ensureMatlabOctaveSubdirs` added so subdirectory implementations work
  when only `src/matlab_octave` is added to MATLAB path
- Grid-first overloads added to:
  - `grad`, `div`, `lap` (1-D/2-D/3-D)
  - `nodal` (1-D/2-D/3-D)
  - `jacobian` (2-D/3-D)
  - `grad*Curv`, `div*Curv`, `nodal*Curv`
  - `interpol*` basic builders
  - `mimeticB`
  - `addScalarBC1D`, `addScalarBC2D`, `addScalarBC3D`
  - `robinBC*` and `mixedBC*` are deprecated compatibility wrappers that now
    delegate to implementations under `boundaries/robin/` and
    `boundaries/mixed/`, which in turn assemble through addScalarBC-based
    boundary operators and emit deprecation warnings
  - The deprecated `robinBC*` and `mixedBC*` implementation folders now
    use shared local helpers to avoid repeated boundary-coefficient decoding
  - Top-level deprecated `robinBC*` and `mixedBC*` wrappers now also share
    a common warning helper for consistent deprecation messaging
  - Scalar boundary implementations moved to `boundaries/scalar/`
    with top-level compatibility entry points
  - Scalar support helpers `addScalarBC*lhs` and `addScalarBC*rhs` also now
    delegate to implementations under `boundaries/scalar/`
  - Compatibility coverage for deprecated `robinBC*` and `mixedBC*`
    wrappers added to `tests/matlab_octave/testBCConsistency.m`
  - `validateGrid` now rejects partial `grid.bc.{dc,nc}` specifications and
    normalizes scalar `dc`/`nc` shorthand to full per-face vectors for
    1-D/2-D/3-D grid-first boundary application
- Canonical operator implementations moved to target folders with
  top-level compatibility entry points:
  - `operators/gradient/gradOp_impl`
  - `operators/divergence/divOp_impl`
  - `operators/laplacian/lapOp_impl`
  - `operators/nodal/nodalOp_impl`
- Transfer interpolation implementations moved to
  `interpolation/transfers/` with top-level compatibility entry points:
  - `interpolCentersToFacesD{1D,2D,3D}_impl`
  - `interpolCentersToFacesD{1D,2D,3D}Periodic_impl`
  - `interpolFacesToCentersG{1D,2D,3D}_impl`
  - `interpolFacesToCentersG{1D,2D,3D}Periodic_impl`
- Deprecated interpolation wrappers moved to `interpolation/basic/` with
  top-level compatibility entry points:
  - `interpol_impl`, `interpol2D_impl`, `interpol3D_impl`
  - `interpolD_impl`, `interpolD2D_impl`, `interpolD3D_impl`
- Grid API helpers moved to `api/` with top-level compatibility entry points:
  - `makeGrid_impl`, `validateGrid_impl`
- Grid templates copied to `geometry/templates/{chevron,horseshoe,swan}`
  and `tfi`/`ttm` now resolve templates via `resolveGridTemplatePath`
  with fallback to legacy `grids/` paths
- `resolveNodalCounts` promoted to top-level helper so moved nodal
  implementations remain path-stable
- Runtime migration test added and passing:
  - `tests/matlab_octave/testGridFirstV2Migration.m`

Pending:

- Remove legacy `grids/` tree after transition period
- Extend runtime migration tests to additional BC and curvilinear paths
