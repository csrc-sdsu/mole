# Elliptic2D X Dirichlet Y Dirichlet

Solves the 2D Poisson equation with Dirichlet boundary conditions

```math
- \nabla^2 u(x,y) = 0
```

with $x \in [0, \pi]$ and $y \in [0, \pi]$.

The boundary conditions are given by

```math
a u + b \nabla u \cdot \hat n = g
```

with $a = 1$, $b = 0$, and $g(x,y) = e^x \cos y$, which is equivalent to Dirichlet conditions along each boundary. This corresponds to the call to `addScalarBC!` of `addScalarBC!(A, b, k, m, dx, n, dy, bc)`, where `A` is the operator matrix, `b` is the right hand side vector, and `bc` is a boundary condition struct that contains the tuples `dc`, `nc`, and `v` which hold the coefficients for $a$, $b$, and $g$ in the above systems of equations. `dc` $= (1.0, 1.0, 1.0, 1.0)$, `nc` $= (0.0, 0.0, 0.0, 0.0)$, and `v` is composed of 4 vectors: $g$ along the left boundary, $g$ along the right boundary, $g$ along the bottom boundary, and $g$ along the top boundary.

The true solution is

```math
u(x,y) = e^x \cos y
```

---
This example is implemented in [`elliptic2DXDirichletYDirichlet.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/elliptic/elliptic2DXDirichletYDirichlet.jl)
