% Terzaghi 1D: using MOLE operators
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
a = 0; 
b = l;
dx = (b - a)/m;
xgrid = [a a+dx/2 : dx : b-dx/2 b];  % Staggered grid

% Times to evaluate (in hours)
times_hr = [1, 10, 40, 70];
times_sec = times_hr * 3600;

% Fluid properties
K = 1e-12;        % Permeability [m^2]
mu = 1e-3;        % Dynamic viscosity [Pa·s]
rho = 1000;       % Fluid density [kg/m^3]
g = 9.81;         % Gravity [m/s^2]

%% Numerical (MOLE) Solution
L = lap(k, m, dx);
G = grad(k, m, dx);
L(1,:) = 0; L(end,:) = 0;

p_numerical = zeros(length(xgrid), length(times_sec));
for i = 1:length(times_sec)
    t_final = times_sec(i);
    dt = 0.03;
    nsteps = round(t_final / dt);

    % Uniform Initial Condition
    p = P0 * ones(size(xgrid))';

    for step = 1:nsteps
        p = p + dt * cf * (L * p);
        p(1) = 0;             % Dirichlet BC
        p(end) = p(end-1);    % Neumann BC
    end

    p_numerical(:,i) = p;
end

%% Analytical Solution
N_max = 100;
p_analytical = zeros(length(xgrid), length(times_sec));
for i = 1:length(times_sec)
    t = times_sec(i);
    p = zeros(size(xgrid));
    for N = 0:N_max
        n = 2*N + 1;
        term = (1/n) * sin(n*pi*xgrid/(2*l)) .* exp(-(n^2)*(pi^2)*cf*t/(4*l^2));
        p = p + term;
    end
    p_analytical(:,i) = (4/pi) * P0 * p;
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
for i = 1:length(times_hr)
    rel_err = norm(p_numerical(:,i) - p_analytical(:,i)) / norm(p_analytical(:,i));
    fprintf('t = %.2f hr: %.6e\n', times_hr(i), rel_err);
end
