### Elliptic3D

Similar to `minimal_poisson2D`, this solves a 3D problem using mimetic Laplacian, where one side of the domain is set to 100, and allowed to diffuse.

$$
\nabla^2 u(x,y,z) = f(x,y,z)
$$

with $x\in[0,5], y\in[0,6], z\in[0,7]$, and

$$
f(x,y,z) = \begin{cases}
    100 & \text{ if z = 0} \\
    0 & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$.
This corresponds to the call to robinBC3D of `robinBC3D(k, m, 1, n, 1, o, 1, 1, 0)`.
