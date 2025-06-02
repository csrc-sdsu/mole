% Numerical solution of Terzaghi's 1D consolidation equation using MOLE
clc;
close all;

addpath('../../src/matlab');  % Update this path to your MOLE operators

% Parameters
P0 = 10e6;         % Face load in Pascals
cf = 1e-4;         % Consolidation (diffusion) constant
L = 25;            % Domain length in meters
k = 2;             % Order of accuracy
m = 50;            % Number of cells
a = 0; b = L;
dx = (b - a)/m;
xgrid = [a a+dx/2 : dx : b-dx/2 b];  % Staggered grid

% Times to evaluate (in hours)
times_hr = [1, 10, 40, 70];
times_sec = times_hr * 3600;

% Fluid and medium properties
K = 1e-12;       % Permeability [m^2]
mu = 1e-3;       % Dynamic viscosity [Pa·s]
rho = 1000;      % Fluid density [kg/m^3]
g = 9.81;        % Gravity [m/s^2]

% MOLE operators
L = lap(k, m, dx);  % Laplacian
G = grad(k, m, dx);   % Gradient

% Enforce zero rows for boundary (to avoid Laplacian affecting boundary values)
L(1,:) = 0;
L(end,:) = 0;

% Store results
p_all = zeros(length(xgrid), length(times_sec));
q_all = zeros(length(xgrid), length(times_sec));

% Plot pressure
figure(1); hold on;
for i = 1:length(times_sec)
    t_final = times_sec(i);
    dt = 0.03;
    nsteps = round(t_final / dt);
    
    %Uniform Initial Condition
    p = P0 * ones(size(xgrid))';

    % Time stepping loop
    for step = 1:nsteps
        p = p + dt * cf * (L * p);
        % Boundary Conditions
        p(1) = 0;              % Dirichlet at x = 0
        p(end) = p(end-1);     % Neumann at x = L (zero gradient)
    end
    
    % Store final pressure
    p_all(:,i) = p;

    % Compute gradient and Darcy flux
    dpdx = G * p;
    q = - (K / mu) * (dpdx - rho * g);
    q_all(1:m+1,i) = q(1:m+1);  % Exclude ghost point

    % Plot pressure profile
    semilogy(xgrid, p/1e6, '-o', 'DisplayName', ['t = ' num2str(times_hr(i)) ' hr']);
end
title('Pressure p(x,t) at various times');
xlabel('x (m)');
ylabel('Excess Pore Pressure p(x,t) [MPa]');
legend('Location', 'southeast');
grid on;

% Plot Darcy flux
figure(2); hold on;
x_flux = linspace(a + dx/2, b - dx/2, m+1);
for i = 1:length(times_sec)
    q = q_all(1:m+1,i);
    semilogy(x_flux, q, '-s', 'DisplayName', ['t = ' num2str(times_hr(i)) ' hr']);
end
title('Darcy Flux q(x,t) at various times');
xlabel('x (m)');
ylabel('q(x,t) [m/s]');
legend('Location', 'southeast');
grid on;

% Print final values
for i = 1:length(times_hr)
    fprintf('\nFinal pressure p(x,t = %.2f hr):\n', times_hr(i));
    disp(p_all(:,i)');
    fprintf('Final Darcy flux q(x,t = %.2f hr):\n', times_hr(i));
    disp(q_all(1:m+1,i)');
end

% Save pressure for comparison
p_numerical = p_all;
