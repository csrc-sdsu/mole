# Hermite Sturm-Liouville Problem

This example solves the Hermite differential equation, which is a classic Sturm-Liouville problem:

$$ u'' - 2 u' + 2 m u = 0, \quad -1 < x < 1 $$

with Dirichlet boundary conditions:
$$ u(-1) = H_m(-1), \quad u(1) = H_m(1) $$

The exact solution to this problem is the Hermite polynomial of degree $m$, denoted as $H_m(x)$. For $m = 4$, the solution is $H_4(x) = e^{x^2} \frac{d^4}{dx^4}e^{-x^2}$.

## Mathematical Background

Hermite's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Hermite's equation, we have:

- $p(x) = e^{-x^2}$
- $q(x) = 0$
- $r(x) = e^{-x^2}$
- $\lambda = m^2$

## Discretization

The equation is discretized using mimetic finite difference operators. The spactial derivative operatores are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where

- $A = L - 2 x I_{FC} G + 2 m I$
- $L$ is the mimetic Laplacian
- $G$ is the mimetic gradient
- $I_{FC}$ is the interpolation operator from faces to centers
- $I$ is the identity matrix

Boundary conditions are applied using `RobinBC`.

---

This example is implemented in:

- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleHermite.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/sturmLiouvilleHermite.cpp)

## Results

The numerical solution closely matches the exact solution, which is the Hermite polynomial $H_4(x) = e^{x^2} \frac{d^4}{dx^4}e^{-x^2}$.
