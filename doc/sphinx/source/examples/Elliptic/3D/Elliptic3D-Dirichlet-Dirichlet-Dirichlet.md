### Elliptic3D Dirichlet Boundary Conditions in All Directions

Solves the 3D Poisson equation on a cube with non-homogeneous Dirichlet boundary conditions on all six faces, and validates the numerical solution against a known exact solution.

$$
-\nabla^2 u(x,y,z) = -6(x+y+z)
$$

with domain $(x,y,z) \in [-1,1]^3$ and boundary conditions:

$$
u(x,y,z) = x^3 + y^3 + z^3 \quad \text{on all six faces of the cube}
$$

Written out face by face:

$$
\begin{aligned}
u(-1,y,z) &= -1 + y^3 + z^3, & u(1,y,z) &= 1 + y^3 + z^3, \\
u(x,-1,z) &= -1 + x^3 + z^3, & u(x,1,z) &= 1 + x^3 + z^3, \\
u(x,y,-1) &= -1 + x^3 + y^3, & u(x,y,1) &= 1 + x^3 + y^3.
\end{aligned}
$$

#### Mathematical Background

The exact solution is

$$
u(x,y,z) = x^3 + y^3 + z^3
$$

Its second derivatives are $u_{xx} = 6x$, $u_{yy} = 6y$, $u_{zz} = 6z$, so

$$
-\nabla^2 u = -(u_{xx} + u_{yy} + u_{zz}) = -6(x+y+z),
$$

which is the forcing term above. The boundary values are obtained by evaluating the exact solution on each face. Because the exact solution is known everywhere, this example is a direct check on the accuracy of the 3D mimetic Laplacian together with `addScalarBC3D`.

The boundary conditions are given in the general form used by MOLE,

$$
a\,u + b\,\frac{\partial u}{\partial n} = g,
$$

with $a = 1$ and $b = 0$ on every face (pure Dirichlet), and $g$ equal to the exact solution on that face.

#### Implementation Details

The grid has $m = 29$ cells in $x$, $n = m+2 = 31$ cells in $y$, and $o = m+4 = 33$ cells in $z$, so $\Delta x = 2/m$, $\Delta y = 2/n$, $\Delta z = 2/o$. The numbers of cells are odd so that a middle slice of the cube lies exactly on a grid plane for plotting. The unknowns live at cell centers plus boundary face centers, giving $(m+2)(n+2)(o+2)$ unknowns. The operators use order of accuracy $k = 2$.

The linear system is built in three steps:

1. **Operator.** `A = -lap3D(k, m, dx, n, dy, o, dz, dc, nc)` is the (negated) 3D mimetic Laplacian.
2. **Right-hand side.** `b = -6*(X+Y+Z)`, evaluated on the grid and reshaped to a vector.
3. **Boundary conditions.** `[A0, b0] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)` replaces the boundary rows of the system with the boundary condition equations.

The arguments of `addScalarBC3D` encode the boundary conditions. Each is ordered as (left, right, bottom, top, front, back), meaning the faces $x=-1$, $x=1$, $y=-1$, $y=1$, $z=-1$, $z=1$:

| Argument | Value | Meaning |
|---|---|---|
| `dc` | `[1;1;1;1;1;1]` | Coefficient $a$ of $u$ on each face |
| `nc` | `[0;0;0;0;0;0]` | Coefficient $b$ of $\partial u / \partial n$ on each face |
| `v` | `{bcl; bcr; bcb; bct; bcf; bcz}` | Boundary values $g$ on each face |

The boundary value vectors have different lengths so that edges and corners shared by two faces are only set once: the left/right vectors have $n \cdot o$ entries, the bottom/top vectors have $(m+2) \cdot o$ entries, and the front/back vectors have $(m+2)(n+2)$ entries. In the script they are taken from the exact solution `ue` on each face, with the shared edges trimmed off (`bcl(2:end-1,2:end-1)`, `bcb(:,2:end-1)`).

The system `A0 * u = b0` is then solved with Octave's backslash operator.

#### Results

The script plots the numerical and exact solutions on the middle YZ, XZ, and XY slices of the cube, and prints the maximum and relative error. With the default grid ($m = 29$), the maximum absolute error is about $1.2 \times 10^{-4}$, and the relative error (maximum error divided by the range of the exact solution) is about $0.002\%$.

```{figure} figures/elliptic3D_dirichlet.png
:width: 100%

Left: numerical solution on the middle XY slice ($z = 0$). Right: absolute error $|u_e - u_a|$ on the same slice. The error is zero on the Dirichlet boundaries and largest in the interior.
```

Refining the grid shows the error decreasing by roughly a factor of 8 each time the cell size is halved:

| $m$ | Maximum error |
|---|---|
| 9 | $3.6 \times 10^{-3}$ |
| 19 | $4.2 \times 10^{-4}$ |
| 39 | $5.0 \times 10^{-5}$ |

---

This example is implemented in:
- [Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic3DXDirichletYDirichletZDirichlet.m)

#### Variants

Related 3D examples:
- {doc}`Elliptic3D <Elliptic3D>`: Laplace equation with one face held at a constant value
- {doc}`Elliptic3D with addScalarBC3D <Elliptic3D-addScalarBC3D>`: the same problem as Elliptic3D, with boundary conditions applied by `addScalarBC3D`

The 1D version of this setup is {doc}`Elliptic1D Non-Homogeneous Dirichlet <../1D/Elliptic1D-Non-Homogeneous-Dirichlet>`.
