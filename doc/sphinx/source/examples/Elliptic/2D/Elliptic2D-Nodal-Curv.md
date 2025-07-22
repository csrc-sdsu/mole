### Elliptic2D Nodal Curv

Solves the 2D Poisson equation with Robin boundary conditions on a curvilinear grid using the nodal mimetic operator. This requires manually setting the boundary condition in the Laplacian, as there is no boundary condition operator for the nodal curvilinear operators.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[0,50], y\in[0,50]$, and

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

The MATLAB/ OCTAVE code uses the function `boundaryIdx2D` to find the correct locations for boundary condition weights in the nodal Laplacian. The code then sets the appropriate values to $0$ or $1$.
