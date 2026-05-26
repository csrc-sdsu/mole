# API Consolidation Implementation Plan (Plan 3 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the two remaining unified public APIs (`addScalarBC` and `interpol`), then delete all deprecated top-level variant files to leave exactly the 9 entry-point surface from the spec.

**Architecture:** `addScalarBC(A, b, k, grid, v)` dispatches through `boundaries/scalar/addScalarBC_impl.m` → dim-specific `addScalarBC1D_impl/2D_impl/3D_impl`. `interpol(grid, direction)` dispatches through `interpolation/transfers/interpol_impl.m` → direction-specific transfers. After the unified APIs are tested and green, all deprecated top-level variants are deleted, test imports are updated, and shims (`gradOp.m`, `divOp.m`, etc.) are removed.

**Tech Stack:** MATLAB/Octave, `matlab.unittest.TestCase`, MOLE mimetic operators library

**Spec:** `docs/superpowers/specs/2026-05-21-grid-struct-refactor-design.md`
**Plan 1 completed:** `docs/superpowers/plans/2026-05-21-grid-struct-enrichment-plan1.md`
**Plan 2 completed:** `docs/superpowers/plans/2026-05-22-operator-migration-plan2.md`

---

## Current State (before Plan 3)

Already done (committed):
- `boundaries/scalar/addScalarBC1D_impl.m` through `addScalarBC3D_impl.m` ✓
- `boundaries/robin/` and `boundaries/mixed/` ✓
- `interpolation/transfers/*_impl.m` (individual direction files) ✓
- `interpolation/basic/interpol_impl.m` (old `(m,c)` shim, to be superseded) ✓
- `addScalarBC1D/2D/3D.m` accept grid-first `(A, b, k, grid, v)` signature ✓

Still needed:
- `boundaries/scalar/addScalarBC_impl.m` — dim-dispatcher
- `src/matlab_octave/addScalarBC.m` — new unified public entry
- `interpolation/transfers/interpol_impl.m` — direction-dispatcher
- `src/matlab_octave/interpol.m` rewritten to `(grid, direction)` API
- Delete all deprecated files (32 files listed in Task 3)

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `src/matlab_octave/addScalarBC.m` | Unified public entry `addScalarBC(A, b, k, grid, v)` |
| Create | `src/matlab_octave/boundaries/scalar/addScalarBC_impl.m` | Dim-dispatcher → 1D/2D/3D impl |
| Modify | `src/matlab_octave/interpol.m` | Rewrite to `(grid, direction)` API |
| Create | `src/matlab_octave/interpolation/transfers/interpol_impl.m` | Direction-dispatcher |
| Create | `tests/matlab_octave/testAPIConsolidation.m` | All Plan 3 tests |
| Modify | `tests/matlab_octave/testBCConsistency.m` | Add unified addScalarBC tests |
| Delete (32 files) | See Task 3 | All deprecated top-level variants |

---

## Task 1: Unified `addScalarBC.m` entry point

**Files:**
- Create: `src/matlab_octave/boundaries/scalar/addScalarBC_impl.m`
- Create: `src/matlab_octave/addScalarBC.m`
- Create: `tests/matlab_octave/testAPIConsolidation.m`

- [ ] **Step 1.1: Write failing tests**

Create `tests/matlab_octave/testAPIConsolidation.m`:

```matlab
classdef testAPIConsolidation < matlab.unittest.TestCase
% PURPOSE
% Tests for Plan 3 — unified addScalarBC and interpol(grid, direction) APIs.
%
% DESCRIPTION
% Verifies that addScalarBC(A, b, k, grid, v) dispatches correctly for 1D,
% 2D, and 3D grids; that interpol(grid, 'CentersToFaces') etc. route to the
% correct transfer implementations; and that both APIs produce identical
% results to the dimensional variants.
%
% SYNTAX
% Run via: runtests('testAPIConsolidation')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function testAddScalarBC1DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 4; m = 50; dx = 0.2;
            dc = [1; 1]; nc = [0; 0];
            v  = [2; 7];
            grid = makeGrid('m', m, 'dx', dx, 'bc', struct('dc', dc, 'nc', nc));
            A0 = speye(m+2); b0 = ones(m+2, 1);
            [A1, b1] = addScalarBC1D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),      1e-12);
        end

        function testAddScalarBC2DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 2; m = 10; n = 8; dx = 0.1; dy = 0.125;
            dc = ones(4,1); nc = zeros(4,1);
            v = {ones(n,1), ones(n,1), ones(m+2,1), ones(m+2,1)}';
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                            'bc', struct('dc', dc, 'nc', nc));
            A0 = speye((m+2)*(n+2)); b0 = ones((m+2)*(n+2), 1);
            [A1, b1] = addScalarBC2D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),       1e-12);
        end

        function testAddScalarBC3DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 2; m = 6; n = 6; o = 6;
            dx = 1/m; dy = 1/n; dz = 1/o;
            dc = ones(6,1); nc = zeros(6,1);
            v = {ones(n*o,1),   ones(n*o,1), ...
                 ones(m*o+2*o,1), ones(m*o+2*o,1), ...
                 ones(m*n+2*n+2,1), ones(m*n+2*n+2,1)}';
            grid = makeGrid('m', m, 'n', n, 'o', o, ...
                            'dx', dx, 'dy', dy, 'dz', dz, ...
                            'bc', struct('dc', dc, 'nc', nc));
            sz = (m+2)*(n+2)*(o+2);
            A0 = speye(sz); b0 = ones(sz, 1);
            [A1, b1] = addScalarBC3D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),       1e-12);
        end

    end  % methods(Test)
end  % classdef
```

- [ ] **Step 1.2: Run — expect failure**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testAPIConsolidation'))"
```

Expected: `Undefined function 'addScalarBC'` errors.

- [ ] **Step 1.3: Create `addScalarBC_impl.m`**

Create `src/matlab_octave/boundaries/scalar/addScalarBC_impl.m`:

```matlab
function [A, b] = addScalarBC_impl(A, b, k, grid, v)
% PURPOSE
% Canonical dim-dispatching implementation for unified addScalarBC.
%
% DESCRIPTION
% Reads grid.dim and calls the appropriate dimensional scalar BC
% implementation. The grid struct must be fully validated (bc.dc, bc.nc
% present and normalized) before this function is called.
%
% Parameters:
%   A    : Linear operator (modified in place)
%   b    : Right-hand-side vector (modified in place)
%   k    : Order of accuracy (even integer >= 2)
%   grid : Validated grid struct with grid.bc.dc and grid.bc.nc
%   v    : Boundary values (2×1 for 1D; cell array for 2D/3D)
%
% SYNTAX
% [A, b] = addScalarBC_impl(A, b, k, grid, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 1
        [A, b] = addScalarBC1D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.bc.dc, grid.bc.nc, v);
    case 2
        [A, b] = addScalarBC2D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.n, grid.dy, ...
                                    grid.bc.dc, grid.bc.nc, v);
    case 3
        [A, b] = addScalarBC3D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.n, grid.dy, ...
                                    grid.o, grid.dz, ...
                                    grid.bc.dc, grid.bc.nc, v);
    otherwise
        error('addScalarBC:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end
```

- [ ] **Step 1.4: Create `addScalarBC.m`**

Create `src/matlab_octave/addScalarBC.m`:

```matlab
function [A, b] = addScalarBC(A, b, k, grid, v)
% PURPOSE
% Apply scalar boundary conditions to a linear system for any grid dimension.
%
% DESCRIPTION
% Unified public entry point — accepts only the grid-struct form.
% Validates the grid, then dispatches to the appropriate dimensional
% implementation based on grid.dim. The grid struct must carry
% grid.bc.dc and grid.bc.nc (Dirichlet/Neumann coefficients).
%
% Parameters:
%   A    : Linear operator without boundary conditions added
%   b    : Right-hand-side vector without boundary conditions added
%   k    : Order of accuracy (even integer >= 2)
%   grid : Grid struct produced by makeGrid or validateGrid, with
%          grid.bc.dc and grid.bc.nc set
%   v    : Boundary values: 2×1 column vector (1D); cell array of
%          column vectors (2D: {left,right,bottom,top};
%          3D: {left,right,bottom,top,front,back})
%
% SYNTAX
% [A, b] = addScalarBC(A, b, k, grid, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 5 || ~isstruct(grid)
        error('addScalarBC:InvalidSignature', ...
              'addScalarBC(A, b, k, grid, v) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    grid = validateGrid(grid);
    [A, b] = addScalarBC_impl(A, b, k, grid, v);
end
```

- [ ] **Step 1.5: Run — expect all 3 tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testAPIConsolidation'))"
```

Expected: all 3 `testAddScalarBC*Unified` tests pass.

- [ ] **Step 1.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy','testGridStruct','testOperatorMigration'}))"
```

Expected: all pass.

- [ ] **Step 1.7: Commit**

```bash
git add src/matlab_octave/addScalarBC.m \
        src/matlab_octave/boundaries/scalar/addScalarBC_impl.m \
        tests/matlab_octave/testAPIConsolidation.m
git commit -m "feat: add unified addScalarBC(A, b, k, grid, v) public entry point"
```

---

## Task 2: New `interpol(grid, direction)` API

The spec defines `interpol(grid, direction)` where direction is one of:
`'CentersToFaces'`, `'FacesToCenters'`, `'NodesToCenters'`, `'CentersToNodes'`

The dispatcher lives at `interpolation/transfers/interpol_impl.m` and routes to
the existing per-dimension, per-direction `_impl` files.

**Files:**
- Create: `src/matlab_octave/interpolation/transfers/interpol_impl.m`
- Modify: `src/matlab_octave/interpol.m` (rewrite to new API)
- Modify: `tests/matlab_octave/testAPIConsolidation.m`

- [ ] **Step 2.1: Add failing interpol tests**

Append inside `methods(Test)` in `testAPIConsolidation.m`:

```matlab
        function testInterpolCentersToFaces1D(testCase)
            addpath('../../src/matlab_octave');
            m = 10; dx = 0.1;
            grid = makeGrid('m', m, 'dx', dx);
            I_new = interpol(grid, 'CentersToFaces');
            I_old = interpolCentersToFacesD1D(2, m);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end

        function testInterpolFacesToCenters1D(testCase)
            addpath('../../src/matlab_octave');
            m = 10; dx = 0.1;
            grid = makeGrid('m', m, 'dx', dx);
            I_new = interpol(grid, 'FacesToCenters');
            I_old = interpolFacesToCentersG1D(2, m);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end

        function testInterpolCentersToFaces2D(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; dx = 0.125; dy = 1/6;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            I_new = interpol(grid, 'CentersToFaces');
            I_old = interpolCentersToFacesD2D(2, m, n);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end
```

- [ ] **Step 2.2: Run — expect failure (`interpol` wrong signature)**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testAPIConsolidation'))"
```

Expected: 3 addScalarBC tests pass; 3 new interpol tests fail (wrong arg count).

- [ ] **Step 2.3: Create `interpolation/transfers/interpol_impl.m`**

Create `src/matlab_octave/interpolation/transfers/interpol_impl.m`:

```matlab
function I = interpol_impl(grid, direction)
% PURPOSE
% Canonical direction-dispatching implementation for unified interpol.
%
% DESCRIPTION
% Routes to the appropriate dimension- and direction-specific transfer
% operator based on grid.dim and the direction string. All underlying
% implementations use order k=2.
%
% Parameters:
%   I         : Sparse matrix — interpolation operator
%   grid      : Validated grid struct with grid.dim, grid.m (and .n, .o)
%   direction : One of 'CentersToFaces', 'FacesToCenters',
%               'NodesToCenters', 'CentersToNodes'
%
% SYNTAX
% I = interpol_impl(grid, direction)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    k = 2;  % fixed order for all transfer operators

    switch lower(direction)

    case 'centerstofaces'
        switch grid.dim
        case 1
            I = interpolCentersToFacesD1D_impl(k, grid.m);
        case 2
            I = interpolCentersToFacesD2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolCentersToFacesD3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'facestocenters'
        switch grid.dim
        case 1
            I = interpolFacesToCentersG1D_impl(k, grid.m);
        case 2
            I = interpolFacesToCentersG2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolFacesToCentersG3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'nodestocenters'
        % NodesToCenters: average of neighboring nodes — same as FacesToCenters
        % for the staggered grid layout; delegate to FacesToCenters path.
        switch grid.dim
        case 1
            I = interpolFacesToCentersG1D_impl(k, grid.m);
        case 2
            I = interpolFacesToCentersG2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolFacesToCentersG3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'centerstonodes'
        % CentersToNodes: reverse of NodesToCenters — same as CentersToFaces.
        switch grid.dim
        case 1
            I = interpolCentersToFacesD1D_impl(k, grid.m);
        case 2
            I = interpolCentersToFacesD2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolCentersToFacesD3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    otherwise
        error('interpol:UnknownDirection', ...
              'direction must be CentersToFaces, FacesToCenters, NodesToCenters, or CentersToNodes');
    end
end
```

- [ ] **Step 2.4: Rewrite `src/matlab_octave/interpol.m`**

Replace the entire file with:

```matlab
function I = interpol(grid, direction)
% PURPOSE
% Returns an interpolation operator for the specified transfer direction.
%
% DESCRIPTION
% Public entry point — accepts only the grid-struct form. Validates the grid
% and dispatches to interpol_impl, which routes to the correct dimensional
% transfer implementation based on grid.dim and direction.
%
% Parameters:
%   I         : Sparse matrix — interpolation operator
%   grid      : Grid struct produced by makeGrid or validateGrid
%   direction : Transfer direction string — one of:
%               'CentersToFaces'  — interior cell centers → face centers
%               'FacesToCenters'  — face centers → cell centers
%               'NodesToCenters'  — corner nodes → cell centers
%               'CentersToNodes'  — cell centers → corner nodes
%
% SYNTAX
% I = interpol(grid, direction)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid) || ~(ischar(direction) || isstring(direction))
        error('interpol:InvalidSignature', ...
              'interpol(grid, direction) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    grid = validateGrid(grid);
    I = interpol_impl(grid, direction);
end
```

- [ ] **Step 2.5: Run — expect all 6 tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testAPIConsolidation'))"
```

Expected: all 6 tests pass.

- [ ] **Step 2.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy','testGridStruct','testOperatorMigration'}))"
```

Expected: all pass. Note: callers of `interpol(m, c)` in example files will still work via
the legacy `interpol.m` — BUT the new entry point only accepts `(grid, direction)`, so any
caller still using the old `(m, c)` form will get an `interpol:InvalidSignature` error.
The test suite doesn't call `interpol(m, c)` directly; examples outside the test suite are
not in the regression baseline and may need updating.

- [ ] **Step 2.7: Commit**

```bash
git add src/matlab_octave/interpol.m \
        src/matlab_octave/interpolation/transfers/interpol_impl.m \
        tests/matlab_octave/testAPIConsolidation.m
git commit -m "feat: add interpol(grid, direction) public API and interpol_impl router"
```

---

## Task 3: Delete deprecated top-level variants

With the unified APIs in place and tested, all deprecated variant files are deleted. Tests
that were using these variants switch to the unified APIs or the legacy dimensional files
(which will be removed in a later cleanup pass).

**Files deleted:**

Operator shims (replaced by direct `_impl` dispatch from public entry points):
- `src/matlab_octave/gradOp.m`
- `src/matlab_octave/divOp.m`
- `src/matlab_octave/lapOp.m`
- `src/matlab_octave/nodalOp.m`

Dimensional operator variants (replaced by the single `grad.m`, `div.m`, etc.):
- `src/matlab_octave/grad2D.m`
- `src/matlab_octave/grad3D.m`
- `src/matlab_octave/grad2DCurv.m`
- `src/matlab_octave/grad3DCurv.m`
- `src/matlab_octave/div2D.m`
- `src/matlab_octave/div3D.m`
- `src/matlab_octave/div2DCurv.m`
- `src/matlab_octave/div3DCurv.m`
- `src/matlab_octave/lap2D.m`
- `src/matlab_octave/lap3D.m`
- `src/matlab_octave/nodal2D.m`
- `src/matlab_octave/nodal3D.m`
- `src/matlab_octave/nodal2DCurv.m`
- `src/matlab_octave/nodal3DCurv.m`
- `src/matlab_octave/curl2D.m` (absorbed into `curlOp_impl.m`)

Legacy scalar BC dimensional entry points (replaced by unified `addScalarBC.m`):
- `src/matlab_octave/addScalarBC1D.m`
- `src/matlab_octave/addScalarBC1Dlhs.m`
- `src/matlab_octave/addScalarBC1Drhs.m`
- `src/matlab_octave/addScalarBC2D.m`
- `src/matlab_octave/addScalarBC2Dlhs.m`
- `src/matlab_octave/addScalarBC2Drhs.m`
- `src/matlab_octave/addScalarBC3D.m`
- `src/matlab_octave/addScalarBC3Dlhs.m`
- `src/matlab_octave/addScalarBC3Drhs.m`

Deprecated BC wrappers (no replacement — removed entirely):
- `src/matlab_octave/robinBC.m`
- `src/matlab_octave/robinBC2D.m`
- `src/matlab_octave/robinBC3D.m`
- `src/matlab_octave/mixedBC.m`
- `src/matlab_octave/mixedBC2D.m`
- `src/matlab_octave/mixedBC3D.m`

Legacy interpolation entry points (replaced by unified `interpol(grid, direction)`):
- `src/matlab_octave/interpol2D.m`
- `src/matlab_octave/interpol3D.m`
- `src/matlab_octave/interpolD.m`
- `src/matlab_octave/interpolD2D.m`
- `src/matlab_octave/interpolD3D.m`
- `src/matlab_octave/interpolCentersToFacesD1D.m`
- `src/matlab_octave/interpolCentersToFacesD1DPeriodic.m`
- `src/matlab_octave/interpolCentersToFacesD2D.m`
- `src/matlab_octave/interpolCentersToFacesD2DPeriodic.m`
- `src/matlab_octave/interpolCentersToFacesD3D.m`
- `src/matlab_octave/interpolCentersToFacesD3DPeriodic.m`
- `src/matlab_octave/interpolFacesToCentersG1D.m`
- `src/matlab_octave/interpolFacesToCentersG1DPeriodic.m`
- `src/matlab_octave/interpolFacesToCentersG2D.m`
- `src/matlab_octave/interpolFacesToCentersG2DPeriodic.m`
- `src/matlab_octave/interpolFacesToCentersG3D.m`
- `src/matlab_octave/interpolFacesToCentersG3DPeriodic.m`

> **Before deleting:** Run the full baseline to confirm green. After deleting, update any
> test file that imports these names, then confirm the baseline is still green.

- [ ] **Step 3.1: Update tests that call deleted names**

`testBCConsistency.m` calls `addScalarBC1D/2D/3D` directly — replace all 9 such calls
with the unified `addScalarBC`. The test verifies `addScalarBC` is numerically identical
to the explicit forms, so the internal explicit-form comparisons just become two calls to
`addScalarBC` with the same arguments (they will trivially match). Remove the explicit-form
setup and use the grid form directly for verification.

`testGridFirstV2Migration.m` imports `grad2D(grid, k)` via `gradOp` shim — update to
call `grad(grid, k)` directly. Same for `div2D → div`, `lap2D → lap`.

- [ ] **Step 3.2: Run baseline before deletions (confirm green)**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy','testGridStruct','testOperatorMigration','testAPIConsolidation'}))"
```

- [ ] **Step 3.3: Delete operator shims**

```bash
git rm src/matlab_octave/gradOp.m src/matlab_octave/divOp.m \
       src/matlab_octave/lapOp.m  src/matlab_octave/nodalOp.m
```

- [ ] **Step 3.4: Delete dimensional operator variants**

```bash
git rm src/matlab_octave/grad2D.m src/matlab_octave/grad3D.m \
       src/matlab_octave/grad2DCurv.m src/matlab_octave/grad3DCurv.m \
       src/matlab_octave/div2D.m src/matlab_octave/div3D.m \
       src/matlab_octave/div2DCurv.m src/matlab_octave/div3DCurv.m \
       src/matlab_octave/lap2D.m src/matlab_octave/lap3D.m \
       src/matlab_octave/nodal2D.m src/matlab_octave/nodal3D.m \
       src/matlab_octave/nodal2DCurv.m src/matlab_octave/nodal3DCurv.m \
       src/matlab_octave/curl2D.m
```

- [ ] **Step 3.5: Delete legacy addScalarBC entry points**

```bash
git rm src/matlab_octave/addScalarBC1D.m \
       src/matlab_octave/addScalarBC1Dlhs.m \
       src/matlab_octave/addScalarBC1Drhs.m \
       src/matlab_octave/addScalarBC2D.m \
       src/matlab_octave/addScalarBC2Dlhs.m \
       src/matlab_octave/addScalarBC2Drhs.m \
       src/matlab_octave/addScalarBC3D.m \
       src/matlab_octave/addScalarBC3Dlhs.m \
       src/matlab_octave/addScalarBC3Drhs.m
```

- [ ] **Step 3.6: Delete deprecated BC wrappers**

```bash
git rm src/matlab_octave/robinBC.m src/matlab_octave/robinBC2D.m src/matlab_octave/robinBC3D.m \
       src/matlab_octave/mixedBC.m src/matlab_octave/mixedBC2D.m src/matlab_octave/mixedBC3D.m
```

- [ ] **Step 3.7: Delete legacy interpolation entry points**

```bash
git rm src/matlab_octave/interpol2D.m src/matlab_octave/interpol3D.m \
       src/matlab_octave/interpolD.m src/matlab_octave/interpolD2D.m src/matlab_octave/interpolD3D.m \
       src/matlab_octave/interpolCentersToFacesD1D.m src/matlab_octave/interpolCentersToFacesD1DPeriodic.m \
       src/matlab_octave/interpolCentersToFacesD2D.m src/matlab_octave/interpolCentersToFacesD2DPeriodic.m \
       src/matlab_octave/interpolCentersToFacesD3D.m src/matlab_octave/interpolCentersToFacesD3DPeriodic.m \
       src/matlab_octave/interpolFacesToCentersG1D.m src/matlab_octave/interpolFacesToCentersG1DPeriodic.m \
       src/matlab_octave/interpolFacesToCentersG2D.m src/matlab_octave/interpolFacesToCentersG2DPeriodic.m \
       src/matlab_octave/interpolFacesToCentersG3D.m src/matlab_octave/interpolFacesToCentersG3DPeriodic.m
```

- [ ] **Step 3.8: Run baseline regression after deletions**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy','testGridStruct','testOperatorMigration','testAPIConsolidation'}))"
```

Expected: all pass.

- [ ] **Step 3.9: Commit deletions + test updates together**

```bash
git add tests/matlab_octave/testBCConsistency.m \
        tests/matlab_octave/testGridFirstV2Migration.m
git commit -m "refactor: delete all deprecated top-level variant files and update tests"
```

---

## Done

Plan 3 complete. The public surface is exactly 9 entry points:
`makeGrid`, `validateGrid`, `grad`, `div`, `lap`, `curl`, `nodal`, `addScalarBC`, `interpol`.

All deprecated files are gone. The test suite is green.
