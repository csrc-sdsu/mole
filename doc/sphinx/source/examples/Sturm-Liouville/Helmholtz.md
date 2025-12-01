# Helmholtz Sturm-Liouville Problem

This example solves the Helmholtz differential equation, which is a classic Sturm-Liouville problem:

$$ u'' + u = 0, \quad 0 < x < 3 $$
or
$$ u'' + \mu^2 u = 0, \quad 0 < x < 1 $$

with boundary conditions:
$$ u(0) = 0, \quad u(3) = \sin(3) $$
or
$$ u'(0) = 0, \quad u(1) + u'(1) = \cos(\mu) - \mu \sin(\mu) $$

The exact solution to this problem is $\sin(x)$ or $\cos(\mu x)$.

## Mathematical Background

Helmholtz's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Helmholtz's equation, we have:

- $p(x) = 1$
- $q(x) = 0$
- $r(x) = 1$
- $\lambda = \mu^2$

## Discretization

The equation is discretized using mimetic finite difference operators. The spatial derivative operators are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where:

- $A = L + I$
- $L$ is the mimetic Laplacian
- $I$ is the identity matrix

Boundary conditions are applied using `RobinBC` or `MixedBC`.

---

These examples are implemented in:

- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleHelmholtzDirichletDirichlet.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/sturmLiouvilleHelmholtzDirichletDirichlet.cpp)
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleHelmholtzDirichletRobin.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/sturmLiouvilleHelmholtzDirichletRobin.cpp)

## Results

The numerical solutions closely match the exact solutions, which are $\sin(x)$ or $\cos(\mu x)$.
