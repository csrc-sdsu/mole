# MOLE MATLAB/Octave Grid Struct Refactor — Design Spec

Date: 2026-05-21
Scope: MATLAB/Octave only (no C++ or Julia changes)
Branch: feat/dev.matlab.2.0

---

## 1. Objectives

1. Enrich the `grid` struct to store pre-computed mesh coordinate arrays (nodes, faces, centers) so `validateGrid` can confirm mesh consistency.
2. Establish a small, clean public API surface (~9 entry points) and internalize everything else.
3. Remove all deprecated functions: `robinBC*`, `mixedBC*`, legacy flat-argument signatures, top-level dimensional variants (`grad2D`, `div3D`, etc.), periodic/nonperiodic variant files, and the deprecated `interpol`/`interpolD` family.
4. Reorganize the folder structure so internal and utility code is not on the public path.

Approach: **Struct-first** — enrich `grid` and `validateGrid` first, then migrate operators, then wipe the public surface and reorganize files.

---

## 2. The Enriched Grid Struct

### 2.1 Scalar fields (unchanged)

| Field | Meaning |
|-------|---------|
| `grid.dim` | 1, 2, or 3 |
| `grid.type` | `'uniform'` \| `'nonuniform'` \| `'periodic'` \| `'curvilinear'` |
| `grid.m` | cells in x |
| `grid.n` | cells in y (2D/3D) |
| `grid.o` | cells in z (3D) |
| `grid.dx`, `grid.dy`, `grid.dz` | step sizes |

### 2.2 New coordinate sub-structs

All arrays are uppercase (full meshgrid arrays). Sizes given for m×n 2D; 1D and 3D follow naturally.

#### 1D (m cells)

| Field | Size | Meaning |
|-------|------|---------|
| `grid.nodes.X` | (m+1)×1 | vertex positions |
| `grid.centers.X` | (m+2)×1 | cell centers + boundary face centers |
| `grid.faces.X` | (m+1)×1 | face centers (coincides with nodes in 1D) |

#### 2D (m×n cells)

| Field | Size | Meaning |
|-------|------|---------|
| `grid.nodes.X`, `.Y` | (m+1)×(n+1) | corner vertices |
| `grid.centers.X`, `.Y` | (m+2)×(n+2) | cell centers + boundary face centers |
| `grid.faces.u.X`, `.Y` | (m+1)×n | x-direction face centers |
| `grid.faces.v.X`, `.Y` | m×(n+1) | y-direction face centers |

#### 3D (m×n×o cells)

| Field | Size | Meaning |
|-------|------|---------|
| `grid.nodes.X/Y/Z` | (m+1)×(n+1)×(o+1) | corner vertices |
| `grid.centers.X/Y/Z` | (m+2)×(n+2)×(o+2) | cell centers + boundary face centers |
| `grid.faces.u.X/Y/Z` | (m+1)×n×o | x-direction face centers |
| `grid.faces.v.X/Y/Z` | m×(n+1)×o | y-direction face centers |
| `grid.faces.w.X/Y/Z` | m×n×(o+1) | z-direction face centers |

### 2.3 Boundary condition sub-struct (unchanged)

```
grid.bc.dc          % Dirichlet coefficients: 2×1 (1D), 4×1 (2D), 6×1 (3D)
grid.bc.nc          % Neumann coefficients: same sizes
grid.bc.isPeriodic  % logical scalar (1D), 2×1 (2D), 3×1 (3D)
grid.bc.hasData     % logical scalar
```

### 2.4 Curvilinear grids

`grid.type = 'curvilinear'`. The caller provides physical node coordinates in `grid.nodes.X` / `grid.nodes.Y` (and `.Z` for 3D) before passing to `makeGrid` or `validateGrid`. The validator confirms sizes match `(m+1)×(n+1)` (etc.) and derives `grid.faces` and `grid.centers` coordinate arrays by interpolation. The old top-level `grid.X` / `grid.Y` fields are retired.

---

## 3. Public API Surface

Exactly 9 public entry points at `src/matlab_octave/`:

| File | Signature | Dispatches to |
|------|-----------|---------------|
| `makeGrid.m` | `grid = makeGrid(name, value, ...)` | `api/makeGrid_impl.m` |
| `validateGrid.m` | `grid = validateGrid(grid)` | `api/validateGrid_impl.m` |
| `grad.m` | `G = grad(grid, k)` | `operators/gradient/gradOp_impl.m` |
| `div.m` | `D = div(grid, k)` | `operators/divergence/divOp_impl.m` |
| `lap.m` | `L = lap(grid, k)` | `operators/laplacian/lapOp_impl.m` |
| `curl.m` | `C = curl(grid, k)` | `operators/curl/curlOp_impl.m` |
| `nodal.m` | `N = nodal(grid, k)` | `operators/nodal/nodalOp_impl.m` |
| `addScalarBC.m` | `[A,b] = addScalarBC(A, b, k, grid, v)` | `boundaries/scalar/addScalarBC_impl.m` |
| `interpol.m` | `I = interpol(grid, direction)` | `interpolation/transfers/interpol_impl.m` |

`interpol` direction argument: `'CentersToFaces'`, `'FacesToCenters'`, `'NodesToCenters'`, `'CentersToNodes'`.

---

## 4. Target Folder Structure

```
src/matlab_octave/
├── makeGrid.m
├── validateGrid.m
├── grad.m
├── div.m
├── lap.m
├── curl.m
├── nodal.m
├── addScalarBC.m
├── interpol.m
│
├── api/
│   ├── makeGrid_impl.m
│   └── validateGrid_impl.m
│
├── operators/
│   ├── gradient/     (gradOp_impl, gradPeriodic, gradNonPeriodic, gradCurv_impl)
│   ├── divergence/   (divOp_impl, divPeriodic, divNonPeriodic, divCurv_impl)
│   ├── laplacian/    (lapOp_impl, lapPeriodic, lapNonPeriodic)
│   ├── curl/         (curlOp_impl)
│   └── nodal/        (nodalOp_impl, nodal2D/3D internals)
│
├── boundaries/
│   ├── scalar/       (addScalarBC_impl, addScalarBC1D/2D/3D_impl, lhs/rhs helpers)
│   └── curvilinear/  (neumann2DCurv, neumann3DCurv)
│
├── interpolation/
│   └── transfers/    (interpol_impl, interpolCentersToFaces*_impl,
│                      interpolFacesToCenters*_impl, interpolNodesToCenters*_impl,
│                      interpolCentersToNodes*_impl, *Periodic variants)
│
├── geometry/
│   ├── metrics/      (jacobian_impl — 2D and 3D, called internally by curvilinear ops)
│   └── templates/    (chevron, horseshoe, swan)
│
├── internal/
│   ├── common/       (ensureMatlabOctaveSubdirs, generateWeights)
│   └── indexing/     (boundaryIdx2D, GI1, GI2, GI13, DI2, DI3)
│
└── utils/            (tfi, ttm, rk4, gridGen, amean, hmean, mimeticB,
                       resolveGridTemplatePath, resolveNodalCounts,
                       sidedNodal, tensorGrad2D)
```

`geometry/grids/` (legacy grid templates) is removed after the `geometry/templates/` transition is complete.

---

## 5. What Gets Deleted

### Top-level operator variants (deleted, not moved)
- `grad1D.m`, `grad2D.m`, `grad3D.m`
- `gradNonPeriodic.m`, `gradPeriodic.m`, `gradNonUniform.m`
- `grad2DCurv.m`, `grad3DCurv.m`
- `gradOp.m` (shim replaced by `grad.m` directly)
- `divOp.m`, `lapOp.m`, `nodalOp.m` (same — shims replaced by their operator entry points)
- Same pattern for remaining `div*`, `lap*`, `nodal*` top-level variants
- `curl2D.m` → renamed/promoted to `curl.m`
- `jacobian2D.m`, `jacobian3D.m` (moved to `geometry/metrics/jacobian_impl.m`)

### Deprecated boundary wrappers (deleted)
- `robinBC.m`, `robinBC2D.m`, `robinBC3D.m`
- `mixedBC.m`, `mixedBC2D.m`, `mixedBC3D.m`
- `deprecatedBoundaryWrapperWarning.m`

### Collapsed BC entry points (deleted; unified via `addScalarBC.m`)
- `addScalarBC1D.m`, `addScalarBC2D.m`, `addScalarBC3D.m`
- `addScalarBC1Dlhs.m`, `addScalarBC1Drhs.m`
- `addScalarBC2Dlhs.m`, `addScalarBC2Drhs.m`
- `addScalarBC3Dlhs.m`, `addScalarBC3Drhs.m`

### Deprecated interpolation family (deleted entirely)
- `interpol.m`, `interpol2D.m`, `interpol3D.m`
- `interpolD.m`, `interpolD2D.m`, `interpolD3D.m`
- Top-level `interpolCentersToFaces*.m`, `interpolFacesToCenters*.m`,
  `interpolNodesToCenters*.m`, `interpolCentersToNodes*.m` (implementations stay under `interpolation/transfers/`)

### Private normalizers (deleted in Phase 1 — already thin shims that delegate to validateGrid)
- `private/normalizeGrid1D.m`, `private/normalizeGrid2D.m`, `private/normalizeGrid3D.m`

---

## 6. Operator Dispatch Pattern

Every public operator entry point:
1. Calls `validateGrid(grid)` — coordinates are guaranteed present after this
2. Asserts stencil size constraints (`k >= 2`, `m >= 2*k`, etc.)
3. Switches on `grid.dim`, then `grid.type` (or `grid.bc.isPeriodic`)
4. Calls the appropriate `_impl` function

`gradOp_impl.m` is already the canonical example. Curvilinear dispatch is added as a new branch that reads `grid.nodes.X/Y` and delegates to `gradCurv_impl.m` (which absorbs the logic currently in `grad2DCurv.m`).

`addScalarBC_impl.m` dispatches on `grid.dim` to `addScalarBC1D_impl`, `addScalarBC2D_impl`, `addScalarBC3D_impl` in `boundaries/scalar/`.

`interpol_impl.m` dispatches on `grid.dim` and the `direction` string to the appropriate transfer `_impl`.

---

## 7. validateGrid Additions

`validateGrid_impl.m:localNormalizeGrid1D/2D/3D` are the springboard. Each is extended to:

1. Compute and attach coordinate arrays after existing BC normalization:
   - Uniform: generate from `linspace` + `meshgrid` using `m/n/o` and `dx/dy/dz`
   - Curvilinear: accept `grid.nodes.X/Y` from caller, derive `faces` and `centers` by interpolation
2. Size-check any coordinate arrays already present (e.g., if caller pre-populates them):
   - `grid.nodes.X` must be `(m+1)×(n+1)` for 2D, etc.
   - `grid.faces.u.X` must be `(m+1)×n`, etc.
   - Mismatches throw `validateGrid:SizeMismatch`
3. For curvilinear: require `grid.nodes.X/Y` to be present; throw `validateGrid:CurvilinearMissingNodes` otherwise

---

## 8. Error IDs

| Error ID | Trigger |
|----------|---------|
| `validateGrid:MissingField` | Required scalar field absent |
| `validateGrid:SizeMismatch` | Coordinate array size inconsistent with m/n/o |
| `validateGrid:CurvilinearMissingNodes` | `type='curvilinear'` but `nodes.X/Y` absent |
| `validateGrid:InvalidBC1D/2D/3D` | BC coefficient mismatch (existing, preserved) |
| `addScalarBC1D:InvalidBoundaryValueSize` | Boundary value vector wrong size (existing, preserved) |
| `addScalarBC2D:InvalidBoundaryValueSize` | Same for 2D |
| `addScalarBC3D:InvalidBoundaryValueSize` | Same for 3D |

---

## 9. Testing

All tests remain in `tests/matlab_octave/`. No new test framework.

### New test file: `testGridStruct.m`
- Constructs uniform 1D, 2D, 3D grids via `makeGrid`; asserts coordinate array sizes
- Constructs a curvilinear 2D grid; asserts `grid.nodes.X/Y` accepted and `faces`/`centers` derived
- Passes enriched grids to `grad`, `div`, `lap`; asserts outputs match pre-refactor baselines
- Asserts `validateGrid:SizeMismatch` thrown when coordinate sizes are wrong
- Asserts `validateGrid:CurvilinearMissingNodes` thrown when curvilinear nodes absent

### Extend `testGridFirstV2Migration.m`
- Add cases confirming old flat-signature entry points no longer exist (expect `undefined function`)

### Extend `testBCConsistency.m`
- Confirm `robinBC*` / `mixedBC*` throw `undefined function`
- Confirm `addScalarBC1D` / `addScalarBC2D` / `addScalarBC3D` throw `undefined function`
- Confirm unified `addScalarBC` produces same output as pre-refactor `addScalarBC2D_impl` baseline

### Baseline regression (must remain green throughout)
```
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); \
  assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

---

## 10. File Header Convention

Every new `.m` file must include a standard header. Two tiers apply:

### Tier 1 — Public entry points and operator-level `_impl` files

```matlab
function [outputs] = funcName(inputs)
% PURPOSE
% One-line description of what this function returns or does.
%
% DESCRIPTION
% Longer description: inputs, mathematical context, behavior notes.
%
% Parameters:
%   output1 : description
%   input1  : description
%
% SYNTAX
% [outputs] = funcName(inputs)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
```

### Tier 2 — Internal helper files (`boundaries/`, `internal/`, `geometry/metrics/`, etc.)

```matlab
function [outputs] = funcName(inputs)
% Canonical implementation for <publicFunctionName>.
```

The license block is omitted for pure-internal helpers that are never on the public path. Any file reachable by a user (including those in `utils/`) uses Tier 1.
