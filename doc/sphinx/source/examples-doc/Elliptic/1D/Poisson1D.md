### Poisson1D

Solves the 1D Poisson equation with Robin boundary conditions.

$$
-\frac{d^2 C}{d x^2} = f(x)
$$

The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

The equation is discretized using mimetic operators.