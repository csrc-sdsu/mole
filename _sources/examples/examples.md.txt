# MOLE Library Examples

The MOLE library contains many examples written in OCTAVE/MATLAB and C++. These examples span a broad range of partial differential equations (PDEs). Below are more technical explanations of the examples included in the library.

**NOTE**: The name for both OCTAVE/MATLAB and C++ will be the same. The files `elliptic1D.m` and `elliptic1D.cpp` solve the same differential equation explained here under Elliptic1D. There are many more OCTAVE/MATLAB examples, so if you cannot find a C++ example, it is only in the OCTAVE/MATLAB folder.

## Elliptic Equations

### Elliptic1D

Solves the 1D Poisson equation with Robin boundary conditions.

$$
\nabla^2 u(x) = f(x)
$$

with $x\in[0,1]$, and $f(x) =e^x$. The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with $a=1$, $b=1$, and $g=0$, and

$$
au(0) + b\frac{du(0)}{dx} = 0
$$

$$
au(1) + b\frac{du(1)}{dx} = 2e
$$

This corresponds to the call to robinBC2D of `robinBC2D(k, m, dx, a, b)`.

### Elliptic2D

Solves the 2D Poisson equation with Robin boundary conditions on a nonuniform grid.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[0,10], y\in[0,10]$, and

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

with $a=1$, $b=0$, and $g=0$, which is equivalent to Dirichlet conditions along each boundary.
This corresponds to the call to robinBC2D of `robinBC2D(k, m, 1, n, 1, 1, 0)`.

### Elliptic2D Case 2

Solves the 2D Poisson equation with Robin boundary conditions on a nonuniform sinusoidal grid.

$$
\nabla^2 u(x,y) = f(x,y)
$$

with $x\in[-\pi, 2\pi], y\in[-\pi, \pi]$, and

$$
f(x,y) = \begin{cases}
    \sin(x)\sin(y) & \text{ along boundaries } \\
    -2\sin(x)\sin(y) & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$, which is equivalent to Dirichlet conditions along each boundary.
This corresponds to the call to robinBC2D of `robinBC2D(k, m, 1, n, 1, 1, 0)`.

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

The MATLAB code uses the function `boundaryIdx2D` to find the correct locations for boundary condition weights in the nodal Laplacian. The code then sets the appropriate values to $0$ or $1$.

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
The MATLAB code uses the function `boundaryIdx2D` to find the correct locations for the weights of the boundary condition in the Laplacian node. The code then sets the appropriate values to $0$ or $1$.

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

### Elliptic3D

Similar to `minimal_poisson2D`, this solves a 3D problem using mimetic Laplacian, where one side of the domain is set to 100, and allowed to diffuse.

$$
\nabla^2 u(x,y,z) = f(x,y,z)
$$

with $x\in[0,5], y\in[0,6], z\in[0,7]$, and

$$
f(x,y) = \begin{cases}
    100 & \text{ if z = 0} \\
    0 & \text{ otherwise }
\end{cases}
$$

The boundary conditions are given by

$$
au + b\nabla u = g
$$

with $a=1$, $b=0$, and $g=0$.
This corresponds to the call to robinBC3D of `robinBC2D(k, m, 1, n, 1, o, 1, 1, 0)`.

### Poisson1D

Solves the 1D Poisson equation with Robin boundary conditions.

$$
-\frac{d^2 C}{d x^2} = f(x)
$$

The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

The equation is discretized using mimetic operators.

### Schrodinger1D

Solves the 1D time-independent Schrödinger equation.

$$
H \psi = E \psi
$$

where $H$ is the Hamiltonian operator, $\psi$ is the wave function, and $E$ is the energy. The Hamiltonian includes the kinetic energy term represented by the Laplacian and a potential energy term.

## Hyperbolic

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

### Hyperbolic1D upwind

Solves the 1D advection equation with periodic boundary conditions using a sided nodal mimetic operator. The main feature of this code is the lack of an interpolator.

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

$$
U^{n+1}_i = U^n_i ( I - S )
$$

The last line $I-S$ is the identity matrix $I$ minus the premultiplied $a\Delta t \mathbf{D}$.

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

### Burgers1D

This example deals with the conservative form of the inviscid Burgers equation in 1D.

$$
\frac{\partial U}{\partial t} + \frac{\partial}{\partial x}\Big(\frac{U^2}{2}\Big) = 0
$$

with $U = u(x,t)$ defined on the domain $x\in[-15,15]$, from time $t\in[0,10]$ and initial conditions

$$
u(x,0) = e^{\frac{-x^2}{50}}
$$

The wave is allowed to propagate across the domain while the area under the curve is calculated. 

## Parabolic Equations

### Transport1D

Solves the 1D advection-reaction-dispersion equation:

$$
\frac{\partial C}{\partial t} + v\frac{\partial C}{\partial x} = D\frac{\partial^2 C}{\partial x^2}
$$

where $C$ is the concentration, $v$ is the pore-water flow velocity, and $D$ is the dispersion coefficient.

### Under work  ....