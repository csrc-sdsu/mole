### Minimal Poisson 2D

Solves the 2D Poisson equation with Robin boundary conditions on a uniform grid where $\Delta x=\Delta y = 1$.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[0,5], y\in[0,5]$, and

$$
f(x,y) = \begin{cases}
    100 & \text{ if y = 0} \\
    0 & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$.
This corresponds to the call to robinBC2D of `robinBC2D(k, m, 1, n, 1, 1, 0)`.
