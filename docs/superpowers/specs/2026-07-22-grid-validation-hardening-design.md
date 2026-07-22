# Grid validation hardening: drop "nonuniform", catch conflicting metadata

## Context

`validateGrid_impl.m` normalizes and enriches a grid struct (nodes/faces/centers
coordinate arrays) before it's handed to operators. A review of the file against
its tests (`testGridStruct.m`) found two classes of problem:

1. `grid.topology` can be inferred as `'nonuniform'` (lowercase `x`/`y`/`z`
   fields present), but no code path anywhere handles that topology. The
   function silently returns the grid unchanged — no coordinate arrays, no
   error — even with `allowPartial=false`. This defeats the goal of catching
   grid errors before any computation happens.
2. Several forms of caller mistake go undetected: explicit `grid.dim`
   contradicting the dimension implied by present fields (e.g. `dim=2` with
   `grid.o` also set), explicit `grid.topology` contradicting curvilinear node
   evidence, non-scalar/non-numeric/non-finite cell counts and spacings in
   2-D/3-D (only spot-checked in 1-D today), curvilinear grids with only one
   of `nodes.X`/`nodes.Y` present, and curvilinear node data that is
   non-numeric or contains NaN/Inf (only array *shape* is validated today).

Boundary-condition (`bc.dc`/`bc.nc`) normalization and its tests are
out of scope for this pass.

## Scope

Files touched: `src/matlab_octave/api/validateGrid_impl.m`,
`src/matlab_octave/api/makeGrid_impl.m`, `tests/matlab_octave/testGridStruct.m`.

No other file in the repo calls `makeGrid`/`validateGrid` or references
`grid.topology` (confirmed by grep), so this change is isolated. The
`*NonUniform.m` operator files (`divNonUniform`, `gradNonUniform`, etc.) are an
unrelated legacy API that takes raw `ticks` vectors directly, not a grid
struct, and are unaffected.

## Design

### 1. Remove "nonuniform" as a topology

Delete the inference branch that sets `grid.topology = 'nonuniform'` from
lowercase `x`/`y`/`z` fields. Topology becomes binary: `'curvilinear'` or
`'uniform'` (with `'periodic'` still derived later from BC data, as today).

A grid struct that previously slipped through as fake "nonuniform" (e.g.
`struct('m', 5, 'x', [...])` with no `dx`) now reads as an incomplete
**uniform** grid and correctly raises the existing
`validateGrid:MissingUniform1D/2D/3D` error instead of silently returning an
unbuilt grid.

### 2. Recognize `grid.nodes.X/Y/Z` (not just legacy top-level `grid.X/Y/Z`) as curvilinear evidence

Today, dim/topology inference only look at top-level `grid.X`/`grid.Y`/`grid.Z`.
Every existing curvilinear test instead sets `grid.nodes.X`/`grid.nodes.Y` and
sets `topology='curvilinear'` by hand, so inference from nodes never actually
fires in practice. Both dim inference and topology inference will also treat
raw `grid.nodes.X/Y/Z` as evidence.

Guard: this evidence only counts when `grid.faces`/`grid.centers` are **not**
already present. Uniform grids also end up with `grid.nodes.X` populated as
*output* of a first `validateGrid` call, so without this guard, re-validating
an already-built uniform grid would false-positive as curvilinear.

### 3. New conflicting-metadata errors

Thrown whenever the corresponding field is given explicitly and disagrees with
what present fields imply — regardless of `allowPartial`, since this signals a
caller mistake rather than incremental construction:

- `validateGrid:DimMismatch` — explicit `grid.dim` disagrees with the
  dimension implied by present fields (`o`/`dz`/`Z`/raw `nodes.Z` ⟹ 3;
  `n`/`dy`/`Y`/raw `nodes.Y` ⟹ 2).
- `validateGrid:TopologyMismatch` — explicit `grid.topology` disagrees with
  curvilinear evidence (e.g. `topology='uniform'` while raw `nodes.X`/`Y` are
  present, or `topology='curvilinear'` while none are present — this second
  case is otherwise `validateGrid:CurvilinearMissingNodes`, so
  `TopologyMismatch` only needs to cover topology said non-curvilinear while
  node evidence exists).

### 4. Other non-BC hardening

- `assert(isscalar(grid), 'grid must be a scalar struct')` alongside the
  existing `isstruct` check.
- Extend cell-count (`m`/`n`/`o`) and spacing (`dx`/`dy`/`dz`) test coverage to
  2-D/3-D for non-numeric, non-scalar, complex, and non-finite values
  (currently only checked in 1-D). Rename the mislabeled
  `testNonNumericCellCountRejected2D3D` (it currently tests non-positive
  values, not non-numeric ones).
- Add tests for the already-implemented but untested `validateGrid:InvalidDim`
  and `validateGrid:MissingUniform1D/2D/3D` error paths.
- Curvilinear: add tests for asymmetric missing node fields (`nodes.X` present,
  `nodes.Y` missing) in 2-D and 3-D.
- Curvilinear: validate that `nodes.X/Y/Z` are numeric, real, and finite (new
  check — today only array *shape* is validated, so NaN/Inf or non-numeric
  node data silently passes validation and only fails later during actual
  interpolation), plus tests for that.

### `makeGrid_impl.m`

Expected to remain unchanged — it's a thin pass-through to
`validateGrid_impl`. If the implementation pass turns up no reason to touch
it, it will be left as-is rather than edited for its own sake.

## Out of scope

- `grid.bc`/`dc`/`nc` normalization and its tests.
- Any file other than the three listed above.
- Reintroducing nonuniform-grid support (that's a "remove", not a "fix").
