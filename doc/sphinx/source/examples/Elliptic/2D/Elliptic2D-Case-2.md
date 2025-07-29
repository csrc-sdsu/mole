### Elliptic2D Case 2

Solves the 2D Poisson equation with Robin boundary conditions on a nonuniform sinusoidal grid.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[-\pi, 2\pi], y\in[-\pi, \pi]$, and

$$
f(x,y) = \begin{cases}
    \sin(x)\sin(y) & \text{ along boundaries } \\
    -2\sin(x)\sin(y) & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$, which is equivalent to Dirichlet conditions along each boundary.
This corresponds to the call to robinBC2D of `robinBC2D(k, m, 1, n, 1, 1, 0)`.
