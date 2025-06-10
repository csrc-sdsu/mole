% -------------------------------------------------------------------------
% Terzaghi One-Dimensional Consolidation Example
%
% Consolidation is the process of transient fluid flow through a porous
% medium that deforms over time.
%
% A constant compressive face load of P0 = 10 MPa is applied at the
% left boundary (x = 0 m) of a saturated porous soil matrix.
%
% Zero displacement is assumed at the right boundary (x = L = 25 m),
% representing a fixed wall or support.
%
% The matrix is assumed to be fully saturated, and fluid drainage is
% permitted only at the loaded boundary (x = 0 m).
%
% The MOLE Laplacian operator is used to compute the excess pore pressure
% p(x, t), satisfies a one-dimensional diffusion equation for pressure.
%
% The domain is defined on the interval x ∈ [0, L] meters.
%
% The simulation compares the MOLE-based numerical solution to an
% analytical benchmark solution derived using Fourier series.
%
% Parameters:
%      P0       : Applied face load [Pa]
%      cf       : Consolidation coefficient or effective diffusion constant [m²/s]
%      l        : Domain length [m]
%      k        : Order of the mimetic operator (2, 4, or higher)
%      m        : Number of cells (discretization resolution)
%      K        : Permeability of the porous medium [m²]
%      mu       : Dynamic viscosity of the fluid [Pa·s]
%      rho      : Fluid density [kg/m³]
%      g        : Acceleration due to gravity [m/s²]
%      Ks       : Bulk modulus of the solid matrix [Pa]
%      alpha    : Biot coefficient (typically between 0 and 1)
%      Ss       : Specific storage coefficient [1/Pa]
%      dx       : Grid spacing [m]
%      xgrid    : Spatial grid points with ghost nodes [m]
%      times_hr : Time points at which results are computed [hours]
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
%%
clc;
close all;

addpath('../../src/matlab_octave');  % MOLE operator path

%% Parameters
P0 = 10e6;         % Face load in Pascals
cf = 1e-4;         % Diffusion constant
l = 25;            % Domain length in meters
k = 2;             % MOLE operator order
m = 50;            % Number of cells

% Spatial discretization
a = 0;                  % Left boundary of the domain [m]
b = l;                  % Right boundary of the domain [m]
dx = (b - a)/m;         % Cell width (uniform grid spacing) [m]
xgrid = [a a+dx/2 : dx : b-dx/2 b];  % Staggered grid with ghost nodes at boundaries
% xgrid has m+2 points: 
% - ghost cell at a (Dirichlet BC)
% - m internal nodes
% - ghost cell at b (Neumann BC)

% Times to evaluate (in hours)
times_hr = [1, 10, 40, 70];         % Time snapshots in hours for comparison
times_sec = times_hr * 3600;        % Convert time points to seconds for simulation

% Fluid properties
K = 1e-12;        % Permeability [m^2]
mu = 1e-3;        % Dynamic viscosity [Pa·s]
rho = 1000;       % Fluid density [kg/m^3]
g = 9.81;         % Gravity [m/s^2]
Ks = 1e8;          % Bulk modulus [Pa]
alpha = 1;         % Biot coefficient
Ss = 1e-5;         % [1/Pa] Specific storage coefficient

%% Numerical (MOLE) Solution
L = lap(k, m, dx);       % Mimetic Laplacian operator for diffusion
G = grad(k, m, dx);      % Mimetic gradient operator for Darcy flux

% Boundary modifications to Laplacian
L(1,:) = 0; L(end,:) = 0;

p_numerical = zeros(length(xgrid), length(times_sec));   % Pressure field [Pa]
q_numerical = zeros(m+1, length(times_sec));             % Darcy flux [m/s] (size = m+1)
e_numerical = zeros(length(xgrid), length(times_sec));   % Strain field
u_numerical = zeros(length(xgrid), length(times_sec));   % Displacement field

% Loop over each specified final time
for i = 1:length(times_sec)
    t_final = times_sec(i);
    dt = 1.0;                       
    nsteps = round(t_final / dt);

    % Uniform Initial Condition : p(x,0) = P0
    p = P0 * ones(size(xgrid))';   

    % Time integration using Forward Euler
    for step = 1:nsteps
        p = p + dt * cf * (L * p);     % Pressure diffusion
        p(1) = 0;                      % Dirichlet BC at x = 0
        p(end) = p(end-1);             % Neumann BC at x = L
    end

    % Compute strain and displacement from final pressure
    e = (alpha * p - P0) / Ks;
    u = cumtrapz(xgrid, e); %cumulative integral using the trapezoidal rule.

    % Store results
    e_numerical(:,i) = e;
    u_numerical(:,i) = u;
    p_numerical(:,i) = p;
    
    % Compute darcy flux
    dpdx = G * p;
    q = - (K / mu) * (dpdx - rho * g);
    q_numerical(:,i) = q(1:m+1);

end

%% Mass Conservation Residual Evaluation

% Compute dp/dt and de/dt using backward differences
dpdt = zeros(size(p_numerical));
dedt = zeros(size(e_numerical));

for i = 2:length(times_sec)
    dt_local = times_sec(i) - times_sec(i-1);
    dpdt(:,i) = (p_numerical(:,i) - p_numerical(:,i-1)) / dt_local;
    dedt(:,i) = (e_numerical(:,i) - e_numerical(:,i-1)) / dt_local;
end

% Compute divergence of q using MOLE div()
divq = zeros(size(p_numerical));  % same shape as pressure field
for i = 1:length(times_sec)
    qx = q_numerical(:,i);                 % q has m+1 values
    divq(:,i) = div(k, m, dx) * qx;        % returns m+2 values (staggered grid)
end

% Compute full mass balance residual
residual = Ss * dpdt + alpha * dedt - divq;

%% Combined Numerical Output
for i = 1:length(times_sec)
    fprintf('\nNumerical results at t = %.2f hr:\n', times_hr(i));
    fprintf('|     x (m)     | Numerical p [Pa] | Darcy Flux [m/s] | Residual [1/s]   |\n');
    fprintf('|---------------|------------------|------------------|------------------|\n');
    for j = 1:m+1
        if i == 1
            fprintf('| %13.6f | %16.6e | %16.6e | %16s |\n', ...
                xgrid(j), p_numerical(j,i), q_numerical(j,i), 'N/A');
        else
            fprintf('| %13.6f | %16.6e | %16.6e | %16.6e |\n', ...
                xgrid(j), p_numerical(j,i), q_numerical(j,i), residual(j,i));
        end
    end
end


%% Analytical Solution
N_max = 100; % Number of Fourier series terms
p_analytical = zeros(length(xgrid), length(times_sec)); % Pressure field [Pa]
q_analytical = zeros(m+1, length(times_sec)); % Darcy flux [m/s] (size = m+1)
e_analytical = zeros(length(xgrid), length(times_sec)); % Strain field
u_analytical = zeros(length(xgrid), length(times_sec)); % Displacement field
residual_analytical = zeros(length(xgrid), length(times_sec));

% Loop over all time snapshots
for i = 1:length(times_sec)
    t = times_sec(i);
    p = zeros(size(xgrid));

    % Compute analytical pressure using Fourier series
    for N = 0:N_max
        n = 2*N + 1; 
        term = (1/n) * sin(n*pi*xgrid/(2*l)) .* exp(-(n^2)*(pi^2)*cf*t/(4*l^2));
        p = p + term;
    end
    p = (4/pi) * P0 * p;
    p_analytical(:,i) = p;

    % Compute Darcy flux
    dpdx = gradient(p, dx);
    q = - (K / mu) * (dpdx - rho * g);
    q_analytical(:,i) = q(1:m+1);

    % Compute analytical strain and displacement
    e = (alpha * p - P0) / Ks;
    u = cumtrapz(xgrid, e);
    e_analytical(:,i) = e;
    u_analytical(:,i) = u;
    

    % Compute mass conservation residual (analytical)
    if i == 1
        residual_analytical(:,i) = NaN(size(p_analytical(:,i)));  % undefined at first time step
    else
        dt_local = times_sec(i) - times_sec(i-1);
        dpdt_ana = (p_analytical(:,i) - p_analytical(:,i-1)) / dt_local;
        dedt_ana = (e_analytical(:,i) - e_analytical(:,i-1)) / dt_local;
        divq_ana = div(k, m, dx) * q_analytical(:,i);
        residual_analytical(:,i) = Ss * dpdt_ana + alpha * dedt_ana - divq_ana;
    end


    % Print combined analytical output
    fprintf('\nAnalytical results at t = %.2f hr:\n', times_hr(i));
    fprintf('|     x (m)     | Analytical p [Pa] | Darcy Flux [m/s] | Residual [1/s]   |\n');
    fprintf('|---------------|-------------------|------------------|------------------|\n');
    for j = 1:m+1
        if i == 1
            fprintf('| %13.6f | %18.6e | %16.6e | %16s |\n', ...
                xgrid(j), p_analytical(j,i), q_analytical(j,i), 'N/A');
        else
            fprintf('| %13.6f | %18.6e | %16.6e | %16.6e |\n', ...
                xgrid(j), p_analytical(j,i), q_analytical(j,i), residual_analytical(j,i));
        end
    end

    if i > 1
        max_res = max(abs(residual_analytical(2:end-1,i)));
        fprintf('|     Max Residual (interior) at t = %.2f hr: %e |\n', times_hr(i), max_res);
    end
end

%% Combined Plot
figure('Name','Terzaghi one-dimensional consolidation');
set(gcf,'Color','white');

% Top subplot: MOLE numerical
subplot(2,1,1);
hold on;
for i = 1:length(times_sec)
    semilogy(xgrid, p_numerical(:,i)/1e6, '-o', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
title('MOLE Numerical Solution');
ylabel('Excess Pore Pressure p(x,t) [MPa]');
axis([0 l 1e-3 10]);
legend('Location', 'southeast');
grid on;

% Bottom subplot: Analytical
subplot(2,1,2);
hold on;
for i = 1:length(times_sec)
    semilogy(xgrid, p_analytical(:,i)/1e6, '--s', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
title('Analytical Benchmark Solution');
xlabel('x (m)');
ylabel('Excess Pore Pressure p(x,t) [MPa]');
axis([0 l 1e-3 10]);
legend('Location', 'southeast');
grid on;



%% Combined Displacement Plot (Numerical vs Analytical)
figure('Name','Displacement Field (Numerical vs Analytical)');
set(gcf,'Color','white');

% Top subplot: Numerical displacement
subplot(2,1,1);
hold on;
for i = 1:length(times_sec)
    plot(xgrid, u_numerical(:,i), '-o', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
xlabel('x (m)');
ylabel('Displacement u(x,t) [m]');
title('Numerical Displacement Field');
legend('Location','southwest');
grid on;

% Bottom subplot: Analytical displacement
subplot(2,1,2);
hold on;
for i = 1:length(times_sec)
    plot(xgrid, u_analytical(:,i), '--s', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
xlabel('x (m)');
ylabel('Displacement u(x,t) [m]');
title('Analytical Displacement Field');
legend('Location','southwest');
grid on;


%% Residual Plot (Numerical vs Analytical)
figure('Name','Mass Conservation Residuals (Numerical vs Analytical)');
set(gcf,'Color','white');

% Top subplot: Numerical residual
subplot(2,1,1);
hold on;
for i = 2:length(times_sec)
    plot(xgrid(2:end-1), residual(2:end-1,i), '-o', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
title('Numerical Mass Conservation Residual');
xlabel('x (m)');
ylabel('Residual [1/s]');
legend('Location','northeast');
grid on;

% Bottom subplot: Analytical residual
subplot(2,1,2);
hold on;
for i = 2:length(times_sec)
    plot(xgrid(2:end-1), residual_analytical(2:end-1,i), '--s', 'DisplayName', [num2str(times_hr(i)) ' hr']);
end
title('Analytical Mass Conservation Residual');
xlabel('x (m)');
ylabel('Residual [1/s]');
legend('Location','northeast');
grid on;


%% Print relative L2 errors
fprintf('\nRelative L2 Errors (Numerical vs Analytical):\n');
fprintf('|     Time [hr]    | Pressure Error | Darcy Flux Error | Strain Error | Displacement Error | Residual Error |\n');
fprintf('|------------------|----------------|------------------|--------------|--------------------|----------------|\n');

for i = 1:length(times_hr)
    % L2 error for pressure
    rel_err_p = norm(p_numerical(:,i) - p_analytical(:,i)) / norm(p_analytical(:,i));

    % L2 error for flux
    rel_err_q = norm(q_numerical(:,i) - q_analytical(:,i)) / norm(q_analytical(:,i));

    % L2 error for strain
    rel_err_e = norm(e_numerical(:,i) - e_analytical(:,i)) / norm(e_analytical(:,i));

    % L2 error for displacement
    rel_err_u = norm(u_numerical(:,i) - u_analytical(:,i)) / norm(u_analytical(:,i));

    % L2 error for mass conservation residual
    if i == 1
        rel_err_r = NaN;  % Not defined for first time step
    else
        rel_err_r = norm(residual(:,i) - residual_analytical(:,i)) / norm(residual_analytical(:,i));
    end

    % Print in formatted row
    if i == 1
        fprintf('| %16.2f | %14.6e | %16.6e | %12.6e | %18.6e | %14s |\n', ...
            times_hr(i), rel_err_p, rel_err_q, rel_err_e, rel_err_u, 'N/A');
    else
        fprintf('| %16.2f | %14.6e | %16.6e | %12.6e | %18.6e | %14.6e |\n', ...
            times_hr(i), rel_err_p, rel_err_q, rel_err_e, rel_err_u, rel_err_r);
    end
end

%% Cumulative Surface Plots 
% Prepare time matrix for plotting
[X, T] = meshgrid(xgrid, times_sec / 3600);  % Time in hours

% 1. Pressure surface plot
figure('Name','Pressure Evolution Surface');
surf(X, T, p_numerical');  % p_numerical': size (space x time)
xlabel('x (m)');
ylabel('Time (hr)');
zlabel('Pressure p(x,t) [Pa]');
title('Pore Pressure Evolution');
shading interp; view(135, 30); colorbar;

% 2. Displacement surface plot
figure('Name','Displacement Evolution Surface');
surf(X, T, u_numerical');
xlabel('x (m)');
ylabel('Time (hr)');
zlabel('Displacement u(x,t) [m]');
title('Displacement Evolution');
shading interp; view(135, 30); colorbar;

% 3. Mass balance residual surface plot (excluding ghost nodes)
x_interior = xgrid(2:end-1);  % length 50
[Xr, Tr] = meshgrid(x_interior, times_sec / 3600);  % size: (4 × 50)

% Plot residual surface
figure('Name','Mass Conservation Residual Surface');
surf(Xr, Tr, residual(2:end-1,:)');
xlabel('x (m)');
ylabel('Time (hr)');
zlabel('Residual [1/s]');
title('Mass Conservation Residual Over Time');
shading interp; view(135, 30); colorbar;



