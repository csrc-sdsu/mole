%% 2D incompressible flow over a square cylinder (masked region)
% Projection method: AB2 (advection) + CN (diffusion)
% MATLAB version aligned with the C++ example settings/output plotting.

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

% cylinder mask indices (same logic as your original)
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

    % Interpolate cell-centered U/V to faces (same intent as C++)
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

    % Mask + corner consistency (same as your "fixes")
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

    % CRITICAL: re-apply velocity BCs AFTER projection (aligns with C++ behavior)
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
