# Operator Migration Implementation Plan (Plan 2 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add curvilinear dispatch to `gradOp_impl`, `divOp_impl`, and `nodalOp_impl`; create `curlOp_impl` and `curl.m`; strip legacy flat-argument signatures from the four public entry points (`grad.m`, `div.m`, `lap.m`, `nodal.m`).

**Architecture:** Each operator impl gains a `if strcmpi(grid.type, 'curvilinear')` branch that delegates to a new `*Curv_impl.m` in the same `operators/` subdirectory. Those curvilinear impls read physical node coordinates from `grid.nodes.X/Y` (ndgrid layout, populated by Plan 1's `validateGrid`), transpose to meshgrid layout for the existing `jacobian2D`/`jacobian3D` helpers, and wrap the existing curvilinear math. `lapOp_impl` composes `divOp_impl * gradOp_impl` and inherits curvilinear for free. `curl.m`/`curlOp_impl.m` absorb `curl2D`'s grid-first interface. The four public entry points are rewritten to accept only `(grid, k)` and call `_impl` directly.

**Tech Stack:** MATLAB/Octave, `matlab.unittest.TestCase`, MOLE mimetic operators library

**Spec:** `docs/superpowers/specs/2026-05-21-grid-struct-refactor-design.md`
**Plan 1 completed:** `docs/superpowers/plans/2026-05-21-grid-struct-enrichment-plan1.md`

**Follow-on plan:**
- Plan 3: API consolidation + cleanup — unified `addScalarBC.m`, unified `interpol.m`, delete all deprecated top-level variant files (`grad2D.m`, `div3D.m`, `grad2DCurv.m`, etc.), delete shims (`gradOp.m`, `divOp.m`, `lapOp.m`, `nodalOp.m`, `curl2D.m`), move `jacobian2D/3D` to `geometry/metrics/`, reorganize folder structure.

---

## Coordinate Convention Note

**Critical:** The grid struct stores node arrays in `ndgrid` layout: `grid.nodes.X` is `(m+1)×(n+1)` where dimension 1 = x-axis. The existing `jacobian2D(k, X, Y)` helper expects `meshgrid` layout: `(n+1)×(m+1)` where rows = y-axis. Always transpose before passing:

```matlab
X = grid.nodes.X';   % (n+1)×(m+1) — meshgrid layout
Y = grid.nodes.Y';
```

For 3D, `grid.nodes.X` is `(m+1)×(n+1)×(o+1)` → `jacobian3D` expects `(n+1)×(m+1)×(o+1)`:

```matlab
X = permute(grid.nodes.X, [2, 1, 3]);
Y = permute(grid.nodes.Y, [2, 1, 3]);
Z = permute(grid.nodes.Z, [2, 1, 3]);
```

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `tests/matlab_octave/testOperatorMigration.m` | All Plan 2 tests |
| Create | `src/matlab_octave/operators/gradient/gradCurv_impl.m` | Curvilinear 2D+3D gradient |
| Modify | `src/matlab_octave/operators/gradient/gradOp_impl.m` | Add curvilinear dispatch branch |
| Create | `src/matlab_octave/operators/divergence/divCurv_impl.m` | Curvilinear 2D+3D divergence |
| Modify | `src/matlab_octave/operators/divergence/divOp_impl.m` | Add curvilinear dispatch branch |
| Create | `src/matlab_octave/operators/nodal/nodalCurv_impl.m` | Curvilinear 2D+3D nodal |
| Modify | `src/matlab_octave/operators/nodal/nodalOp_impl.m` | Add curvilinear dispatch branch |
| Create | `src/matlab_octave/operators/curl/curlOp_impl.m` | Grid-first 2D curl (delegates to curl2D) |
| Create | `src/matlab_octave/curl.m` | Public curl entry point `curl(grid, k)` |
| Modify | `src/matlab_octave/grad.m` | Strip legacy sigs; call gradOp_impl directly |
| Modify | `src/matlab_octave/div.m` | Strip legacy sigs; call divOp_impl directly |
| Modify | `src/matlab_octave/lap.m` | Strip legacy sigs; call lapOp_impl directly |
| Modify | `src/matlab_octave/nodal.m` | Strip legacy sigs; call nodalOp_impl directly |
| Modify | `tests/matlab_octave/testGridFirstV2Migration.m` | Fix 3 legacy calls broken by sig strip |

The shim files `gradOp.m`, `divOp.m`, `lapOp.m`, `nodalOp.m` are **kept** in Plan 2 — `grad2D.m`, `div2D.m`, etc. still call them and are not removed until Plan 3.

---

## Task 1: Curvilinear gradient dispatch

**Files:**
- Create: `tests/matlab_octave/testOperatorMigration.m`
- Create: `src/matlab_octave/operators/gradient/gradCurv_impl.m`
- Modify: `src/matlab_octave/operators/gradient/gradOp_impl.m`

- [ ] **Step 1.1: Write failing tests**

Create `tests/matlab_octave/testOperatorMigration.m`:

```matlab
classdef testOperatorMigration < matlab.unittest.TestCase
% PURPOSE
% Regression tests for Plan 2 — operator curvilinear dispatch and
% legacy-signature removal.
%
% DESCRIPTION
% Verifies that grad, div, lap, nodal accept curvilinear grids whose
% coordinate arrays were populated by validateGrid; that curl(grid, k)
% is a valid public entry point; and that grad, div, lap reject
% flat-argument signatures after the signature strip in Task 6.
%
% SYNTAX
% Run via: runtests('testOperatorMigration')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function testGradCurvilinear2DIdentityEqualsUniform(testCase)
            addpath('../../src/matlab_octave');
            % An identity curvilinear map must produce the same operator
            % as a uniform grid with the same spacing.
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);   % (m+1)×(n+1) ndgrid
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            grid_uniform = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            G_curv    = grad(grid_curv, k);
            G_uniform = grad(grid_uniform, k);
            testCase.verifyLessThan(norm(G_curv - G_uniform, 'fro'), 1e-10);
        end

        function testGradCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            % Compare grid-first curvilinear grad against the old flat-arg call.
            % grad2DCurv expects meshgrid (n+1)×(m+1) — use X' to convert.
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            G_new = grad(grid_curv, k);
            G_old = grad2DCurv(k, X', Y');
            testCase.verifyLessThan(norm(G_new - G_old, 'fro'), 1e-10);
        end

    end  % methods(Test)
end  % classdef
```

- [ ] **Step 1.2: Run — expect failure**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: errors — `grad` on a curvilinear grid falls into the uniform dim=2 branch and produces the wrong result.

- [ ] **Step 1.3: Create `gradCurv_impl.m`**

Create `src/matlab_octave/operators/gradient/gradCurv_impl.m`:

```matlab
function G = gradCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic gradient operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% grid.nodes arrays are (m+1)×(n+1) in ndgrid layout; jacobian2D/3D
% expects meshgrid layout, so a transpose / permute is applied before
% delegating to grad2DCurv / grad3DCurv.
%
% Parameters:
%   G    : Sparse matrix — curvilinear gradient operator
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% G = gradCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        % grid.nodes.X is (m+1)×(n+1) ndgrid; jacobian2D expects (n+1)×(m+1) meshgrid
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        G = grad2DCurv(k, X, Y);

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; jacobian3D expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        G = grad3DCurv(k, X, Y, Z);

    otherwise
        error('gradCurv_impl:InvalidDim', ...
              'Curvilinear gradient is only implemented for dim=2 and dim=3');
    end
end
```

- [ ] **Step 1.4: Add curvilinear branch to `gradOp_impl.m`**

In `src/matlab_octave/operators/gradient/gradOp_impl.m`, in `case 2`, add the curvilinear guard **immediately after** the two size asserts, before the `if grid.bc.isPeriodic(1)` line. The `case 2` block becomes:

```matlab
    case 2
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            G = gradCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
```

Do the same in `case 3` — add the guard after the three size asserts, before `if grid.bc.isPeriodic(1)`:

```matlab
    case 3
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.o >= 2*k, ['o >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            G = gradCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
```

- [ ] **Step 1.5: Run — expect tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: both grad curvilinear tests pass.

- [ ] **Step 1.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 1.7: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m \
        src/matlab_octave/operators/gradient/gradCurv_impl.m \
        src/matlab_octave/operators/gradient/gradOp_impl.m
git commit -m "feat: add curvilinear dispatch to gradOp_impl via gradCurv_impl"
```

---

## Task 2: Curvilinear divergence dispatch

**Files:**
- Modify: `tests/matlab_octave/testOperatorMigration.m`
- Create: `src/matlab_octave/operators/divergence/divCurv_impl.m`
- Modify: `src/matlab_octave/operators/divergence/divOp_impl.m`

- [ ] **Step 2.1: Add failing tests**

Append inside `methods(Test)` before the closing `end  % methods`:

```matlab
        function testDivCurvilinear2DIdentityEqualsUniform(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            grid_uniform = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            D_curv    = div(grid_curv, k);
            D_uniform = div(grid_uniform, k);
            testCase.verifyLessThan(norm(D_curv - D_uniform, 'fro'), 1e-10);
        end

        function testDivCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            D_new = div(grid_curv, k);
            D_old = div2DCurv(k, X', Y');
            testCase.verifyLessThan(norm(D_new - D_old, 'fro'), 1e-10);
        end
```

- [ ] **Step 2.2: Run — expect new tests fail**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: grad tests pass; div curvilinear tests fail.

- [ ] **Step 2.3: Create `divCurv_impl.m`**

Create `src/matlab_octave/operators/divergence/divCurv_impl.m`:

```matlab
function D = divCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic divergence operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% Transposes/permutes from ndgrid layout to meshgrid layout expected by
% jacobian2D/jacobian3D, then delegates to div2DCurv / div3DCurv.
%
% Parameters:
%   D    : Sparse matrix — curvilinear divergence operator
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% D = divCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        D = div2DCurv(k, X, Y);

    case 3
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        D = div3DCurv(k, X, Y, Z);

    otherwise
        error('divCurv_impl:InvalidDim', ...
              'Curvilinear divergence is only implemented for dim=2 and dim=3');
    end
end
```

- [ ] **Step 2.4: Add curvilinear branch to `divOp_impl.m`**

In `src/matlab_octave/operators/divergence/divOp_impl.m`, in `case 2`, add the guard after the two size asserts, before `if grid.bc.isPeriodic(1)`:

```matlab
    case 2
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            D = divCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
```

In `case 3`, add after the three size asserts:

```matlab
    case 3
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.o >= 2*k, ['o >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            D = divCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
```

- [ ] **Step 2.5: Run — expect all tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: all 4 tests pass.

- [ ] **Step 2.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 2.7: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m \
        src/matlab_octave/operators/divergence/divCurv_impl.m \
        src/matlab_octave/operators/divergence/divOp_impl.m
git commit -m "feat: add curvilinear dispatch to divOp_impl via divCurv_impl"
```

---

## Task 3: Verify Laplacian inherits curvilinear

`lapOp_impl.m` is:

```matlab
function L = lapOp_impl(grid, k)
    D = divOp_impl(grid, k);
    G = gradOp_impl(grid, k);
    L = D * G;
end
```

No code changes needed — curvilinear support falls through automatically. This task adds a confirming test only.

**Files:**
- Modify: `tests/matlab_octave/testOperatorMigration.m`

- [ ] **Step 3.1: Add lap curvilinear test**

Append inside `methods(Test)`:

```matlab
        function testLapCurvilinear2DIsCompositeOfDivGrad(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            L = lap(grid_curv, k);
            D = div(grid_curv, k);
            G = grad(grid_curv, k);
            testCase.verifyLessThan(norm(L - D*G, 'fro'), 1e-12);
        end
```

- [ ] **Step 3.2: Run — expect pass immediately (no implementation changes)**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: all 5 tests pass.

- [ ] **Step 3.3: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m
git commit -m "test: confirm lapOp_impl inherits curvilinear via div*grad composition"
```

---

## Task 4: Curvilinear nodal dispatch

**Files:**
- Modify: `tests/matlab_octave/testOperatorMigration.m`
- Create: `src/matlab_octave/operators/nodal/nodalCurv_impl.m`
- Modify: `src/matlab_octave/operators/nodal/nodalOp_impl.m`

- [ ] **Step 4.1: Add failing nodal curvilinear test**

Append inside `methods(Test)`:

```matlab
        function testNodalCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            % nodal2DCurv returns [Nx, Ny]; nodalOp_impl stacks them as [Nx; Ny].
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            [Nx_old, Ny_old] = nodal2DCurv(k, X', Y');
            N_new = nodal(grid_curv, k);
            N_old = [Nx_old; Ny_old];
            testCase.verifyLessThan(norm(N_new - N_old, 'fro'), 1e-10);
        end
```

- [ ] **Step 4.2: Run — expect failure**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: 5 pass, 1 fail (nodal curvilinear).

- [ ] **Step 4.3: Create `nodalCurv_impl.m`**

Create `src/matlab_octave/operators/nodal/nodalCurv_impl.m`:

```matlab
function N = nodalCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic nodal derivative operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% Transposes/permutes from ndgrid layout to meshgrid layout expected by
% nodal2DCurv / nodal3DCurv, then stacks the per-direction results into
% a single tall sparse matrix [Nx; Ny] (2D) or [Nx; Ny; Nz] (3D).
%
% Parameters:
%   N    : Stacked sparse matrix of curvilinear nodal operators
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% N = nodalCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        [Nx, Ny] = nodal2DCurv(k, X, Y);
        N = [Nx; Ny];

    case 3
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        [Nx, Ny, Nz] = nodal3DCurv(k, X, Y, Z);
        N = [Nx; Ny; Nz];

    otherwise
        error('nodalCurv_impl:InvalidDim', ...
              'Curvilinear nodal is only implemented for dim=2 and dim=3');
    end
end
```

- [ ] **Step 4.4: Add curvilinear branch to `nodalOp_impl.m`**

In `src/matlab_octave/operators/nodal/nodalOp_impl.m`, find the two assert lines at the top of the function body. Add an early-return curvilinear block immediately after them, before the `switch grid.dim` statement:

```matlab
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');

    if strcmpi(grid.type, 'curvilinear')
        N = nodalCurv_impl(grid, k);
        return;
    end

    switch grid.dim
```

- [ ] **Step 4.5: Run — expect all tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: all 6 tests pass.

- [ ] **Step 4.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 4.7: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m \
        src/matlab_octave/operators/nodal/nodalCurv_impl.m \
        src/matlab_octave/operators/nodal/nodalOp_impl.m
git commit -m "feat: add curvilinear dispatch to nodalOp_impl via nodalCurv_impl"
```

---

## Task 5: Create `curlOp_impl.m` and `curl.m`

**Files:**
- Modify: `tests/matlab_octave/testOperatorMigration.m`
- Create: `src/matlab_octave/operators/curl/curlOp_impl.m`
- Create: `src/matlab_octave/curl.m`

`curl2D.m` is not deleted here — Plan 3 removes it after absorbing its implementation into `curlOp_impl.m`. For now, `curlOp_impl.m` delegates to `curl2D`.

- [ ] **Step 5.1: Add failing curl test**

Append inside `methods(Test)`:

```matlab
        function testCurlGrid2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            m = 10; n = 8; k = 2;
            dx = 1/m; dy = 1/n;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            C_new = curl(grid, k);
            C_old = curl2D(k, m, dx, n, dy);
            testCase.verifyLessThan(norm(C_new - C_old, 'fro'), 1e-12);
        end
```

- [ ] **Step 5.2: Run — expect failure (`curl` undefined)**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: 6 pass, 1 fail with `Undefined function 'curl'`.

- [ ] **Step 5.3: Create `curlOp_impl.m`**

Create `src/matlab_octave/operators/curl/curlOp_impl.m`:

```matlab
function C = curlOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic 2-D curl operator.
%
% DESCRIPTION
% Assembles the three-component discrete curl for a 2-D uniform grid.
% Row blocks: x-component (n*(m+1) rows), y-component ((n+1)*m rows),
% scalar z-curl (n*m rows). Delegates to curl2D for the matrix assembly;
% the implementation will be absorbed inline in Plan 3 when curl2D.m is
% removed.
%
% Parameters:
%   C    : Sparse matrix — 2-D mimetic curl operator
%   grid : Validated grid struct (must be dim=2)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% C = curlOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid);

    assert(grid.dim == 2, ...
           'curlOp_impl:InvalidDim', 'curl is only implemented for 2-D grids');
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k must be even');

    C = curl2D(k, grid.m, grid.dx, grid.n, grid.dy);
end
```

- [ ] **Step 5.4: Create `curl.m`**

Create `src/matlab_octave/curl.m`:

```matlab
function C = curl(grid, k)
% PURPOSE
% Returns the mimetic 2-D curl operator for a uniform grid.
%
% DESCRIPTION
% Public entry point — accepts only the grid-struct form. Validates the
% grid and delegates to curlOp_impl. The returned matrix has three row
% blocks: x-component (n*(m+1) rows), y-component ((n+1)*m rows), and
% scalar z-curl (n*m rows).
%
% Parameters:
%   C    : Sparse matrix — 2-D mimetic curl
%   grid : Grid struct produced by makeGrid or validateGrid (must be dim=2)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% C = curl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('curl:InvalidSignature', ...
              'curl(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    C = curlOp_impl(grid, k);
end
```

- [ ] **Step 5.5: Run — expect all 7 tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: all 7 tests pass.

- [ ] **Step 5.6: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 5.7: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m \
        src/matlab_octave/operators/curl/curlOp_impl.m \
        src/matlab_octave/curl.m
git commit -m "feat: add curl(grid, k) public entry point and curlOp_impl"
```

---

## Task 6: Strip legacy signatures + rewire public entry points

The four public entry points are rewritten to accept only `(grid, k)` and call `_impl` directly — eliminating the need for the shims within those paths. The shims (`gradOp.m`, etc.) **survive** for Plan 3, which deletes `grad2D.m`, `div2D.m`, etc. that still call them.

**Files:**
- Modify: `tests/matlab_octave/testOperatorMigration.m`
- Modify: `src/matlab_octave/grad.m`
- Modify: `src/matlab_octave/div.m`
- Modify: `src/matlab_octave/lap.m`
- Modify: `src/matlab_octave/nodal.m`
- Modify: `tests/matlab_octave/testGridFirstV2Migration.m`

- [ ] **Step 6.1: Add rejection tests to `testOperatorMigration.m`**

Append inside `methods(Test)`:

```matlab
        function testGradRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() grad(2, 10, 0.1), 'grad:InvalidSignature');
        end

        function testDivRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() div(2, 10, 0.1), 'div:InvalidSignature');
        end

        function testLapRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() lap(2, 10, 0.1), 'lap:InvalidSignature');
        end
```

- [ ] **Step 6.2: Run — expect 3 new tests fail (legacy still accepted)**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: 7 pass, 3 fail.

- [ ] **Step 6.3: Rewrite `grad.m`**

Replace the entire contents of `src/matlab_octave/grad.m` with:

```matlab
function G = grad(grid, k)
% PURPOSE
% Mimetic gradient operator — 1-D, 2-D, and 3-D, uniform and curvilinear.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Validates the grid and
% dispatches to gradOp_impl, which handles uniform, periodic, and
% curvilinear grids across all dimensions.
%
% Parameters:
%   G    : Sparse matrix — mimetic gradient operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% G = grad(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('grad:InvalidSignature', ...
              'grad(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    G = gradOp_impl(grid, k);
end
```

- [ ] **Step 6.4: Rewrite `div.m`**

Replace the entire contents of `src/matlab_octave/div.m` with:

```matlab
function D = div(grid, k)
% PURPOSE
% Mimetic divergence operator — 1-D, 2-D, and 3-D, uniform and curvilinear.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Validates the grid and
% dispatches to divOp_impl, which handles uniform, periodic, and
% curvilinear grids across all dimensions.
%
% Parameters:
%   D    : Sparse matrix — mimetic divergence operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% D = div(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('div:InvalidSignature', ...
              'div(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    D = divOp_impl(grid, k);
end
```

- [ ] **Step 6.5: Rewrite `lap.m`**

Replace the entire contents of `src/matlab_octave/lap.m` with:

```matlab
function L = lap(grid, k)
% PURPOSE
% Mimetic Laplacian operator — 1-D, 2-D, and 3-D, uniform and curvilinear.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Composes div*grad via
% lapOp_impl, which inherits curvilinear support from the individual
% operator impls.
%
% Parameters:
%   L    : Sparse matrix — mimetic Laplacian operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% L = lap(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('lap:InvalidSignature', ...
              'lap(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    L = lapOp_impl(grid, k);
end
```

- [ ] **Step 6.6: Rewrite `nodal.m`**

Replace the entire contents of `src/matlab_octave/nodal.m` with:

```matlab
function N = nodal(grid, k)
% PURPOSE
% Mimetic nodal derivative operator — 1-D, 2-D, and 3-D.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Validates the grid and
% dispatches to nodalOp_impl, which handles uniform and curvilinear grids.
%
% Parameters:
%   N    : Sparse matrix — mimetic nodal derivative operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% N = nodal(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('nodal:InvalidSignature', ...
              'nodal(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    N = nodalOp_impl(grid, k);
end
```

- [ ] **Step 6.7: Fix broken calls in `testGridFirstV2Migration.m`**

In `testGridFirstOperatorsMatchLegacy1D`, three lines use the now-removed flat-arg form of `grad`, `div`, `lap`. Replace them:

Find:
```matlab
Gold = grad(k, m, dx);
```
Replace with:
```matlab
Gold = gradNonPeriodic(k, m, dx);
```

Find:
```matlab
Dold = div(k, m, dx);
```
Replace with:
```matlab
Dold = divNonPeriodic(k, m, dx);
```

Find:
```matlab
Lold = lap(k, m, dx);
```
Replace with:
```matlab
Lold = lapNonPeriodic(k, m, dx);
```

- [ ] **Step 6.8: Run `testOperatorMigration` — expect all 10 tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testOperatorMigration'))"
```

Expected: all 10 tests pass.

- [ ] **Step 6.9: Run baseline regression — expect all pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass. The 2D/3D migration tests (`testGridFirstOperatorsMatchLegacy2D`, `testGridFirstOperatorsMatchLegacy3D`) still call `grad2D(grid, k)` / `grad3D(grid, k)` which go through `gradOp.m` — those shims still exist.

- [ ] **Step 6.10: Commit**

```bash
git add tests/matlab_octave/testOperatorMigration.m \
        src/matlab_octave/grad.m \
        src/matlab_octave/div.m \
        src/matlab_octave/lap.m \
        src/matlab_octave/nodal.m \
        tests/matlab_octave/testGridFirstV2Migration.m
git commit -m "refactor: strip legacy flat-arg signatures from grad, div, lap, nodal entry points"
```

---

## Done

Plan 2 complete. The operator layer now:
- Dispatches `grid.type='curvilinear'` grids to `gradCurv_impl`, `divCurv_impl`, `nodalCurv_impl` (reading `grid.nodes.X/Y/Z` populated by Plan 1)
- Provides `curl(grid, k)` as a new public entry point backed by `curlOp_impl`
- Accepts only `(grid, k)` at the four public entry points; flat-argument calls throw `*:InvalidSignature`
- The shims `gradOp.m` / `divOp.m` / `lapOp.m` / `nodalOp.m` survive until Plan 3 deletes their callers

**Next:** Plan 3 — API consolidation + cleanup: unified `addScalarBC.m`, unified `interpol.m`, delete all deprecated top-level variant files (`grad2D.m`, `grad2DCurv.m`, `divOp.m`, `curl2D.m`, etc.), absorb `curl2D` logic into `curlOp_impl`, move `jacobian2D/3D` to `geometry/metrics/jacobian_impl.m`, reorganize folder structure.
