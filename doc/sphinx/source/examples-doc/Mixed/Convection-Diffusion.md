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

## Implementation

```matlab
% Mimetic operator's parameters
k = 2;
m = 101; n = 51; o = 101;  % Grid dimensions

% Domain dimensions
a = 0; b = 101;  % x-direction
c = 0; d = 51;   % y-direction
e = 0; f = 101;  % z-direction

% Spatial steps
dx = (b-a)/m; dy = (d-c)/n; dz = (f-e)/o;

% Mimetic operators
D = div3D(k, m, dx, n, dy, o, dz);
G = grad3D(k, m, dx, n, dy, o, dz);
I = interpol3D(m, n, o, 1, 1, 1);

% Create velocity field with impermeable shale layers
y = ones(m, n+1, o);
y(:, seal, :) = 0;      % First shale layer
y(:, seal+5, :) = 0;    % Second shale layer
y = y(:);
V(((m+1)*n*o+1):((m+1)*n*o+numel(y))) = y;

% Set initial concentration (injection well)
C(ceil((m+2)/2), bottom:top, ceil((o+2)/2)) = 1;

% Time integration
for i = 1 : iterations
    % Solve diffusion (implicit)
    C = L*C;
    
    % Impose source conditions
    C(idx) = 1;
    
    % Solve convection (explicit)
    C = C - D*C;
    
    % Reimpose source conditions
    C(idx) = 1;
end
```

## Results

The simulation shows how CO₂ spreads through the domain, with the shale layers acting as barriers to flow. The concentration profile evolves over time due to:
1. Molecular diffusion (spreading in all directions)
2. Advective transport (preferential movement in the direction of flow)
3. Reduced transport through low-permeability layers

This type of simulation is valuable for understanding subsurface fluid dynamics and designing effective carbon storage strategies. 