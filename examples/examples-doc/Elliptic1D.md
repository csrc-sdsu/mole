### Elliptic1D

Solves the 1D Poisson equation with Robin boundary conditions.

$$
\nabla^2 u(x) = f(x)
$$

with $x\in[0,1]$, and $f(x) =e^x$. The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with $a=1$, $b=1$, and $g=0$, and

$$
au(0) + b\frac{du(0)}{dx} = 0
$$

$$
au(1) + b\frac{du(1)}{dx} = 2e
$$

This corresponds to the call to robinBC2D of `robinBC2D(k, m, dx, a, b)`.