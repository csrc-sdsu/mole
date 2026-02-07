# 2D Channel Flow with a Cylinder

This example simulates a 2D incompressible channel flow past a cylinder-like obstacle (implemented as a masked no-slip region) using MOLE mimetic operators and a fractional-step (projection / pressure-correction) method. At moderate Reynolds number, the solution exhibits a wake and may show vortex shedding depending on grid resolution and time step.

## Governing Equations

We solve the incompressible Navier–Stokes equations in two dimensions:
$$
\frac{\partial \mathbf{u}}{\partial t} + (\mathbf{u}\cdot\nabla)\mathbf{u}
= -\frac{1}{\rho}\nabla p + \nu \nabla^{2}\mathbf{u},
\qquad
\nabla\cdot\mathbf{u} = 0,
$$

where:
- $\mathbf{u}=(u,v)$ is the velocity field,
- $p$ is the kinematic pressure,
- $\rho$ is the density,
- $\nu$ is the kinematic viscosity.

## Domain and Initial/Boundary Conditions

### Spatial/Temporal Domain

The computational domain is a 2D channel:

- $x \in [0,8]$,
- $y \in [-1,1]$,
- $t \in [0, t_{\text{final}}]$ with $t_{\text{final}}=$ `tspan` (default in code: `tspan = 32.0`).

A “cylinder” is represented by a masked block of cells located near $x/L_x =$ `cylin_pos` (default `1/8`) with a size controlled by `cylin_size` (default `1/10`). Inside this mask, velocity is forced to zero (no-slip).

### Initial Conditions (time-dependent)

At $t=0$:
- $u(x,y,0)=U_0$ everywhere in the fluid region,
- $v(x,y,0)=0$,
- and the obstacle mask region is set to $u=v=0$.

(Default in code: `U_init = 1.0`.)

### Boundary Conditions

Velocity boundary conditions:
- **Inlet (left)**: Dirichlet inflow  
  $$
u = U_0, \qquad v=0.
$$

- **Outlet (right)**: zero streamwise gradient (Neumann outflow)  
  $$
\frac{\partial u}{\partial x}=0, \qquad \frac{\partial v}{\partial x}=0.
$$

- **Top and bottom walls**: no-slip  
  $$
u=0,\qquad v=0.
$$

- **Obstacle mask**: no-slip enforced by projection back to $u=v=0$ in the masked region after each time step.

Pressure boundary conditions (pressure Poisson step):
- **Outlet (right)**: Dirichlet reference pressure  
  $$
p = 0.
$$

- **Other boundaries**: homogeneous Neumann  
  $$
\frac{\partial p}{\partial n}=0.
$$

## Mathematical Background

“Flow past a cylinder in a channel” is a classic benchmark. In this example, the cylinder is approximated by an axis-aligned mask region (immersed-boundary-style enforcement by zeroing velocity in the masked cells). This provides a simple obstacle treatment while demonstrating how MOLE operators can be used to build a full incompressible flow solver.

The Reynolds number is defined using a characteristic diameter $D$ and inlet speed $U_0$:
$$
\mathrm{Re} = \frac{U_0 D}{\nu}.
$$

In the implementation, $D = 2\,\texttt{cylin\_size}$ and $\nu = U_0 D/\mathrm{Re}$ (default: $\mathrm{Re}=200$).

## Implementation Details

### Projection (Fractional-Step) Method

Each time step advances the momentum equation and enforces incompressibility:

1. **Advection evaluation**
   - Nonlinear convection is advanced with AB2 (Adams–Bashforth 2), with AB1 used on the first step.

2. **Diffusion (Helmholtz solve)**
   - Viscous diffusion is treated with Crank–Nicolson, resulting in two Helmholtz-type sparse linear systems for intermediate velocities $u^*, v^*$.

3. **Pressure Poisson solve**
   - Pressure is obtained from the Poisson equation derived from $\nabla\cdot\mathbf{u}^{n+1}=0$:  
     $$
\nabla^2 p^{n+1} = \frac{\rho}{\Delta t}\nabla\cdot \mathbf{u}^*.
$$

4. **Velocity correction**
   $$
\mathbf{u}^{n+1} = \mathbf{u}^* - \frac{\Delta t}{\rho}\nabla p^{n+1}.
$$

5. **Re-apply boundary conditions + obstacle mask**
   - The solver re-enforces all velocity BCs and sets the masked region to $u=v=0$.

### Mimetic Spatial Operators (MOLE)

The spatial discretization uses MOLE operators:
- Divergence operator $D$,
- Gradient operator $G$,
- Laplacian operator $L = DG$,

along with interpolation operators to map between cell-centered and face-based quantities used in flux evaluations and in the projection step.

### Output Products

The example writes:
- `U_final.csv`, `V_final.csv`, `p_final.csv` (cell-centered fields),
- and an image of the final speed field:
  - `cylinder_flow_2D_output1.png` (this page embeds it as a figure)

## Running the Example

From the build directory:

```bash
cmake --build . -j
./examples/cpp/cylinder_flow_2D
```

## Results

The final speed magnitude typically shows an acceleration around the obstacle and a wake downstream. At $\mathrm{Re}=200$, unsteady vortex shedding can appear depending on grid/time-step choices and the obstacle mask representation.

```{figure} cylinder_flow_2D_output1.png
:alt: Final speed magnitude for 2D channel flow past a masked cylinder obstacle.
:width: 85%

Final speed magnitude field for the 2D channel flow with a masked “cylinder” obstacle.
```

### Validation / Analytical Solution

No closed-form analytical solution is available for this configuration. Practical validation options include:
- verifying that $\|\nabla\cdot\mathbf{u}\|$ remains small after the projection step,
- comparing qualitative wake structure and shedding behavior with known channel-cylinder benchmarks,
- and performing grid/time-step refinement studies.

---

This example is implemented in:
- `examples/cpp/cylinder_flow_2D.cpp`

#### Variants

Possible variants (not included by default) that are useful for exploration:
- different Reynolds numbers (e.g., $50 \le \mathrm{Re} \le 500$),
- refining $m \times n$ resolution to reduce numerical diffusion,
- replacing the rectangular mask by a more geometric obstacle treatment (if desired).
