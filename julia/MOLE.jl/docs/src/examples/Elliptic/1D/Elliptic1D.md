# Elliptic 1D

Solves the 1D Poisson equation with Robin boundary conditions.

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

This corresponds to the call to `robinBC` of `robinBC(k, m, dx, a, b)`.

The true solution is

```math
u(x) = e^x
```

---
This example is implemented in [`elliptic1D.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/elliptic/elliptic1D.jl)
