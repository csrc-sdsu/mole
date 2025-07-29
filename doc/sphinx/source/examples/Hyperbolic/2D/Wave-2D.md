### Wave 2D

Solves the two-dimensional wave equation using the position Verlet algorithm.

$$
\frac{\partial^2 U}{\partial t^2} - c^2\frac{\partial^2 U}{\partial x^2} = 0
$$

where $U=u(x,y,t)$ defined on the domains $x\in[0,1], y\in[0,1]$ and $t\in[0,1]$, and wave speed $c=1$. The boundaries are Dirichlet. Initial position and velocity are given as

$$
u(x,y,0) = \sin(\pi x) \sin(\pi y)
$$

$$
u'(x,y,0) = 0
$$
