% -------------------------------------------------------------------------
% mendel2D: Poro-Thermoelastic Coupled Simulation using MOLE Operators
%
% 2D numerical simulation of poro-thermoelastic behavior using mimetic
% operators (grad2D, div2D) on a rectangular domain [-a,a] x [-b,b].
%
% Governing Equations:
% - Cauchy Momentum Balance with thermal stress
% - Darcy Flow Equation
% - Coupled mass balance with thermal expansion
%
% Boundary Conditions:
% - x = ±a: p = 0, sigma_xx = sigma_xz = 0
% - y = ±b: sigma_zx = 0, uz = const, integral sigma_zz = -2F
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2025 San Diego State University Research Foundation (SDSURF).
% ----------------------------------------------------------------------------

clc; clear; close all;
addpath('../../src/matlab');  % Path to MOLE operators

%% Parameters
% Domain
a = 1;          % Half-width in x [m]
b = 1;          % Half-height in y [m]
m = 40;         % Cells in x
n = 40;         % Cells in y
k = 2;          % MOLE operator order

dx = 2*a / m;
dy = 2*b / n;

% Grid
x = linspace(-a, a, m+2); % Includes ghost nodes
y = linspace(-b, b, n+2);
[X, Y] = meshgrid(x, y);

%% Physical Properties
K = 1e-12;        % Permeability [m^2]
mu = 1e-3;        % Dynamic viscosity [Pa.s]
rho = 1000;       % Fluid density [kg/m^3]
g = 9.81;         % Gravity [m/s^2]
Kb = 1e8;         % Bulk modulus [Pa]
alpha = 1.0;      % Biot coefficient
Ss = 1e-5;        % Specific storage [1/Pa]
alpha_T = 1e-4;   % Thermal expansion coeff [1/K]
beta_T = 1e-6;    % Thermal flow coupling
T0 = 293;         % Reference temperature [K]
T = T0 * ones((m+2)*(n+2),1);  % Uniform temp field for now

%% Operators
% Boundary types: Dirichlet on p at x=+-a; traction elsewhere
% dc = [left, right, bottom, top]; all Dirichlet for now
bc_dir = [1;1;1;1];
bc_neu = [0;0;0;0];

G = grad2D(k, m, dx, n, dy, bc_dir, bc_neu);     % Gradient operator
D = div2D(k, m, dx, n, dy, bc_dir, bc_neu);      % Divergence operator

%% Time Setup
final_time = 3600;    % 1 hour in seconds
dt = 1.0;             % Time step [s]
nsteps = round(final_time / dt);
time_out = [600, 1800, 3600];  % Output times [s]
out_idx = 1;

%% Initial Conditions
p = zeros((m+2)*(n+2), 1);     % Initial pressure [Pa]
u = zeros(2*(m+2)*(n+2), 1);   % Initial displacement (ux; uy)

%% Time Loop
for step = 1:nsteps
    t = step * dt;

    % -- Compute total stress source term
    Tdiff = T - T0;
    thermal_term = 3 * Kb * alpha_T * Tdiff;
    sigma_source = - (alpha * p + thermal_term);

    % -- Mechanical solve (placeholder: assume zero acceleration)
    % Here, you would solve: div(sigma') + rho g = 0
    % (To be implemented: finite element or linear solve for displacement)
    % Ensure p is a column vector
    p = reshape(p, [], 1);

          
    % -- Darcy flux: q = -(K/mu)*(grad(p) - rho*g)
    %grav_vector = repmat([0; -rho*g], (m+2)*(n+2), 1);
    dp = G * p;
    grav_vector = zeros(size(dp));
    grav_vector(2:2:end) = -rho * g;  % Apply gravity only in y-direction
    q = - (K / mu) * (dp - grav_vector);

    % -- Mass balance: Ss*dp/dt + alpha*de/dt - beta_T*dT/dt - div(q) = 0
    dq = D * q;
    dpdt = -dq / Ss;   % Simplified (no thermal or strain coupling yet)
    p = p + dt * dpdt;

    % Apply Dirichlet BC on pressure (p = 0 at x = ±a)
    for i = 1:m+2
        for j = [1, n+2]  % bottom and top rows
            idx = sub2ind([n+2, m+2], j, i);
            p(idx) = 0;
        end
    end

    % Output snapshot
    if out_idx <= length(time_out) && abs(t - time_out(out_idx)) < dt/2
        fprintf('t = %g s\n', t);
        p_field = reshape(p, n+2, m+2);
        figure;
        surf(x, y, p_field);
        title(['Pressure at t = ' num2str(t/60) ' min']);
        xlabel('x [m]'); ylabel('y [m]'); zlabel('p [Pa]');
        shading interp; colorbar; view(140, 30);
        out_idx = out_idx + 1;
    end
end

fprintf('\nSimulation complete.\n');