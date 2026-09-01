# Elliptic 2D X Periodic Y Dirichlet

Solves the 2D Poisson equation with periodic boundary conditions in the x-direction and Dirichlet boundary conditions in the y-direction

```math
- \nabla^2 u(x,y) = 2 \sin (2 \pi x) (1 + 2 \pi^2 y (1 - y))
```

with $x \in [0, 1]$ and $y \in [0, 1]$.

The bottom and top boundary conditions are given by

```math
a u + b \nabla u \cdot \hat n = g
```

with $a = 1$, $b = 0$, and $g(x, y) = y (1 - y) \sin (2 \pi x)$, which is equivalen to Dirichlet boundary conditions along the two boundaries. This correspondes to the call to `addScalarBC!` of `addScalarBC!(A, b, k, m, dx, n, dy, bc)`, where `A` is the operator matrix, `b` is the right hand side vector, and `bc` is a boundary condition struct that contains the tuples `dc`, `nc`, and `v` which hold the coefficients for $a$, $b$, and $g$ in the above systems of equations. `dc` = $= (0.0, 0.0, 1.0, 1.0)$, `nc` $= (0.0, 0.0, 0.0, 0.0)$, and `v` is composed of 4 elements: the first two are never accessed because of the periodicity in the x-direction, the third is $g$ along the bottom boundary, and the fourth is $g$ along the top boundary.

The true solution is

```math
u(x,y) = y (1 - y) \sin (2 \pi x)
```

---
This example is implemented in [`elliptic2DXPerYDirichlet.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/elliptic/elliptic2DXPerYDirichlet.jl)
