# Lock Exchange Problem

This example simulates a 2D lock exchange problem using mimetic methods. The lock exchange is a classic fluid dynamics problem where two fluids of different densities initially separated by a vertical barrier (lock) are allowed to flow into each other when the barrier is removed. This creates complex flow patterns including gravity currents and Kelvin-Helmholtz instabilities.

## Governing Equations

The simulation uses the Boussinesq approximation, which accounts for density variations only in the buoyancy term:

$$\frac{\partial \mathbf{u}}{\partial t} + (\mathbf{u} \cdot \nabla) \mathbf{u} = -\frac{1}{\rho_0}\nabla p + \nu \nabla^2 \mathbf{u} + \mathbf{g}\alpha(T-T_0)$$

$$\nabla \cdot \mathbf{u} = 0$$

$$\frac{\partial T}{\partial t} + \mathbf{u} \cdot \nabla T = \kappa \nabla^2 T$$

where:
- $\mathbf{u}$ is the velocity field
- $p$ is the pressure
- $T$ is the temperature
- $\rho_0$ is the reference density
- $\nu$ is the kinematic viscosity
- $\alpha$ is the thermal expansion coefficient
- $\mathbf{g}$ is the gravitational acceleration
- $T_0$ is the reference temperature

## Domain and Initial Conditions

The simulation is conducted on a rectangular domain $[0, 100] \times [0, 20]$ meters. Initially, fluids of different densities (or temperatures) are separated at the mid-point of the domain with a narrow transition region.

## Numerical Method

The equations are solved using a fractional step method (projection method):

1. **Predictor Step**: Compute an intermediate velocity field $\mathbf{u}^*$ without enforcing incompressibility
2. **Pressure Solution**: Solve a Poisson equation for pressure to enforce incompressibility
3. **Corrector Step**: Project the velocity field to be divergence-free
4. **Temperature Advection**: Update temperature using upwind/downwind differencing

Spatial discretization uses mimetic operators:
- Divergence operator ($D$)
- Gradient operator ($G$)
- Laplacian operator ($L = DG$)

## Implementation

```matlab
%% Parameters (for seawater @ S = 35)
alpha = 1.664e-4;        % 1/°C Coefficient of thermal expansion
T_0 = 10;                % °C Reference temperature
rho_0 = 1027;            % kg/m3 Reference density
interface_width = 0.1;   % m Width of the interface
g = 9.806;               % m/s2 Gravity acceleration
reduced_gravity = 0.01;  % m/s2 Reduced gravity
delta_rho = reduced_gravity*rho_0/g;  % Density difference between the two fluids

%% Mimetic operators
k = 2;                        % Spatial order of accuracy
D = div2D(k, m, dx, n, dy);   % Divergence
G = grad2D(k, m, dx, n, dy);  % Gradient
L = D*G;                      % Laplacian

% Premultiplication of G
G = -dt/rho_middle*G;

% Apply Neumann BCs to Laplacian
L = L+robinBC2D(k, m, dx, n, dy, 0, 1);

%% Main time loop 
for t = 1 : iterations
    %% Predictor step
    % Compute intermediate velocities u_s and v_s
    
    %% Solve for pressure
    R = rho_dt*[u_s; v_s];
    p = L\(D*R);
    
    %% Corrector step
    u = u_s+G(1:u_length, :)*p;
    v = v_s+G(u_length+1:end, :)*p;
    
    %% Advection of heat
    % Update temperature
end
```

## Results

The simulation captures the gravity currents that form as the denser fluid flows beneath the lighter fluid. Depending on the Reynolds number, Kelvin-Helmholtz billows may develop along the interface. Due to the relatively coarse grid, numerical diffusion limits the formation of sharp billows, but increasing the resolution would allow for more detailed structures to emerge. 