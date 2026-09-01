# 2D Heat Equation

This example solves the two-dimensional heat equation with Dirichlet boundary conditions, which is a classic parabolic PDE:

$$
\frac{\partial T}{\partial t}
=
\alpha\left(
\frac{\partial^2 T}{\partial x^2}
+
\frac{\partial^2 T}{\partial y^2}
\right)
$$

where $T$ is the temperature and $\alpha$ is the thermal diffusivity.

## Domain and Boundary Conditions

The domain is $(x,y) \in [0,2]\times[0,2]$ with Dirichlet boundary conditions:
- $T(0, y, t) = 0$
- $T(2, y, t) = 0$
- $T(x, 0, t) = 0$
- $T(x, 2, t) = 0$

The initial condition is a square region with value $T=2$, while the rest of the domain is initialized to $T=0$.

## Discretization

The spatial discretization uses the mimetic Laplacian operator with a specified order of accuracy $k$. The temporal discretization can be either:
1. Explicit, forward Euler: $T^{n+1} = T^n + \alpha \Delta t L T^n$
2. Implicit, backward Euler: $T^{n+1} = (I - \alpha \Delta t L)^{-1} T^n$

where $L$ is the mimetic discrete Laplacian operator.

The explicit scheme requires a sufficiently small time step for stability.

---

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/parabolic2D.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/parabolic2D.cpp)

## Results

The solution shows the initial pulse diffusing through the two-dimensional domain, with the temperature at the boundaries held constant at zero. The explicit scheme is conditionally stable.
