### Wave 2D Case 2

Solves the two-dimensional wave equation using the position Verlet algorithm. This example uses the fourth order mimetic Laplacian, and extends the domain

$$
\frac{\partial^2 U}{\partial t^2} - c^2\frac{\partial^2 U}{\partial x^2} = 0
$$

where $U=u(x,y,t)$ defined on the domains $x\in[-5,10], y\in[-5,10]$ and $t\in[0,0.3]$, and wave speed $c=100$. The boundaries are Dirichlet. Initial position and velocity are given as

$$
u(x,y,0) = \begin{cases}
    \sin(\pi x)\sin(\pi y) & 2 < x < 3,\,\,2 < y < 3 \\
    0 & \text{ otherwise }
\end{cases}
$$

$$
u'(x,y,0) = 0
$$