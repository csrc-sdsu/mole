# Grid Struct Enrichment Implementation Plan (Plan 1 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `validateGrid` and `makeGrid` to compute and store mesh coordinate arrays (`nodes`, `faces`, `centers`) for uniform 1D/2D/3D and curvilinear 2D grids, and validate their sizes against `m/n/o`.

**Architecture:** All coordinate generation lives in `validateGrid_impl.m` as new local helpers (`localGenerateCoordinates1D/2D/3D` and `localDeriveCurvilinearCoordinates2D`). `makeGrid` already calls `validateGrid` so it gains coordinate arrays for free. `private/normalizeGrid*.m` are deleted (already thin shims that delegate to `validateGrid`). Tests follow MATLAB `classdef` `matlab.unittest.TestCase` pattern in `tests/matlab_octave/`.

**Tech Stack:** MATLAB/Octave, `ndgrid`, `matlab.unittest.TestCase`, MOLE mimetic operators library

**Spec:** `docs/superpowers/specs/2026-05-21-grid-struct-refactor-design.md`

**Follow-on plans:**
- Plan 2: Operator migration — update `gradOp_impl`, `divOp_impl`, etc. to dispatch on `grid.type = 'curvilinear'` using `grid.nodes.X/Y`; create `curlOp_impl`; strip legacy signatures from entry points.
- Plan 3: API consolidation + cleanup — unified `addScalarBC.m`, unified `interpol.m`, delete all deprecated files, move utils/internal.

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `tests/matlab_octave/testGridStruct.m` | All coordinate array tests |
| Modify | `src/matlab_octave/api/validateGrid_impl.m` | Add coordinate generation helpers |
| Delete | `src/matlab_octave/private/normalizeGrid1D.m` | Already-thin shim |
| Delete | `src/matlab_octave/private/normalizeGrid2D.m` | Already-thin shim |
| Delete | `src/matlab_octave/private/normalizeGrid3D.m` | Already-thin shim |

`makeGrid_impl.m` and `makeGrid.m` require no changes — `makeGrid` calls `validateGrid`, which now produces coordinate arrays.

---

## Task 1: Test skeleton + 1D uniform coordinate arrays

**Files:**
- Create: `tests/matlab_octave/testGridStruct.m`
- Modify: (none yet)

- [ ] **Step 1.1: Write the failing test**

Create `tests/matlab_octave/testGridStruct.m`:

```matlab
classdef testGridStruct < matlab.unittest.TestCase
% PURPOSE
% Unit tests for enriched grid struct coordinate arrays.
%
% DESCRIPTION
% Verifies that makeGrid and validateGrid populate grid.nodes,
% grid.faces, and grid.centers with correctly-sized meshgrid arrays
% for uniform 1-D, 2-D, and 3-D grids, curvilinear 2-D grids, and
% that size mismatches throw the correct error IDs.
%
% SYNTAX
% Run via: runtests('testGridStruct')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function test1DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.nodes));
            testCase.verifySize(grid.nodes.X, [m+1, 1]);
            testCase.verifyEqual(grid.nodes.X(1),   0,      'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end),  m*dx,  'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(2),    dx,    'AbsTol', 1e-14);
        end

        function test1DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.centers));
            testCase.verifySize(grid.centers.X, [m+2, 1]);
            testCase.verifyEqual(grid.centers.X(1),   0,          'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(2),   0.5*dx,     'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(end),  m*dx,      'AbsTol', 1e-14);
        end

        function test1DUniformFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.faces));
            testCase.verifySize(grid.faces.X, [m+1, 1]);
            testCase.verifyEqual(grid.faces.X, grid.nodes.X, 'AbsTol', 1e-14);
        end

    end  % methods(Test)
end  % classdef
```

- [ ] **Step 1.2: Run the test — expect failure**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: errors because `grid.nodes`, `grid.faces`, `grid.centers` fields do not exist yet.

- [ ] **Step 1.3: Implement 1D coordinate generation in `validateGrid_impl.m`**

In `src/matlab_octave/api/validateGrid_impl.m`, add a call at the end of `localNormalizeGrid1D` and a new local function. Find the end of `localNormalizeGrid1D` (currently ends after setting `grid.bc` and `grid.type`):

```matlab
% EXISTING end of localNormalizeGrid1D — add one line before the closing end:
    grid = localGenerateCoordinates1D(grid);
end
```

Then add this new local function at the bottom of the file (before the final `end` if the file is a classdef, or just appended if it is a plain script with local functions):

```matlab
function grid = localGenerateCoordinates1D(grid)
    m  = grid.m;
    dx = grid.dx;

    x_node   = (0:m)' * dx;                              % (m+1)×1
    x_center = [0; ((1:m) - 0.5)' * dx; m * dx];        % (m+2)×1
    x_face   = x_node;                                   % (m+1)×1

    grid.nodes.X   = x_node;
    grid.centers.X = x_center;
    grid.faces.X   = x_face;
end
```

- [ ] **Step 1.4: Run the test — expect pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: 3 tests pass, 0 failed.

- [ ] **Step 1.5: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all existing tests still pass (coordinate generation is additive; nothing is broken).

- [ ] **Step 1.6: Commit**

```bash
git add tests/matlab_octave/testGridStruct.m src/matlab_octave/api/validateGrid_impl.m
git commit -m "feat: add 1D coordinate arrays to grid struct"
```

---

## Task 2: 2D uniform coordinate arrays

**Files:**
- Modify: `tests/matlab_octave/testGridStruct.m` (add 2D tests)
- Modify: `src/matlab_octave/api/validateGrid_impl.m` (add 2D coord helper)

- [ ] **Step 2.1: Add 2D tests to `testGridStruct.m`**

Append inside `methods(Test)` before the closing `end`:

```matlab
        function test2DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.nodes));
            testCase.verifySize(grid.nodes.X, [m+1, n+1]);
            testCase.verifySize(grid.nodes.Y, [m+1, n+1]);
            % first row: x advances with dx, y = 0
            testCase.verifyEqual(grid.nodes.X(1, 1), 0,    'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end, 1), m*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Y(1, 1), 0,    'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Y(1, end), n*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifySize(grid.centers.X, [m+2, n+2]);
            testCase.verifySize(grid.centers.Y, [m+2, n+2]);
            testCase.verifyEqual(grid.centers.X(1,1), 0,      'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(2,1), 0.5*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.Y(1,2), 0.5*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformUFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.faces));
            testCase.verifyTrue(isstruct(grid.faces.u));
            testCase.verifySize(grid.faces.u.X, [m+1, n]);
            testCase.verifySize(grid.faces.u.Y, [m+1, n]);
            % u-face x-coords same as node x-coords (all m+1 x-positions)
            testCase.verifyEqual(grid.faces.u.X(:, 1), grid.nodes.X(:, 1), 'AbsTol', 1e-14);
            % u-face y-coords are cell centers in y (n values)
            testCase.verifyEqual(grid.faces.u.Y(1, 1), 0.5*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformVFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.faces.v));
            testCase.verifySize(grid.faces.v.X, [m, n+1]);
            testCase.verifySize(grid.faces.v.Y, [m, n+1]);
            % v-face y-coords same as node y-coords
            testCase.verifyEqual(grid.faces.v.Y(1, :)', grid.nodes.Y(1, :)', 'AbsTol', 1e-14);
            % v-face x-coords are cell centers in x (m values)
            testCase.verifyEqual(grid.faces.v.X(1, 1), 0.5*dx, 'AbsTol', 1e-14);
        end
```

- [ ] **Step 2.2: Run — expect failure on 2D tests**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: 1D tests pass, 2D tests fail with field-not-found errors.

- [ ] **Step 2.3: Add `localGenerateCoordinates2D` to `validateGrid_impl.m` and call it**

At the end of `localNormalizeGrid2D` (before its closing `end`), add:

```matlab
    grid = localGenerateCoordinates2D(grid);
```

Then add the new local function at the bottom of the file:

```matlab
function grid = localGenerateCoordinates2D(grid)
    m = grid.m; n = grid.n;
    dx = grid.dx; dy = grid.dy;

    xn = (0:m) * dx;                          % node x: m+1 values
    yn = (0:n) * dy;                           % node y: n+1 values
    xc = [0, (0.5:m-0.5) * dx, m*dx];         % center x: m+2 values
    yc = [0, (0.5:n-0.5) * dy, n*dy];         % center y: n+2 values
    xu = xn;                                   % u-face x: m+1 (same as nodes)
    yu = (0.5:n-0.5) * dy;                    % u-face y: n values
    xv = (0.5:m-0.5) * dx;                    % v-face x: m values
    yv = yn;                                   % v-face y: n+1 (same as nodes)

    [grid.nodes.X,   grid.nodes.Y]   = ndgrid(xn, yn);
    [grid.centers.X, grid.centers.Y] = ndgrid(xc, yc);
    [grid.faces.u.X, grid.faces.u.Y] = ndgrid(xu, yu);
    [grid.faces.v.X, grid.faces.v.Y] = ndgrid(xv, yv);
end
```

- [ ] **Step 2.4: Run — expect all 2D tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: all tests pass.

- [ ] **Step 2.5: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 2.6: Commit**

```bash
git add tests/matlab_octave/testGridStruct.m src/matlab_octave/api/validateGrid_impl.m
git commit -m "feat: add 2D coordinate arrays to grid struct"
```

---

## Task 3: 3D uniform coordinate arrays

**Files:**
- Modify: `tests/matlab_octave/testGridStruct.m`
- Modify: `src/matlab_octave/api/validateGrid_impl.m`

- [ ] **Step 3.1: Add 3D tests to `testGridStruct.m`**

Append inside `methods(Test)`:

```matlab
        function test3DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.nodes.X, [m+1, n+1, o+1]);
            testCase.verifySize(grid.nodes.Y, [m+1, n+1, o+1]);
            testCase.verifySize(grid.nodes.Z, [m+1, n+1, o+1]);
            testCase.verifyEqual(grid.nodes.X(1,1,1), 0,     'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end,1,1), m*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Z(1,1,end), o*dz, 'AbsTol', 1e-14);
        end

        function test3DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.centers.X, [m+2, n+2, o+2]);
            testCase.verifySize(grid.centers.Y, [m+2, n+2, o+2]);
            testCase.verifySize(grid.centers.Z, [m+2, n+2, o+2]);
        end

        function test3DUniformFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.faces.u.X, [m+1, n,   o  ]);
            testCase.verifySize(grid.faces.v.X, [m,   n+1, o  ]);
            testCase.verifySize(grid.faces.w.X, [m,   n,   o+1]);
        end
```

- [ ] **Step 3.2: Run — expect failure on 3D tests**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: 1D/2D pass, 3D tests fail.

- [ ] **Step 3.3: Add `localGenerateCoordinates3D` to `validateGrid_impl.m`**

At the end of `localNormalizeGrid3D`, add:

```matlab
    grid = localGenerateCoordinates3D(grid);
```

Add local function at the bottom of the file:

```matlab
function grid = localGenerateCoordinates3D(grid)
    m = grid.m; n = grid.n; o = grid.o;
    dx = grid.dx; dy = grid.dy; dz = grid.dz;

    xn = (0:m) * dx;
    yn = (0:n) * dy;
    zn = (0:o) * dz;
    xc = [0, (0.5:m-0.5) * dx, m*dx];
    yc = [0, (0.5:n-0.5) * dy, n*dy];
    zc = [0, (0.5:o-0.5) * dz, o*dz];

    [grid.nodes.X,   grid.nodes.Y,   grid.nodes.Z]   = ndgrid(xn, yn, zn);
    [grid.centers.X, grid.centers.Y, grid.centers.Z] = ndgrid(xc, yc, zc);

    [grid.faces.u.X, grid.faces.u.Y, grid.faces.u.Z] = ndgrid(xn, (0.5:n-0.5)*dy, (0.5:o-0.5)*dz);
    [grid.faces.v.X, grid.faces.v.Y, grid.faces.v.Z] = ndgrid((0.5:m-0.5)*dx, yn, (0.5:o-0.5)*dz);
    [grid.faces.w.X, grid.faces.w.Y, grid.faces.w.Z] = ndgrid((0.5:m-0.5)*dx, (0.5:n-0.5)*dy, zn);
end
```

- [ ] **Step 3.4: Run — expect all 3D tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: all tests pass.

- [ ] **Step 3.5: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 3.6: Commit**

```bash
git add tests/matlab_octave/testGridStruct.m src/matlab_octave/api/validateGrid_impl.m
git commit -m "feat: add 3D coordinate arrays to grid struct"
```

---

## Task 4: Curvilinear 2D coordinate arrays

**Files:**
- Modify: `tests/matlab_octave/testGridStruct.m`
- Modify: `src/matlab_octave/api/validateGrid_impl.m`

- [ ] **Step 4.1: Add curvilinear tests to `testGridStruct.m`**

Append inside `methods(Test)`:

```matlab
        function test2DCurvilinearNodeValidation(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5;
            % Provide physical node coordinates for a simple stretched grid
            [X, Y] = ndgrid(linspace(0,1,m+1), linspace(0,2,n+1));
            grid = struct('m', m, 'n', n, 'dx', 1, 'dy', 1, ...
                          'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid = validateGrid(grid);

            testCase.verifySize(grid.nodes.X, [m+1, n+1]);
            testCase.verifySize(grid.nodes.Y, [m+1, n+1]);
        end

        function test2DCurvilinearFacesAndCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5;
            [X, Y] = ndgrid(linspace(0,1,m+1), linspace(0,2,n+1));
            grid = struct('m', m, 'n', n, 'dx', 1, 'dy', 1, ...
                          'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid = validateGrid(grid);

            testCase.verifySize(grid.faces.u.X, [m+1, n  ]);
            testCase.verifySize(grid.faces.v.X, [m,   n+1]);
            testCase.verifySize(grid.centers.X, [m+2, n+2]);
        end

        function test2DCurvilinearMissingNodesError(testCase)
            addpath('../../src/matlab_octave');
            grid = struct('m', 4, 'n', 5, 'dx', 1, 'dy', 1, 'type', 'curvilinear');
            testCase.verifyError(@() validateGrid(grid), ...
                'validateGrid:CurvilinearMissingNodes');
        end
```

- [ ] **Step 4.2: Run — expect failure on curvilinear tests**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: 1D/2D/3D pass, curvilinear tests fail.

- [ ] **Step 4.3: Add curvilinear handling to `localNormalizeGrid2D` in `validateGrid_impl.m`**

In `localNormalizeGrid2D`, before the call to `localGenerateCoordinates2D`, add a branch:

```matlab
    if strcmpi(grid.type, 'curvilinear')
        grid = localDeriveCurvilinearCoordinates2D(grid);
    else
        grid = localGenerateCoordinates2D(grid);
    end
```

Add the new local function at the bottom of the file:

```matlab
function grid = localDeriveCurvilinearCoordinates2D(grid)
    if ~isfield(grid, 'nodes') || ~isfield(grid.nodes, 'X') || ~isfield(grid.nodes, 'Y')
        error('validateGrid:CurvilinearMissingNodes', ...
              'grid.type=''curvilinear'' requires grid.nodes.X and grid.nodes.Y');
    end

    m = grid.m; n = grid.n;
    NX = grid.nodes.X;  % (m+1)×(n+1)
    NY = grid.nodes.Y;

    if ~isequal(size(NX), [m+1, n+1])
        error('validateGrid:SizeMismatch', ...
              'grid.nodes.X must be %dx%d for m=%d, n=%d; got %dx%d', ...
              m+1, n+1, m, n, size(NX,1), size(NX,2));
    end
    if ~isequal(size(NY), [m+1, n+1])
        error('validateGrid:SizeMismatch', ...
              'grid.nodes.Y must be %dx%d for m=%d, n=%d; got %dx%d', ...
              m+1, n+1, m, n, size(NY,1), size(NY,2));
    end

    % U-faces: (m+1)×n — average nodes across y pairs
    grid.faces.u.X = (NX(:, 1:end-1) + NX(:, 2:end)) / 2;
    grid.faces.u.Y = (NY(:, 1:end-1) + NY(:, 2:end)) / 2;

    % V-faces: m×(n+1) — average nodes across x pairs
    grid.faces.v.X = (NX(1:end-1, :) + NX(2:end, :)) / 2;
    grid.faces.v.Y = (NY(1:end-1, :) + NY(2:end, :)) / 2;

    % Interior cell centers: m×n — bilinear average of 4 surrounding nodes
    cx = (NX(1:end-1,1:end-1) + NX(2:end,1:end-1) + ...
          NX(1:end-1,2:end)   + NX(2:end,2:end)) / 4;
    cy = (NY(1:end-1,1:end-1) + NY(2:end,1:end-1) + ...
          NY(1:end-1,2:end)   + NY(2:end,2:end)) / 4;

    % Boundary face centers for (m+2)×(n+2) centers array
    left_x  = (NX(1:end-1,1) + NX(2:end,1)) / 2;  % m×1
    left_y  = (NY(1:end-1,1) + NY(2:end,1)) / 2;
    right_x = (NX(1:end-1,end) + NX(2:end,end)) / 2;
    right_y = (NY(1:end-1,end) + NY(2:end,end)) / 2;
    bot_x   = (NX(1,1:end-1) + NX(1,2:end)) / 2;  % 1×n
    bot_y   = (NY(1,1:end-1) + NY(1,2:end)) / 2;
    top_x   = (NX(end,1:end-1) + NX(end,2:end)) / 2;
    top_y   = (NY(end,1:end-1) + NY(end,2:end)) / 2;

    CX = zeros(m+2, n+2);  CY = zeros(m+2, n+2);
    CX(2:m+1, 2:n+1) = cx;  CY(2:m+1, 2:n+1) = cy;
    CX(2:m+1, 1) = left_x;  CY(2:m+1, 1) = left_y;
    CX(2:m+1, n+2) = right_x; CY(2:m+1, n+2) = right_y;
    CX(1, 2:n+1) = bot_x;   CY(1, 2:n+1) = bot_y;
    CX(m+2, 2:n+1) = top_x; CY(m+2, 2:n+1) = top_y;
    CX(1,1) = NX(1,1);       CY(1,1) = NY(1,1);
    CX(1,n+2) = NX(1,end);   CY(1,n+2) = NY(1,end);
    CX(m+2,1) = NX(end,1);   CY(m+2,1) = NY(end,1);
    CX(m+2,n+2) = NX(end,end); CY(m+2,n+2) = NY(end,end);
    grid.centers.X = CX;
    grid.centers.Y = CY;
end
```

- [ ] **Step 4.4: Run — expect all curvilinear tests pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: all tests pass.

- [ ] **Step 4.5: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 4.6: Commit**

```bash
git add tests/matlab_octave/testGridStruct.m src/matlab_octave/api/validateGrid_impl.m
git commit -m "feat: add curvilinear 2D coordinate derivation to validateGrid"
```

---

## Task 5: Verify size mismatch and missing-node errors are correctly thrown

Task 4 already added `test2DNodeSizeMismatchError` and `test2DCurvilinearMissingNodesError`. This task confirms the error IDs fire as expected after the Task 4 implementation fixes.

> **Note:** Size validation only applies to curvilinear grids where the user supplies `grid.nodes.X/Y`. For uniform grids, `validateGrid` always regenerates coordinate arrays, so pre-populated coordinates are simply replaced — there is nothing to validate.

**Files:**
- Modify: `tests/matlab_octave/testGridStruct.m` (add Y-axis size mismatch test)
- No changes to `validateGrid_impl.m` needed (error IDs already correct after Task 4)

- [ ] **Step 5.1: Add Y-axis node size mismatch test**

Append inside `methods(Test)` in `testGridStruct.m`:

```matlab
        function test2DNodeYSizeMismatchError(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5;
            good_X = zeros(m+1, n+1);
            bad_Y  = zeros(m+1, n);   % wrong: should be (m+1)×(n+1)
            grid = struct('m', m, 'n', n, 'dx', 1, 'dy', 1, ...
                          'type', 'curvilinear', ...
                          'nodes', struct('X', good_X, 'Y', bad_Y));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:SizeMismatch');
        end
```

- [ ] **Step 5.2: Run all tests — expect pass**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); assertSuccess(runtests('testGridStruct'))"
```

Expected: all tests pass.

- [ ] **Step 5.3: Run baseline regression**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 5.4: Commit**

```bash
git add tests/matlab_octave/testGridStruct.m
git commit -m "test: add Y-axis curvilinear size mismatch test to testGridStruct"
```

---

## Task 6: Delete private normalizer shims and add headers

**Files:**
- Delete: `src/matlab_octave/private/normalizeGrid1D.m`
- Delete: `src/matlab_octave/private/normalizeGrid2D.m`
- Delete: `src/matlab_octave/private/normalizeGrid3D.m`
- Modify: `src/matlab_octave/api/validateGrid_impl.m` (add full header)

- [ ] **Step 6.1: Confirm shims are no longer needed**

The three private normalizers currently contain only:
```matlab
function grid = normalizeGridND(grid)
    grid.dim = N;
    grid = validateGrid(grid);
end
```
No other file should be calling them directly after the v2 migration. Verify:

```bash
grep -r "normalizeGrid1D\|normalizeGrid2D\|normalizeGrid3D" \
    /home/jbrzensk/github/MOLE/mole/src/matlab_octave/ \
    --include="*.m" -l
```

Expected: only the three normalizer files themselves appear. If other files still call them, update those callers to call `validateGrid` directly before deleting.

- [ ] **Step 6.2: Delete the shims**

```bash
git rm src/matlab_octave/private/normalizeGrid1D.m \
       src/matlab_octave/private/normalizeGrid2D.m \
       src/matlab_octave/private/normalizeGrid3D.m
```

- [ ] **Step 6.3: Add full header to `validateGrid_impl.m`**

Replace the current one-liner at the top:

```matlab
function grid = validateGrid_impl(grid, allowPartial)
% Canonical implementation for validateGrid.
```

With the full header:

```matlab
function grid = validateGrid_impl(grid, allowPartial)
% PURPOSE
% Canonical implementation for validateGrid — normalizes and enriches a
% grid struct with coordinate arrays for nodes, faces, and centers.
%
% DESCRIPTION
% Accepts a partial or complete grid struct, infers dim and type from
% present fields, normalizes grid.bc.{dc,nc,isPeriodic}, and populates
% grid.nodes, grid.faces, and grid.centers with meshgrid-style arrays.
% For curvilinear grids, grid.nodes.X/Y must be supplied by the caller;
% faces and centers are derived by interpolation.
% Throws validateGrid:SizeMismatch if pre-populated coordinate arrays
% disagree with m/n/o, and validateGrid:CurvilinearMissingNodes if a
% curvilinear grid lacks node coordinates.
%
% Parameters:
%   grid         : Input struct (partial or complete)
%   allowPartial : (optional) logical, default false — skip missing-field
%                  errors during incremental construction
%
% SYNTAX
% grid = validateGrid_impl(grid)
% grid = validateGrid_impl(grid, allowPartial)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
```

- [ ] **Step 6.4: Run all tests**

```bash
cd /home/jbrzensk/github/MOLE/mole/tests/matlab_octave
matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testGridStruct','testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
```

Expected: all pass.

- [ ] **Step 6.5: Commit**

```bash
git add src/matlab_octave/api/validateGrid_impl.m
git commit -m "refactor: delete private normalizeGrid shims and add full header to validateGrid_impl"
```

---

## Done

Plan 1 complete. `makeGrid` and `validateGrid` now produce a fully-populated grid struct with `nodes`, `faces`, and `centers` coordinate arrays for all uniform and curvilinear 2D cases. The baseline regression suite is green.

**Next:** Proceed to Plan 2 — Operator Migration (update `gradOp_impl`, `divOp_impl`, `lapOp_impl`, `nodalOp_impl` to dispatch curvilinear via `grid.nodes.X/Y`; extract `grad2DCurv`/`div2DCurv` logic into `operators/gradient/gradCurv_impl.m` etc.; create `operators/curl/curlOp_impl.m`; strip legacy signatures from `grad.m`, `div.m`, `lap.m`, `nodal.m`).
