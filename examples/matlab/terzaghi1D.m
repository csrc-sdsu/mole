% Numerical solution of Terzaghi's 1D consolidation equation using MOLE
clc;
close all;

addpath('../../src/matlab');  % Update this path to your MOLE operators

% Parameters
P0 = 1;           % Initial pressure amplitude
cf = 0.01;        % Consolidation (diffusion) constant
L = 1.0;          % Domain length
m = 50;           % Number of cells
k = 2;            % Order of accuracy
a = 0; b = L;     % Domain boundaries
dx = (b - a)/m;   % Step size

% Time parameters
TIME = 0.5;                % Final time
dt = 0.03;                % Time step (you can match CFL)
nsteps = round(TIME / dt); % Number of time steps

% Fluid and medium properties
K = 1e-12;       % Permeability [m^2]
mu = 1e-3;       % Dynamic viscosity [Pa·s]
rho = 1000;      % Fluid density [kg/m^3]
g = 9.81;        % Gravity [m/s^2]

% Spatial grid (staggered)
xgrid = [a a+dx/2 : dx : b-dx/2 b];  % m+2 points (same as analytical)

% Initialize pressure
p = P0 * sin(pi * xgrid)';  % Initial condition

% MOLE Laplacian and gradient operators
L = lap(k, m, dx);          % Laplacian (size: m+1 x m+2)
G = grad(k, m, dx);         % Gradient (size: m+1 x m+2)

% Enforce Dirichlet BCs: zero pressure at boundaries
L(1,:) = 0;
L(end,:) = 0;

% Time integration using Forward Euler
for t = 0:dt:TIME
    % Update pressure
    p = p + dt * cf * (L * p);
    p(1) = 0;       % Dirichlet BC
    p(end) = 0;     % Dirichlet BC

    % Compute gradient of p using MOLE
    dpdx = G * p;

    % Compute Darcy flux
    q = - (K/mu) * (dpdx - rho*g);

    % Plot p
    subplot(2,1,1);
    plot(xgrid, p, '-o');
    title(['Pressure p(x,t) at t = ' num2str(t, '%.2f')]);
    xlabel('x'); ylabel('p(x,t)');
    axis([0 1 -0.2 1.2]); grid on;

    % Plot q
    x_flux = linspace(a + dx/2, b - dx/2, m+1);  % Same as in analytical
    subplot(2,1,2);
    plot(x_flux, q, '-s');
    title(['Darcy flux q(x,t) at t = ' num2str(t, '%.2f')]);
    xlabel('x'); ylabel('q(x,t)');
    grid on;

    drawnow
end

% for comparing with benchmark
p_numerical = p;

% Print final pressure value
fprintf('\nFinal pressure p(x,t=%.2f):\n', t);
disp(p');

% Print final Darcy flux value
fprintf('\nFinal Darcy flux q(x,t=%.2f):\n', t);
disp(q');
