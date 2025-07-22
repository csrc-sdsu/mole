### Hyperbolic1D

Solves the 1D advection equation with periodic boundary conditions.

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
U^{n+1}_i = U^n_i - a \Delta t \mathbf{D} U^n_i
$$

---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/hyperbolic1D.m)

Additional MATLAB/ OCTAVE variants:
- [Upwind Scheme](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/hyperbolic1D_upwind.m)
- [Lax-Friedrichs Scheme](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/hyperbolic1D_lax_friedrichs.m)
