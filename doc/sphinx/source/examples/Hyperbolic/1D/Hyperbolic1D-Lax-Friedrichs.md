### Hyperbolic1D Lax Friedrichs

Solves the 1D advection equation with periodic boundary conditions using a sided nodal mimetic operator and the Lax-Friedrichs scheme for time integration. The main feature of this code is the lack of an interpolator. This is first order in both time and space, even though a second order mimetic operator is used.

$$
\frac{\partial U}{\partial t} + a\frac{\partial U}{\partial x} = 0
$$

where $U=u(x,t)$ and $a=1$ is the advection velocity. The domain $x\in[0,1]$ and $t\in[0,1]$ with initial condition

$$
u(x,0) = \sin(2\pi x)
$$

Periodic boundary conditions are used

$$
u(0,t) = u(1,t)
$$

Using finite differences for the time derivative

$$
\frac{\partial U}{\partial t} = \frac{U^{n+1}_i - U^{n}_i}{\Delta t}
$$

where $U_i^n$ is $u(x_i, t_n)$, and the mimetic operator $\mathbf{D}$ for the space derivative.

$$
\frac{U^{n+1}_i - U^{n}_i}{\Delta t} + a \mathbf{D} U^n_i = 0
$$

$$
\frac{U^{n+1}_i - U^{n}_i}{\Delta t} = -a \mathbf{D} U^n_i
$$

$$
U^{n+1}_i = \mathbf{U}^n_i - a \Delta t \mathbf{D} U^n_i
$$

The last line $\mathbf{U}$ is the derived (average) value of the U from the $U^n$ timestep.
