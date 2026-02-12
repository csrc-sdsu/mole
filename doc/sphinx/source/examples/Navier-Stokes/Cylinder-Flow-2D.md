# 2D Channel Flow with a Cylinder-Like Obstacle (Masked Region)

This example simulates a 2D incompressible channel flow past a cylinder-like obstacle (implemented as an axis-aligned masked no-slip region) using MOLE mimetic operators and a fractional-step (projection / pressure-correction) method. At moderate Reynolds number, the solution exhibits a wake and may show vortex shedding depending on grid resolution, time step, and the obstacle mask representation.

## Governing Equations

We solve the incompressible Navier–Stokes equations in two dimensions:

$$
\frac{\partial \mathbf{u}}{\partial t} + (\mathbf{u}\cdot\nabla)\mathbf{u}
= -\frac{1}{\rho}\nabla p + \nu\nabla^{2}\mathbf{u}
$$

$$
\nabla\cdot\mathbf{u} = 0
$$

where:
- $$\mathbf{u}=(u,v)$$ is the velocity field
- $$p$$ is the (dynamic) pressure
- $$\rho$$ is the density
- $$\nu$$ is the kinematic viscosity

> Note: If you prefer using kinematic pressure $$\pi=p/\rho$$, the momentum equation becomes
> $$\partial_t\mathbf{u}+(\mathbf{u}\cdot\nabla)\mathbf{u}=-\nabla \pi + \nu\nabla^2\mathbf{u}.$$

## Domain and Initial/Boundary Conditions

### Spatial/Temporal Domain

The computational domain is a 2D channel:

- $$x \in [0,8]$$
- $$y \in [-1,1]$$
- $$t \in [0, t_{\text{final}}]$$ with $$t_{\text{final}} = \texttt{tspan}$$ (default in code: `tspan = 32.0`)

A “square cylinder” is represented by a masked block of cells located near

$$
x/L_x = \mathtt{cylin}\_\mathtt{pos}
$$

with a size controlled by `cylin_size` (default `1/10`). Inside this mask, velocity is forced to zero (no-slip). The mask is applied as an axis-aligned cell region (not a geometric immersed boundary).

### Initial Conditions (t = 0)

At $$t=0$$:
- $$u(x,y,0)=U_0$$ everywhere in the fluid region
- $$v(x,y,0)=0$$
- the obstacle mask region is set to $$u=v=0$$

(Default in code: `U_init = 1.0`.)

### Boundary Conditions

Velocity boundary conditions:
- **Inlet (left)**: Dirichlet inflow with $$u = U_0$$ and $$v = 0$$
- **Outlet (right)**: zero streamwise gradient (Neumann outflow) with $$\partial u/\partial x = 0$$ and $$\partial v/\partial x = 0$$
- **Top and bottom walls**: no-slip with $$u=0$$ and $$v=0$$
- **Obstacle mask**: no-slip enforced by setting $$u=v=0$$ inside the mask region after each time step

Pressure boundary conditions (pressure Poisson step):
- **Outlet (right)**: Dirichlet reference pressure with $$p = 0$$
- **Other boundaries**: homogeneous Neumann with $$\partial p/\partial n = 0$$

## Implementation Details

### Projection (Fractional-Step) Method

Each time step advances a predictor–corrector scheme to enforce incompressibility:

1. **Prediction (intermediate velocity)**
   - Compute the intermediate velocity $$\mathbf{u}^*$$ by advancing the momentum equation
   - Nonlinear convection is advanced with AB2 (AB1 for the first step)
   - Viscous diffusion is treated with Crank–Nicolson, leading to Helmholtz-type solves for $$u^*$$ and $$v^*$$

2. **Pressure Poisson solve**

$$
\nabla^2 p^{n+1} = \frac{\rho}{\Delta t}\nabla\cdot \mathbf{u}^*
$$

3. **Velocity correction**

$$
\mathbf{u}^{n+1} = \mathbf{u}^* - \frac{\Delta t}{\rho}\nabla p^{n+1}
$$

4. **Re-apply boundary conditions + obstacle mask**
   - Re-enforce all velocity boundary conditions
   - Set the masked obstacle region to $$u=0$$ and $$v=0$$.

### Mimetic Spatial Operators (MOLE)

The spatial discretization uses MOLE operators:
- Divergence operator $$D$$
- Gradient operator $$G$$
- Laplacian operator $$L = DG$$

along with interpolation operators to map between cell-centered and face-based quantities used in flux evaluations and in the projection step.

## Output Products

The solver writes the final cell-centered fields:
- `U_final.csv`, `V_final.csv`, `p_final.csv`

A plotting script is provided to visualize these CSV outputs using gnuplot:
- `cylinder_flow_2D_plot.gnu` → produces `cylinder_flow_2D_plot.png`

## Running the Example

Assuming you already configured and built MOLE following the tutorial, run the example from the `examples/cpp` directory so that all outputs (CSV + plots) are written next to the source and plotting scripts:

```bash
cd <mole-repo>/examples/cpp
../../build/examples/cpp/cylinder_flow_2D
gnuplot cylinder_flow_2D_plot.gnu
