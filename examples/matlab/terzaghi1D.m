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
% -------------------------------------------------------------------------

%%
clc;
close all;

addpath('../../src/matlab');  % MOLE operator path

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

%% Numerical (MOLE) Solution
L = lap(k, m, dx);       % Mimetic Laplacian operator for diffusion
G = grad(k, m, dx);      % Mimetic gradient operator for Darcy flux

% Boundary modifications to Laplacian
L(1,:) = 0; L(end,:) = 0;

p_numerical = zeros(length(xgrid), length(times_sec)); % Pressure field [Pa]
q_numerical = zeros(m+1, length(times_sec));  % Darcy flux [m/s] (size = m+1)

% Loop over each specified final time
for i = 1:length(times_sec)
    t_final = times_sec(i);
    dt = 0.03;
    nsteps = round(t_final / dt);

    % Uniform Initial Condition : p(x,0) = P0
    p = P0 * ones(size(xgrid))';

    % Time integration using Forward Euler
    for step = 1:nsteps
        p = p + dt * cf * (L * p);
        p(1) = 0;             % Dirichlet BC at x = 0
        p(end) = p(end-1);    % Neumann BC at x = L
    end

    p_numerical(:,i) = p;

    % Compute Darcy flux (numerical)
    dpdx = G * p;
    q = - (K / mu) * (dpdx - rho * g);
    q_numerical(:,i) = q(1:m+1);  

    % Print numerical results
    fprintf('\nNumerical results at t = %.2f hr:\n', times_hr(i));
    fprintf('|     x (m)     | Numerical p [Pa] | Darcy Flux [m/s] |\n');
    fprintf('|---------------|------------------|------------------|\n');
    for j = 1:m+1
        fprintf('| %13.6f | %16.6e | %16.6e |\n', xgrid(j), p_numerical(j,i), q_numerical(j,i));
    end
end

%% Analytical Solution
N_max = 100; % Number of Fourier series terms
p_analytical = zeros(length(xgrid), length(times_sec)); % Pressure field [Pa]
q_analytical = zeros(m+1, length(times_sec));  % Darcy flux [m/s] (size = m+1)

% Loop over all time snapshots
for i = 1:length(times_sec)
    t = times_sec(i);
    p = zeros(size(xgrid));

     % Compute analytical solution using truncated Fourier sine series
    for N = 0:N_max
        n = 2*N + 1; % Odd terms only (satisfies boundary conditions)
        term = (1/n) * sin(n*pi*xgrid/(2*l)) .* exp(-(n^2)*(pi^2)*cf*t/(4*l^2));
        p = p + term;
    end
    p = (4/pi) * P0 * p;
    p_analytical(:,i) = p;

    % Compute Darcy flux (analytical)
    dpdx = gradient(p, dx);  % basic gradient
    q = - (K / mu) * (dpdx - rho * g);
    q_analytical(:,i) = q(1:m+1);

    % Print analytical results
    fprintf('\nAnalytical results at t = %.2f hr:\n', times_hr(i));
    fprintf('|     x (m)     | Analytical p [Pa] | Darcy Flux [m/s] |\n');
    fprintf('|---------------|-------------------|------------------|\n');
    for j = 1:m+1
        fprintf('| %13.6f | %18.6e | %16.6e |\n', xgrid(j), p_analytical(j,i), q_analytical(j,i));
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

%% Print relative L2 errors
fprintf('\nRelative L2 Errors (Numerical vs Analytical):\n');
fprintf('|     Time [hr]    |   Pressure Error   |   Darcy Flux Error |\n');
fprintf('|------------------|--------------------|---------------------|\n');
for i = 1:length(times_hr)
    % L2 error for pressure
    rel_err_p = norm(p_numerical(:,i) - p_analytical(:,i)) / norm(p_analytical(:,i));
    
    % L2 error for flux
    rel_err_q = norm(q_numerical(:,i) - q_analytical(:,i)) / norm(q_analytical(:,i));
    
    % Print in table format
    fprintf('| %16.2f | %18.6e | %19.6e |\n', times_hr(i), rel_err_p, rel_err_q);
end
