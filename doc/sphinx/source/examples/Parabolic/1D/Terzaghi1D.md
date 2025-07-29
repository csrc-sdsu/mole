### Terzaghi One-Dimensional Consolidation

Simulates **Terzaghi's 1D consolidation** using mimetic finite difference operators from the MOLE library. The system models **transient flow and deformation** in a saturated soil column under a **constant compressive load** at one end with **drainage permitted only at the loaded boundary**.

The governing pressure equation is:

$$
\frac{\partial p}{\partial t} = c_f \nabla^2 p
$$

with $x\in[0,25]$ meters. Displacement and strain are derived from the pressure, and Darcy’s law is used to compute fluid flux.

#### Boundary conditions:

- **Dirichlet** at $x = 0$: $p(0, t) = 0$   
- **Neumann** at $x = L$: $\displaystyle \frac{dp}{dx}(L, t) = 0$
This setup models **open drainage** at the loaded face and **no flow** at the fixed base.

This corresponds to a domain with **impermeable backing** and **open drainage at the loaded end**.

#### Numerical Strategy

- Pressure is initialized to a uniform value $P_0 = 10\ \mathrm{MPa}$
- Integration is performed using **Forward Euler**
- Mimetic MOLE operators:
  - `lap()` for pressure diffusion
  - `grad()` for Darcy flux
  - `div()` for residual calculations
- Spatial discretization uses a **staggered grid** with ghost cells to enforce boundary conditions

#### Analytical Benchmark

An analytical solution is computed using a **Fourier series expansion**:

$$
p(x,t) = \sum_{n=0}^{\infty} \left( \frac{4 P_0}{n \pi} \sin\left(\frac{n \pi x}{2L}\right) e^{- \frac{n^2 \pi^2 c_f t}{4L^2}} \right), \quad n = 2k + 1
$$

The benchmark solution includes:
- Pressure field
- Flux via Darcy's law
- Strain and displacement
- Mass conservation residual

#### Outputs

At selected time snapshots (1, 10, 40, 70 hours), the following are printed and plotted:

- **Numerical and analytical pressure** profiles
- **Darcy flux** from numerical and analytical solutions
- **Displacement fields**
- **Mass balance residuals**
- **Relative L2 error** tables
- **3D surface plots** for pressure, displacement, and residual evolution

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

#### Code Location

This example is implemented in:  
- [MATLAB/ OCTAVE (terzaghi1D.m)](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/terzaghi1D.m)
