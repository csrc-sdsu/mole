### Elliptic3D with addScalarBC3D

Solves the same problem as {doc}`Elliptic3D <Elliptic3D>`, but applies the boundary conditions with the general function `addScalarBC3D` instead of `robinBC3D`. One face of a box is held at $u = 100$ and the other five at $u = 0$; the solution shows how that value diffuses into the interior.

$$
\nabla^2 u(x,y,z) = 0
$$

with domain $x \in [0,5]$, $y \in [0,6]$, $z \in [0,7]$ and boundary conditions:

$$
u(x,y,0) = 100, \qquad u = 0 \ \text{on the other five faces.}
$$

#### Mathematical Background

This is Laplace's equation, which describes steady-state situations where nothing is changing over time. For example, it models the temperature in a box whose front face is held at 100 degrees and whose other faces are held at 0, once the temperature has stopped changing. Since there is no source inside the domain, the solution is determined by the boundary values alone: it is 100 on the front face and decays toward 0 away from it.

The boundary conditions use MOLE's general form

$$
a\,u + b\,\frac{\partial u}{\partial n} = g,
$$

with $a = 1$ and $b = 0$ (pure Dirichlet) on all six faces, $g = 100$ on the front face, and $g = 0$ elsewhere.

#### Implementation Details

The grid has $m = 5$, $n = 6$, and $o = 7$ cells with unit spacing ($\Delta x = \Delta y = \Delta z = 1$). Including the boundary face centers, the solution array has size $(m+2) \times (n+2) \times (o+2) = 7 \times 8 \times 9$. The operators use order of accuracy $k = 2$.

The boundary conditions are described by three arguments, each ordered as (left, right, bottom, top, front, back):

| Argument | Value | Meaning |
|---|---|---|
| `dc` | `[1;1;1;1;1;1]` | Coefficient $a$ of $u$ on each face |
| `nc` | `[0;0;0;0;0;0]` | Coefficient $b$ of $\partial u / \partial n$ on each face |
| `v` | `{bcl; bcr; bcb; bct; bcf; bcz}` | Boundary values $g$: `bcf = 100*ones(...)`, all others zero |

The vectors in `v` have different lengths so that each edge and corner is set only once: $n \cdot o$ for left/right, $(m+2) \cdot o$ for bottom/top, and $(m+2)(n+2)$ for front/back.

The equation is discretized using mimetic finite difference operators with order of accuracy $k = 2$.

The discrete system is:

$$L u = b$$

where:

- $L$ is the 3D mimetic Laplacian, built with `lap3D(k, m, 1, n, 1, o, 1, dc, nc)`
- $b = 0$ in the interior (no source term)
- the boundary rows of $L$ and $b$ are replaced with the boundary condition equations by `addScalarBC3D`

#### Results

Running both scripts gives identical solutions (the maximum difference between them is exactly zero), which confirms that the two ways of applying the boundary condition are equivalent for this problem.

The script displays one $xy$ page of the solution (page `p = 2`, the first interior layer next to the $u = 100$ face) with `imagesc`.

```{figure} figures/elliptic3D_addScalarBC3D.png
:width: 100%

Left: the page the script displays, next to the $u = 100$ face. Values are largest in the center and drop to 0 at the edges. Right: a middle slice through the box, showing the solution decaying from 100 on the front face toward 0.
```

---

This example is implemented in:
- [Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic3DaddScalarBC3D.m)

#### Variants

- {doc}`Elliptic3D <Elliptic3D>`: the same problem using `robinBC3D` ([Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic3D.m), [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/elliptic3D.cpp))
- {doc}`Elliptic3D Dirichlet in All Directions <Elliptic3D-Dirichlet-Dirichlet-Dirichlet>`: `addScalarBC3D` with non-homogeneous Dirichlet conditions and an exact solution
