# Bessel Sturm-Liouville Problem

This example solves the Bessel differential equation, which is a classic Sturm-Liouville problem:

$$ x^2 u''  + x u' + (x^2 - \nu^2) u = 0, \quad 0 < x 1 $$

with Dirichlet boundary conditions:
$$ u(0) = 0, \quad u(1) = J_\nu(1) $$

The exact solution to this problem is the Bessel function of the first kind of order $\nu$, denoted as $J_\nu(x)$. For $\nu = 3$, the solution is $ J_3(x) = \frac{1}{\pi}\int^{\pi}_0 \cos(3\tau) - x\sin(\tau)\,d\tau $.

## Mathematical Background

Bessel's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Bessel's equation, we have:

- $p(x) = x^2$
- $q(x) = x$
- $r(x) = \frac{1}{x}$
- $\lambda = -\nu^2$

## Discretization

The equation is discretized using mimetic finite difference operators. The spaical derivative operators are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where:

- $A = x^2 L + x I_{FC} G + (x^2 - \nu^2) I$
- $L$ is the mimetic Laplacian
- $G$ is the mimetic gradient
- $I_{FC}$ is the interpolation operator from faces to centers
- $I$ is the identity matrix

Boundary conditions are applied using `RobinBC`.

---

This example is implemented in:

- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleBessel.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/sturmLiouvilleBessel.cpp)

## Results

The numerical solution closely matches the exact solution, which is the Bessel function of the first kind of order $\nu$:  

$J_\nu(x) = \frac{1}{\pi}\int^{\pi}_0 \cos(\nu\tau) - x\sin(\tau)\,d\tau$.
