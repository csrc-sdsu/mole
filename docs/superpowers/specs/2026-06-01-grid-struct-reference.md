# MOLE Grid Struct Reference (MATLAB/Octave)

**Date:** 2026-06-01  
**Scope:** MATLAB/Octave grid struct — fields, coordinate arrays, and curvilinear support  
**Audience:** C++ developers implementing an equivalent `Grid` type

---

## 1. Overview

The grid struct is the central data object passed to all MOLE mimetic operators
(`grad`, `div`, `lap`, `curl`, `nodal`, `addScalarBC`, `interpol`). It bundles
everything an operator needs to know about the physical domain: how many cells
exist in each direction, how large each cell is, where nodes/faces/cell-centers
sit in physical space, and what type of boundary treatment is expected.

Two public functions build and validate the struct:

```matlab
grid = makeGrid('m', 64, 'n', 64, 'dx', 1/64, 'dy', 1/64, 'bc', bc)
grid = validateGrid(grid)   % explicit re-validation / enrichment
```

`makeGrid` accepts either name-value pairs or a partially filled struct and
always calls `validateGrid` before returning. `validateGrid` infers missing
metadata fields, normalises boundary coefficients, and populates all coordinate
arrays. Callers should treat the returned struct as immutable: operators read
from it but never write to it.

---

## 2. Core Fields

### 2.1 `dim` — dimensionality

| Value | Meaning |
|-------|---------|
| `1`   | 1-D problem (x only) |
| `2`   | 2-D problem (x, y) |
| `3`   | 3-D problem (x, y, z) |

**Inferred automatically** from whichever size fields are present:

- `o` or `dz` present → `dim = 3`
- `n` or `dy` present → `dim = 2`
- otherwise → `dim = 1`

### 2.2 `type` — grid topology

| Value          | Meaning |
|----------------|---------|
| `'uniform'`    | Constant spacing (`dx`/`dy`/`dz` scalars); no periodic axes |
| `'periodic'`   | Constant spacing; one or more axes are periodic |
| `'curvilinear'`| Physical coordinates supplied by the caller as node arrays |

**Inferred automatically:**

- `X`, `Y`, or `Z` fields present at struct root → `'curvilinear'`  
- `x`, `y`, or `z` fields (lowercase) present → `'nonuniform'` *(reserved, not yet active)*  
- otherwise → `'uniform'` or `'periodic'` depending on boundary coefficients

### 2.3 Cell counts: `m`, `n`, `o`

| Field | Axis | Required for |
|-------|------|-------------|
| `m`   | x    | 1-D, 2-D, 3-D |
| `n`   | y    | 2-D, 3-D |
| `o`   | z    | 3-D |

These are **cell counts**, not node counts. A grid with `m` cells in x has
`m+1` nodes along x.

For curvilinear grids, `m`/`n`/`o` must equal the node-array dimension minus one:
`nodes.X` must be `(m+1) × (n+1)` for 2-D, `(m+1) × (n+1) × (o+1)` for 3-D.

### 2.4 Cell spacings: `dx`, `dy`, `dz`

Scalar values giving the uniform physical spacing between adjacent nodes along
each axis. Required for uniform and periodic grids; **not used** for
curvilinear grids (physical distances are encoded in the node coordinate
arrays instead).

### 2.5 `bc` — boundary condition sub-struct

The `bc` sub-struct encodes Robin boundary coefficients and periodicity flags.
See the companion *Boundary Conditions Reference* document for full details.
The fields relevant to the grid struct itself are:

- `bc.isPeriodic` — logical vector (`1×1` for 1-D, `2×1` for 2-D, `3×1` for 3-D).
  Each element is `true` if the corresponding axis wraps around. Used by
  `validateGrid` to set `grid.type = 'periodic'`.

---

## 3. Coordinate Arrays

After `validateGrid`, the struct contains three sub-structs holding physical
coordinates for every point class in the staggered mimetic grid:

| Sub-struct | Point class | Role |
|------------|-------------|------|
| `nodes`    | Grid corners | Where physical boundaries and node values live |
| `faces`    | Cell-face midpoints | Where flux (vector field) unknowns live |
| `centers`  | Cell interiors | Where scalar (potential) unknowns live |

All arrays use **ndgrid layout**: the first index varies in x, the second in y,
the third in z. This is the opposite of MATLAB's default `meshgrid` convention.

### 3.1 One-dimensional grid

| Field | Size | Description |
|-------|------|-------------|
| `nodes.X`   | `(m+1) × 1` | `0, dx, 2·dx, …, m·dx` |
| `faces.X`   | `(m+1) × 1` | Identical to `nodes.X` (in 1-D, face midpoints coincide with nodes) |
| `centers.X` | `(m+2) × 1` | `0, 0.5·dx, 1.5·dx, …, (m−0.5)·dx, m·dx` |

The centers array has **two ghost entries**: the first element (`0`) and the
last element (`m·dx`) mirror the domain boundary. This is required so that
the mimetic boundary condition operator can augment the interior matrix rows
with boundary data without resizing.

### 3.2 Two-dimensional grid

Face arrays are split by normal direction — `u` faces are perpendicular to x
(x-normal), `v` faces are perpendicular to y (y-normal).

| Field | Size | Description |
|-------|------|-------------|
| `nodes.X`, `nodes.Y`     | `(m+1) × (n+1)` | ndgrid of node positions |
| `centers.X`, `centers.Y` | `(m+2) × (n+2)` | ndgrid with ghost padding on all sides |
| `faces.u.X`, `faces.u.Y` | `(m+1) × n`     | x-normal face midpoints |
| `faces.v.X`, `faces.v.Y` | `m × (n+1)`     | y-normal face midpoints |

**u-face coordinate ranges (uniform):**

```
faces.u.X = 0, dx, 2·dx, …, m·dx          (m+1 values — same as node x-positions)
faces.u.Y = 0.5·dy, 1.5·dy, …, (n−0.5)·dy (n values — face centers between node rows)
```

**v-face coordinate ranges (uniform):**

```
faces.v.X = 0.5·dx, 1.5·dx, …, (m−0.5)·dx (m values)
faces.v.Y = 0, dy, 2·dy, …, n·dy           (n+1 values — same as node y-positions)
```

### 3.3 Three-dimensional grid

Face arrays split into three components: `u` (x-normal), `v` (y-normal),
`w` (z-normal).

| Field | Size | Description |
|-------|------|-------------|
| `nodes.X/Y/Z`     | `(m+1) × (n+1) × (o+1)` | ndgrid of node positions |
| `centers.X/Y/Z`   | `(m+2) × (n+2) × (o+2)` | ghost-padded ndgrid |
| `faces.u.X/Y/Z`   | `(m+1) × n × o`         | x-normal faces |
| `faces.v.X/Y/Z`   | `m × (n+1) × o`         | y-normal faces |
| `faces.w.X/Y/Z`   | `m × n × (o+1)`         | z-normal faces |

The pattern is consistent: the face component named after a direction (`u`→x,
`v`→y, `w`→z) has a full node count in that direction and cell-center count in
the other two directions.

---

## 4. Curvilinear Grids

For non-uniform physical domains the caller constructs a partially filled
struct, populates the node coordinate arrays, then passes it to `validateGrid`:

```matlab
g = struct();
g.m = m - 1;   % cell count = node count - 1
g.n = n - 1;
g.type = 'curvilinear';
g.nodes.X = X';   % (m+1) × (n+1) node array, transposed to ndgrid layout
g.nodes.Y = Y';
g = validateGrid(g);
```

### 4.1 What the caller must supply

| Dimension | Required fields |
|-----------|----------------|
| 2-D | `m`, `n`, `type='curvilinear'`, `nodes.X`, `nodes.Y` |
| 3-D | `m`, `n`, `o`, `type='curvilinear'`, `nodes.X`, `nodes.Y`, `nodes.Z` |

Node arrays must be exact size `(m+1) × (n+1)` (2-D) or
`(m+1) × (n+1) × (o+1)` (3-D) in ndgrid layout (x-index first).
`validateGrid` throws `validateGrid:SizeMismatch` if the sizes are wrong, and
`validateGrid:CurvilinearMissingNodes` if the arrays are absent.

### 4.2 What `validateGrid` derives

All coordinate arrays are computed by averaging the caller-supplied node
positions. No `dx`/`dy`/`dz` is computed or stored; physical distances are
implicit in the node positions themselves.

**u-faces** (x-normal): average of adjacent nodes along the n-direction (column pairs):

```
faces.u.X(:, j) = 0.5 * (nodes.X(:, j) + nodes.X(:, j+1))   for j = 1…n
faces.u.Y(:, j) = 0.5 * (nodes.Y(:, j) + nodes.Y(:, j+1))
```

Size: `(m+1) × n`.

**v-faces** (y-normal): average of adjacent nodes along the m-direction (row pairs):

```
faces.v.X(i, :) = 0.5 * (nodes.X(i, :) + nodes.X(i+1, :))   for i = 1…m
faces.v.Y(i, :) = 0.5 * (nodes.Y(i, :) + nodes.Y(i+1, :))
```

Size: `m × (n+1)`.

**Cell centers**: bilinear average of the four surrounding corner nodes:

```
centers.X(i, j) = 0.25 * (nodes.X(i,j) + nodes.X(i+1,j) + nodes.X(i,j+1) + nodes.X(i+1,j+1))
centers.Y(i, j) = 0.25 * (nodes.Y(i,j) + nodes.Y(i+1,j) + nodes.Y(i,j+1) + nodes.Y(i+1,j+1))
```

Size: `m × n`.

For **3-D curvilinear**, the same edge-midpoint and trilinear-average rules
apply in all three axis directions. The node arrays are
`(m+1) × (n+1) × (o+1)` and the derived face/center arrays follow the same
naming and sizing conventions as the uniform 3-D case above.

### 4.3 Layout note for operator internals

Curvilinear operators (`gradCurv_impl`, `divCurv_impl`, `nodalCurv_impl`)
internally need **meshgrid layout** for the Jacobian computation. They
transpose or permute the ndgrid arrays on entry:

```matlab
X = grid.nodes.X';            % 2-D: (n+1)×(m+1) meshgrid
X = permute(grid.nodes.X, [2,1,3]);  % 3-D: (n+1)×(m+1)×(o+1)
```

This conversion is the operator's responsibility, not the grid struct's.
The struct always stores coordinates in ndgrid layout.

---

## 5. Quick-Reference Table

| Field | 1-D | 2-D | 3-D | Curvilinear | Notes |
|-------|:---:|:---:|:---:|:-----------:|-------|
| `dim` | 1 | 2 | 3 | 2 or 3 | Auto-inferred |
| `type` | str | str | str | `'curvilinear'` | `'uniform'`/`'periodic'`/`'curvilinear'` |
| `m` | scalar | scalar | scalar | scalar | Cell count in x |
| `n` | — | scalar | scalar | scalar | Cell count in y |
| `o` | — | — | scalar | scalar | Cell count in z |
| `dx` | scalar | scalar | scalar | — | x cell spacing |
| `dy` | — | scalar | scalar | — | y cell spacing |
| `dz` | — | — | scalar | — | z cell spacing |
| `nodes.X` | `(m+1)×1` | `(m+1)×(n+1)` | `(m+1)×(n+1)×(o+1)` | same (user-supplied) | ndgrid layout |
| `nodes.Y` | — | `(m+1)×(n+1)` | `(m+1)×(n+1)×(o+1)` | same (user-supplied) | |
| `nodes.Z` | — | — | `(m+1)×(n+1)×(o+1)` | same (user-supplied) | |
| `centers.X` | `(m+2)×1` | `(m+2)×(n+2)` | `(m+2)×(n+2)×(o+2)` | `m×n` or `m×n×o` | Ghost padding in uniform; no ghost in curvilinear |
| `centers.Y` | — | `(m+2)×(n+2)` | `(m+2)×(n+2)×(o+2)` | `m×n` or `m×n×o` | |
| `centers.Z` | — | — | `(m+2)×(n+2)×(o+2)` | `m×n×o` | |
| `faces.X` | `(m+1)×1` | — | — | — | 1-D only; equals `nodes.X` |
| `faces.u.X` | — | `(m+1)×n` | `(m+1)×n×o` | `(m+1)×n` | x-normal faces |
| `faces.u.Y` | — | `(m+1)×n` | `(m+1)×n×o` | `(m+1)×n` | |
| `faces.u.Z` | — | — | `(m+1)×n×o` | — | 3-D only |
| `faces.v.X` | — | `m×(n+1)` | `m×(n+1)×o` | `m×(n+1)` | y-normal faces |
| `faces.v.Y` | — | `m×(n+1)` | `m×(n+1)×o` | `m×(n+1)` | |
| `faces.v.Z` | — | — | `m×(n+1)×o` | — | 3-D only |
| `faces.w.X` | — | — | `m×n×(o+1)` | — | z-normal faces |
| `faces.w.Y` | — | — | `m×n×(o+1)` | — | |
| `faces.w.Z` | — | — | `m×n×(o+1)` | — | |
| `bc.isPeriodic` | `1×1` | `2×1` | `3×1` | — | One flag per axis |
