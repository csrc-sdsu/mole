### Elliptic2D

Solves the 2D Poisson equation with Robin boundary conditions on a nonuniform grid.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[0,10], y\in[0,10]$, and

$$
f(x,y) = \begin{cases}
    (x-0.5)^2+(y-0.5)^2 & \text{ along boundaries } \\
    4 & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$, which is equivalent to Dirichlet conditions along each boundary.
This corresponds to the call to robinBC2D of `robinBC2D(k, m, 1, n, 1, 1, 0)`.
