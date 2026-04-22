%% 2D incompressible channel flow past a cylinder
%
% This example solves the two-dimensional incompressible Navier-Stokes
% equations in a rectangular channel,
%
%     du/dt + d(u^2)/dx + d(uv)/dy = -(1/rho) dp/dx + nu * Lap(u),
%     dv/dt + d(uv)/dx + d(v^2)/dy = -(1/rho) dp/dy + nu * Lap(v),
%     du/dx + dv/dy = 0,
%
% on the domain
%
%     x in [0, 8],   y in [-1, 1].
%
% The flow is advanced with a projection (pressure-correction) method:
%
%   1) compute tentative velocities U*, V* from the momentum equations
%      without the new pressure,
%   2) solve a pressure Poisson equation so that the corrected velocity
%      satisfies incompressibility,
%   3) correct the velocity field with the pressure gradient.
%
% Boundary conditions:
%
%   Velocity:
%     - inlet   (left)   : u = U_init, v = 0
%     - outlet  (right)  : du/dx = 0, dv/dx = 0
%     - walls   (top/bot): u = 0, v = 0   (no-slip)
%
%   Pressure:
%     - outlet  (right)  : p = 0   (reference pressure)
%     - elsewhere        : zero normal pressure gradient
%
% Initial condition:
%
%   The velocity is initialized as
%
%     u = U_init,   v = 0
%
%   in the fluid region, and is set to zero inside the masked obstacle
%   region.
%
% Mimetic discretization (MOLE):
%
%   This script uses MOLE mimetic operators on a Cartesian grid. The main
%   discrete operators are
%
%     L  = lap2D(...)    : cell-centered Laplacian for viscous diffusion
%     D  = div2D(...)    : divergence of stacked face fluxes [Fx; Fy]
%     G  = grad2D(...)   : gradient of cell-centered pressure
%     I  = interpolCentersToFacesD2D(...)
%                        : interpolation from cell centers to faces
%     II = interpolFacesToCentersG2D(...)
%                        : interpolation from faces back to cell centers
%
%   The convective terms are assembled in conservative flux form on faces,
%   then mapped back to cell centers by the mimetic divergence operator.
%   Pressure is stored at cell centers, its gradient is computed on faces,
%   and the velocity correction is brought back to the cell-centered
%   storage used in this example.
%
% Storage convention:
%
%   U_flat, V_flat, and p_new_flat are column-vector versions of the
%   cell-centered fields (including MOLE boundary locations). Quantities
%   with suffixes _on_u and _on_v denote values located on vertical and
%   horizontal faces, respectively.
%
% Obstacle mask:
%
%   The obstacle is introduced through a Cartesian mask rather than a
%   body-fitted curved boundary. A block of grid cells near the nominal
%   cylinder location is marked as solid, and velocities are forced to zero
%   there at initialization and after each update. In this sense, the mask
%   acts as a simple immersed no-slip obstacle on the background grid.
%
% Notes:
%
%   - Although motivated by flow past a cylinder, the present MATLAB
%     implementation uses a masked block of cells, not a fitted circular
%     boundary.
%   - The purpose of this example is to demonstrate how MOLE mimetic
%     operators and interpolation matrices can be combined to build a
%     transient incompressible flow solver in a compact way.

close all; clear; clc;
addpath('../../src/matlab_octave')

%% Settings (match C++)
Re    = 200;     % C++: 200
k     = 2;       % C++: 2
tspan = 32;      % C++: 32.0
dt    = 0.005;   % C++: 0.005

%% Domain and grid (match C++)
x_start = 0;  x_end = 8;
y_start = -1; y_end = 1;

m = 481;
n = 121;

dx = (x_end - x_start)/m;
dy = (y_end - y_start)/n;

% Cell-centered "with ghost" coords (length m+2, n+2)
xgrid = [0 dx/2:dx:(x_end-x_start)-dx/2 (x_end-x_start)];
ygrid = [0 dy/2:dy:(y_end-y_start)-dy/2 (y_end-y_start)];
[Y, X] = meshgrid(ygrid, xgrid);

%% Obstacle (match C++)
cylin_pos  = 1/8;
cylin_size = 1/10;

%% Physical parameters (match C++ formula)
rho    = 1;
D0     = 2*cylin_size;
U_init = 1;
nu     = U_init * D0 / Re;

%% Mimetic operators (MOLE)
L  = lap2D(k, m, dx, n, dy);
D  = div2D(k, m, dx, n, dy);
G  = grad2D(k, m, dx, n, dy);

I  = interpolCentersToFacesD2D(k, m, n);
II = interpolFacesToCentersG2D(k, m, n);

Ncell = (m+2)*(n+2);
Icell = speye(Ncell);

% CN diffusion matrices
M  = (Icell - 0.5*dt*nu*L);
Mp = (Icell + 0.5*dt*nu*L);

%% Initial conditions (match C++)
U = 0.*X + U_init;
V = 0.*X;

% cylinder mask indices 
m_unit = floor(cylin_pos*m);
halfN1 = 0.5*(n+3);  % n odd => integer
rad    = floor(cylin_size*m_unit);

i1 = m_unit - rad;
i2 = m_unit + rad;
j1 = halfN1 - rad;
j2 = halfN1 + rad;

U(i1:i2, j1:j2) = 0;
V(i1:i2, j1:j2) = 0;

U_flat = U(:);
V_flat = V(:);

AdvU_prev = zeros(size(U_flat));
AdvV_prev = zeros(size(V_flat));

p_new_flat = zeros(Ncell,1);

%% Helmholtz BCs for U*, V*
dcU = [1;0;1;1];  ncU = [0;1;0;0];
vU  = {ones(n,1); zeros(n,1); zeros(m+2,1); zeros(m+2,1)};

dcV = [1;0;1;1];  ncV = [0;1;0;0];
vV  = {zeros(n,1); zeros(n,1); zeros(m+2,1); zeros(m+2,1)};

[Au, bU0] = addScalarBC2D(M, zeros(Ncell,1), k, m, dx, n, dy, dcU, ncU, vU);
[Av, bV0] = addScalarBC2D(M, zeros(Ncell,1), k, m, dx, n, dy, dcV, ncV, vV);

diffU   = Au - M;
diffV   = Av - M;
rowsbcU = find(sum(spones(diffU),2) ~= 0);
rowsbcV = find(sum(spones(diffV),2) ~= 0);

Au_fac = decomposition(Au, 'lu');
Av_fac = decomposition(Av, 'lu');

%% Pressure Poisson BCs
dcP = [0;1;0;0];  ncP = [1;0;1;1];
vP  = {zeros(n,1); zeros(n,1); zeros(m+2,1); zeros(m+2,1)};

[Ap, bP0] = addScalarBC2D(L, zeros(Ncell,1), k, m, dx, n, dy, dcP, ncP, vP);
diffP   = Ap - L;
rowsbcP = find(sum(spones(diffP),2) ~= 0);

Ap_fac = decomposition(Ap, 'lu');

%% Time integration (match C++ structure)
nSteps   = round(tspan/dt);
plotEvery = 100;

for t_step = 1:nSteps

    % Interpolate cell-centered U/V to faces
    U_stag = I * [U_flat; U_flat];
    U_on_u = U_stag(1:(m+1)*n);
    U_on_v = U_stag((m+1)*n+1:end);

    V_stag = I * [V_flat; V_flat];
    V_on_u = V_stag(1:(m+1)*n);
    V_on_v = V_stag((m+1)*n+1:end);

    % Nonlinear fluxes on faces
    UU_on_u = U_on_u .* U_on_u;
    UV_on_u = U_on_u .* V_on_u;

    VV_on_v = V_on_v .* V_on_v;
    UV_on_v = U_on_v .* V_on_v;

    u_div = [UU_on_u; UV_on_v];
    v_div = [UV_on_u; VV_on_v];

    AdvU_n = D * u_div;
    AdvV_n = D * v_div;

    % AB2 (AB1 on first step)
    if t_step == 1
        AdvU_ab = AdvU_n;
        AdvV_ab = AdvV_n;
    else
        AdvU_ab = 1.5*AdvU_n - 0.5*AdvU_prev;
        AdvV_ab = 1.5*AdvV_n - 0.5*AdvV_prev;
    end

    % Helmholtz solves (CN diffusion) with BCs
    rhsU = Mp*U_flat - dt*AdvU_ab;
    rhsV = Mp*V_flat - dt*AdvV_ab;

    rhsU_bc = rhsU; rhsU_bc(rowsbcU) = 0; rhsU_bc = rhsU_bc + bU0;
    rhsV_bc = rhsV; rhsV_bc(rowsbcV) = 0; rhsV_bc = rhsV_bc + bV0;

    U_star_flat = Au_fac \ rhsU_bc;
    V_star_flat = Av_fac \ rhsV_bc;

    U_star = reshape(U_star_flat, m+2, n+2);
    V_star = reshape(V_star_flat, m+2, n+2);

    % Mask + corner consistency 
    U_star(i1:i2, j1:j2) = 0;
    V_star(i1:i2, j1:j2) = 0;

    U_star(1,1)   = 0;  U_star(1,end) = 0;
    V_star(1,1)   = 0;  V_star(1,end) = 0;

    U_star_flat = U_star(:);
    V_star_flat = V_star(:);

    % Pressure Poisson RHS from u*
    U_star_stag = I * [U_star_flat; U_star_flat];
    U_star_on_u = U_star_stag(1:(m+1)*n);

    V_star_stag = I * [V_star_flat; V_star_flat];
    V_star_on_v = V_star_stag((m+1)*n+1:end);

    UV_star_div = [U_star_on_u; V_star_on_v];
    RHS = (rho/dt) * (D * UV_star_div);

    RHS_bc = RHS; RHS_bc(rowsbcP) = 0; RHS_bc = RHS_bc + bP0;
    p_new_flat = Ap_fac \ RHS_bc;

    % Projection correction
    U_V_flat = [U_star_flat; V_star_flat] - (dt/rho) * (II * G * p_new_flat);

    U_new = reshape(U_V_flat(1:Ncell), m+2, n+2);
    V_new = reshape(U_V_flat(Ncell+1:end), m+2, n+2);

    % CRITICAL: re-apply velocity BCs AFTER projection
    [U_new, V_new] = applyVelocityBCAndMask(U_new, V_new, U_init, i1,i2,j1,j2);

    % Update
    U_flat = U_new(:);
    V_flat = V_new(:);

    AdvU_prev = AdvU_n;
    AdvV_prev = AdvV_n;

    if (mod(t_step, plotEvery) == 0) || (t_step == 1) || (t_step == nSteps)
        maxU = max(abs(U_new(:)));
        maxV = max(abs(V_new(:)));
        CFL  = dt * (maxU/dx + maxV/dy);
        inletMean = mean(U_new(1,:));
        fprintf('step %6d/%6d | t=%.6f | CFL~%.3f | max|U|=%.3e | max|V|=%.3e | mean(U_in)=%.3f\n', ...
            t_step, nSteps, dt*t_step, CFL, maxU, maxV, inletMean);
    end
end

%% Final plot: U, V, p in one column (3x1)
U = reshape(U_flat, m+2, n+2);
V = reshape(V_flat, m+2, n+2);
p = reshape(p_new_flat, m+2, n+2);

figure('Name','Final U/V/p','NumberTitle','off');
set(gcf, 'WindowState', 'maximized');

subplot(3,1,1)
imagesc(U'); axis image; axis tight; colorbar;
xlabel('x (grid index)'); ylabel('y (grid index)');
title(sprintf('U at t = %.3f', tspan))

subplot(3,1,2)
imagesc(V'); axis image; axis tight; colorbar;
xlabel('x (grid index)'); ylabel('y (grid index)');
title(sprintf('V at t = %.3f', tspan))

subplot(3,1,3)
imagesc(p'); axis image; axis tight; colorbar;
xlabel('x (grid index)'); ylabel('y (grid index)');
title('Pressure p')

%% -------- local helper: enforce velocity BCs + corner + cylinder mask -----
function [U, V] = applyVelocityBCAndMask(U, V, Uin, i1,i2,j1,j2)
    % inlet Dirichlet
    U(1,:) = Uin;
    V(1,:) = 0;

    % outlet Neumann (zero-gradient)
    U(end,:) = U(end-1,:);
    V(end,:) = V(end-1,:);

    % walls no-slip
    U(2:end,1)   = 0;
    V(2:end,1)   = 0;
    U(2:end,end) = 0;
    V(2:end,end) = 0;

    % inlet-wall corners should obey wall
    U(1,1)   = 0;  U(1,end)   = 0;
    V(1,1)   = 0;  V(1,end)   = 0;

    % cylinder mask
    U(i1:i2, j1:j2) = 0;
    V(i1:i2, j1:j2) = 0;
end
