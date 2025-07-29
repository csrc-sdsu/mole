# 3D Convection-Diffusion Equation

This example solves the three-dimensional convection-diffusion equation using mimetic methods. The convection-diffusion equation is a parabolic partial differential equation that describes physical phenomena where particles, energy, or other physical quantities are transferred inside a physical system due to two processes: diffusion and convection.

## Mathematical Model

The convection-diffusion equation has the form:

$$\frac{\partial C}{\partial t} + \nabla \cdot (\mathbf{v} C) = \nabla \cdot (D \nabla C)$$

where:
- $C$ is the concentration (or density)
- $\mathbf{v}$ is the velocity field
- $D$ is the diffusion coefficient

This equation combines:
- The diffusion term: $\nabla \cdot (D \nabla C)$
- The convection term: $\nabla \cdot (\mathbf{v} C)$

## Application Context

This example simulates CO₂ transport in a geological formation with impermeable shale layers. The simulation represents CO₂ injection through a well, and its subsequent movement through porous media with varying permeability. This type of simulation is important for:
- Carbon capture and storage (CCS) studies
- Underground contaminant transport
- Enhanced oil recovery analysis

## Numerical Method

The equation is solved using operator splitting with:
1. A Forward-Time Central-Space (FTCS) scheme for the diffusion term
2. An upwind scheme for the convection term

Mimetic operators are used for spatial discretization:
- Divergence operator ($D$)
- Gradient operator ($G$)
- Interpolation operator ($I$)

Time step constraints include:
- von Neumann stability criterion for diffusion: $\Delta t \leq \frac{\Delta x^2}{3D}$
- CFL condition for convection: $\Delta t \leq \frac{\Delta x}{\max(|\mathbf{v}|)}$

---

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/convection_diffusion3D.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/convection_diffusion3D.cpp)

## Results

The simulation shows how CO₂ spreads through the domain, with the shale layers acting as barriers to flow. The concentration profile evolves over time due to:
1. Molecular diffusion (spreading in all directions)
2. Advective transport (preferential movement in the direction of flow)
3. Reduced transport through low-permeability layers

This type of simulation is valuable for understanding subsurface fluid dynamics and designing effective carbon storage strategies. 
