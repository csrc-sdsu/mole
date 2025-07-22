### Elliptic2D Nodal Curv Sinusoidal

Solves the 2D Poisson equation with Robin boundary conditions on a curvilinear sinusoidal grid using the nodal mimetic operator. This requires manually setting the boundary condition in the Laplacian, as there is no boundary condition operator for the nodal curvilinear operators.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[-\pi, 2\pi], y\in[-\pi, \pi]$, and

$$
f(x,y) = \begin{cases}
    \sin(x)+\cos(y) & \text{ along boundaries } \\
    -\sin(x) - \cos(y) & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$, which is equivalent to Dirichlet conditions along each boundary.
The MATLAB/ OCTAVE code uses the function `boundaryIdx2D` to find the correct locations for the weights of the boundary condition in the Laplacian node. The code then sets the appropriate values to $0$ or $1$.
