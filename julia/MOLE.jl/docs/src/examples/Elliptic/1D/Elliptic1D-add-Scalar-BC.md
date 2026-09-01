# Elliptic1D Add Scalar Boundary Conditions

Solves the 1D Poisson equation with Robin boundary conditions. This is the exact same problem as [`elliptic1D.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/elliptic/elliptic1D.jl), with `addScalarBC` used instead of `robinBC`. The equation to solve is

```math
\nabla^2 u(x) = f(x)
```

with $x \in [0, 1]$ and $f(x) = e^x$. The boundary conditions are given by

```math
a u + b \frac{du}{dx} = g
```

with $a = 1$, $b = 1$, and

```math
a u(0) + b \frac{du(0)}{dx} = 0
```

```math
a u(1) + b \frac{du(1)}{dx} = 2 e
```

This corresponds to the call to `addScalarBC!` of `addScalarBC!(A, b, k, m, dx, bc)`, where `bc` is a boundary condition struct that contains the tuples `dc`, `nc`, and `v` which hold the coefficients for $a$, $b$, and $g$ in the above systems of equations. `dc` $= (1.0, 1.0)$, `nc` $= (1.0, 1.0)$, and `v` $= (0.0, 2.0 * \exp(1))$.

The key difference is the implementaiton of the boundary condition operators. In `elliptic1D.jl`, the right hand side of the Robin operator is included in lines 30-32, yet in this example, the boundary conditions are set via the `addScalarBC!` operator.

The true solution is

```math
u(x) = e^x
```

---
This example is implemented in [`elliptic1DaddScalarBC.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/elliptic/elliptic1DaddScalarBC.jl)
