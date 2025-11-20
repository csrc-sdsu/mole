# Legendre Sturm-Liouville Problem

This example solves the Legendre differential equation, which is a classic Sturm-Liouville problem:

$$ (1 - x^2) u'' - 2 x u' + n (n + 1) u = 0, \quad -1 < x < 1 $$

with Dirichlet boundary conditions:
$$ u(-1) = -1, \quad u(1) = 1 $$

The exact solutoin to this problem is the Legendre polynomial of degree $n$, denoted as $L_n(x)$. For $n = 4$, the solution is $L_4(x) = \frac{1}{8}(35x^4 -30x^2 + 3)$.

## Mathematical Background

Legendre's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Legendre's equation, we have:

- $p(x) = 1-x^2$
- $q(x) = 0$
- $r(x) = 1$
- $\lambda = n(n+1)$

## Discretization

The equation is discretized using mimetic finite difference operators. The spatial derivative operators are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where:

- $A = (1 - x^2) L - 2 x I_{FC} G + n(n+1) I$
- $L$ is the mimetic Laplacian
- $G$ is the mimetic gradient
- $I_{FC}$ is the interpolation operator from faces to centers
- $I$ is the identity matrix

Boundary conditions are applied using `RobinBC`.

---

This example is implemented in:

- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleLegendre.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cppe/sturmLiouvilleLegendre.cpp)

## Results

The numerical solution closely matches the exact solution, which is the Legendre polynomial $L_4(x) = \frac{1}{8}(35x^4 -30x^2 + 3)$.
