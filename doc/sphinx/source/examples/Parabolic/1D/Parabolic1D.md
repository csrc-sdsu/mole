# 1D Heat Equation

This example solves the one-dimensional heat equation with Dirichlet boundary conditions, which is a classic parabolic PDE:

$$\frac{\partial T}{\partial t} = \alpha \frac{\partial^2 T}{\partial x^2}$$

where $T$ is the temperature and $\alpha$ is the thermal diffusivity.

## Domain and Boundary Conditions

The domain is $x \in [0, 1]$ with Dirichlet boundary conditions:
- $T(0, t) = 100$
- $T(1, t) = 100$

## Discretization

The spatial discretization uses the mimetic laplacian operator with a specified order of accuracy $k$. The temporal discretization can be either:
1. Explicit (forward Euler): $T^{n+1} = T^n + \alpha \Delta t L T^n$
2. Implicit (backward Euler): $T^{n+1} = (I - \alpha \Delta t L)^{-1} T^n$

where $L$ is the mimetic discrete Laplacian operator.

The time step is constrained by the stability condition for the explicit scheme:
$$\Delta t \leq \frac{\Delta x^2}{3\alpha}$$

---

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/parabolic1D.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/parabolic1D.cpp)

## Results

The solution shows the heat diffusing through the domain, with the temperature at the boundaries held constant at 100. The explicit scheme is conditionally stable, requiring a small time step, while the implicit scheme is unconditionally stable but requires solving a linear system at each time step. 
