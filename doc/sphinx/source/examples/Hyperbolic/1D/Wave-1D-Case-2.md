### Wave 1D Case 2

Solves the one-way wave equation using the position Verlet or Forest-Ruth algorithms with higher wave speed.

$$
\frac{\partial^2 U}{\partial t^2} - c^2\frac{\partial^2 U}{\partial x^2} = 0
$$

where $U=u(x,t)$ defined on the domains $x\in[0,1]$ and $t\in[0,0.06]$, and wave speed $c=100$. Initial position and velocity are given as

$$
u(x,0) = \begin{cases}
    \sin(\pi x) & 2 < x < 3 \\
    0 & \text{ otherwise }
\end{cases}
$$

$$
u'(x,0) = 0
$$
