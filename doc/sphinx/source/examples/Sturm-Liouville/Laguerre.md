# Laguerre Sturm-Liouville Problem

This example solves the Laguerre differential equation, which is a classic Sturm-Liouville problem:

$$x u'' + (1 - x) u' + n u = 0, \quad 0 < x < 2$$

with Dirichlet boundary conditions:
$$ u(0) = L_n(2), \quad u(2) = L_n(2) $$

The exact solution to this problem is the Laguerre polynomial of degree $n$, denoted as $L_n(x)$. For $n = 4$, the solution is $L_4(x) = \frac{e^x}{4!} \frac{d^4}{dx^4} (e^{-x}x^4) $.

## Mathematical Background

Laguerre's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Laguerre's equation, we have:

- $p(x) = xe^{-x}$
- $q(x) = 0$
- $r(x) = e^{-x}$
- $\lambda = n$

## Discretization

The equation is discretized using mimetic finite difference operators. The spatial derivative operators are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where:

- $A = x L + (1 - x) I_{FC} G + n I$
- $L$ is the mimetic Laplacian
- $G$ is the mimetic gradient
- $I_{FC}$ is the interpolation operator from faces to centers
- $I$ is the identity matrix

Boundary conditions are applied using `RobinBC`.

---

This example is implemented in:

- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/sturmLiouvilleLaguerre.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/sturmLiouvilleLaguerre.cpp)

## Results

The numerical solution closely matches the exact solution, which is the Laguerre polynomial $L_4(x) = \frac{e^x}{4!} \frac{d^4}{dx^4} (e^{-x}x^4) $.
