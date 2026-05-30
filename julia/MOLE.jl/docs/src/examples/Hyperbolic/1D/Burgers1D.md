# Burgers 1D

Solves the conservative form of the inviscid Burger's Equation in 1D.   

```math
\frac{\partial }{\partial t} U + \frac{\partial}{\partial x} \left(\frac{U^{2}}{2}\right)=0
```

with $U = u(x,t)$ defined on the domain $x \in [-15,15]$, from time $t \in [0,10]$ and initial condition   

```math
u(x, 0) = e^{\frac{-x^{2}}{50}}
```

The wave is allowed to propagate across the domain while the area under the curve is calculated.


---
This example is implemented in [`burgers1D.jl`](https://github.com/csrc-sdsu/mole/blob/main/julia/MOLE/jl/examples/hyperbolic/burgers1D.jl)
