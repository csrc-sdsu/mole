# Hyperbolic 1D

Solves the 1D advection equation with periodic boundary conditions.

```math
\frac{\partial }{\partial t} U + a \frac{\partial }{\partial x} U = 0
```

where $U = u(x,t)$ and $a = 1$ is the advection velocity. The domain $x \in [0,1]$ and $t \in [0,1]$ with initial condition

```math
u(x, 0) = \sin(2\pi x)
```

Periodic boundary conditions are used

```math
u(0, t) = u(1, t)
```

Using finite differences for the time derivative

```math
\frac{\partial U}{\partial t} = \frac{U^{n+1}_{i}-U^{n}_{i}}{\delta t}
```

where $U_{i}^{n}$ is $u(x_{i},t_{n})$ and the mimetic operator $\mathbf{D}$ for the space derivative.

```math
\frac{U^{n+1}_{i}-U^{n}_{i}}{\delta t} + a \mathbf{D}U_{i}^{n} = 0\\
\frac{U^{n+1}_{i}-U^{n}_{i}}{\delta t} = - a \mathbf{D}U_{i}^{n}\\
U^{n+1}_{i} = U^{n}_{i}  - a \delta t \mathbf{D} U_{i}^{n}\\
```

---
This example is implemented in [`hyperbolic1D.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE.jl/examples/hyperbolic/hyperbolic1D.jl)   
