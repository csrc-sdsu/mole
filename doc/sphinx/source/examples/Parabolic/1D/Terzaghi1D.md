% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008–2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
% Simulates Terzaghi’s 1D consolidation using mimetic finite difference
% operators from the MOLE library. Pressure is evolved over time using a
% diffusion-like PDE; displacement is derived post-simulation.
%
% Governing equation:
%     ∂p/∂t = cf * ∇²p
%
% Boundary conditions:
%     Dirichlet: p(0,t) = 0
%     Neumann: dp/dx(L,t) = 0
% This setup models open drainage at the loaded face and no flow at the fixed base.
% This corresponds to a domain with impermeable backing and open drainage at the loaded end.
% Outputs include pressure, Darcy flux, displacement, and mass residuals.


#### Numerical Strategy

- Pressure is initialized to a uniform value $P_0 = 10\ \mathrm{MPa}$
- Integration is performed using **Forward Euler**
- Mimetic MOLE operators:
  - `lap()` for pressure diffusion
  - `grad()` for Darcy flux
  - `div()` for residual calculations
- Spatial discretization uses a **staggered grid** with ghost cells to enforce boundary conditions

---

#### Analytical Benchmark

An analytical solution is computed using a **Fourier series expansion**:

$$
p(x,t) = \sum_{n=0}^{\infty} \left( \frac{4 P_0}{n \pi} \sin\left(\frac{n \pi x}{2L}\right) e^{- \frac{n^2 \pi^2 c_f t}{4L^2}} \right), \quad n = 2k + 1
$$

The benchmark solution includes:
- Pressure field
- Flux via Darcy’s law
- Strain and displacement
- Mass conservation residual

---

#### Outputs

At selected time snapshots (1, 10, 40, 70 hours), the following are printed and plotted:

- **Numerical and analytical pressure** profiles
- **Darcy flux** from numerical and analytical solutions
- **Displacement fields**
- **Mass balance residuals**
- **Relative L2 error** tables
- **3D surface plots** for pressure, displacement, and residual evolution

---

#### Physical Parameters

| Parameter | Value                                 | Description                          |
|----------:|---------------------------------------|--------------------------------------|
| $P_0$      | 10 MPa                                | Face load                            |
| $c_f$      | $1\times10^{-4}$                      | Diffusivity                          |
| $K$        | $1\times10^{-12}\,\mathrm{m}^2$       | Permeability                         |
| $\mu$      | $1\times10^{-3}\,\mathrm{Pa\cdot s}$  | Dynamic viscosity                    |
| $K_s$      | $1\times10^8\,\mathrm{Pa}$            | Bulk modulus                         |
| $\alpha$   | 1.0                                   | Biot coefficient                     |
| $S_s$      | $1\times10^{-5}\,\mathrm{Pa}^{-1}$    | Specific storage coefficient         |
| $\rho$     | $1000\,\mathrm{kg/m^3}$               | Fluid density                        |
| $g$        | $9.81\,\mathrm{m/s^2}$                | Gravitational acceleration           |

---

#### Code Location

This example is implemented in:  
- [MATLAB/ OCTAVE (terzaghi1D.m)](https://github.com/csrc-sdsu/mole/blob/master/examples/matlab/terzaghi1D.m)

---
