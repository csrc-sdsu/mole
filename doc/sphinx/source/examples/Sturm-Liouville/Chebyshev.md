# Chebyshev Sturm-Liouville Problem

This example solves the Chebyshev differential equation, which is a classic Sturm-Liouville problem:

$$(1-x^2) u'' - x u' + n^2 u = 0, \quad -1 < x < 1$$

with Dirichlet boundary conditions:
$$u(-1) = 1, \quad u(1) = 1$$

The exact solution to this problem is the Chebyshev polynomial of the first kind of degree $n$, denoted as $T_n(x)$. For $n=2$, the solution is $T_2(x) = 2x^2 - 1$.

## Mathematical Background

Chebyshev's differential equation is a special case of the Sturm-Liouville problem, which has the general form:

$$\frac{d}{dx}\left(p(x)\frac{du}{dx}\right) + q(x)u + \lambda r(x)u = 0$$

For Chebyshev's equation, we have:
- $p(x) = 1-x^2$
- $q(x) = 0$
- $r(x) = 1$
- $\lambda = n^2$

## Discretization

The equation is discretized using mimetic finite difference operators. The spatial derivative operators are constructed with a specified order of accuracy $k$.

The discrete system is:

$$A u = b$$

where:
- $A = (1-x^2) L - x I G + n^2 I$
- $L$ is the mimetic Laplacian
- $G$ is the mimetic gradient
- $I$ is the interpolation operator from faces to centers

Boundary conditions are applied using the `addScalarBC1D` function.

---

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/sturmLiouvilleChebyshev.m)

## Results

The numerical solution closely matches the exact solution, which is the Chebyshev polynomial $T_2(x) = 2x^2 - 1$. 

Chebyshev polynomials are important in numerical analysis and approximation theory because they:
1. Minimize the maximum error in polynomial approximation
2. Have roots that are optimal interpolation points (Chebyshev nodes)
3. Are closely related to the Fourier cosine series 
