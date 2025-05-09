### Wave 1D

Solves the one-way wave equation using the position Verlet or Forest-Ruth algorithms.

$$
\frac{\partial^2 U}{\partial t^2} - c^2\frac{\partial^2 U}{\partial x^2} = 0
$$

where $U=u(x,t)$ defined on the domains $x\in[0,1]$ and $t\in[0,1]$, and wave speed $c=2$. Initial position and velocity are given as

$$
u(x,0) = \sin(\pi x)
$$

$$
u'(x,0) = 0
$$