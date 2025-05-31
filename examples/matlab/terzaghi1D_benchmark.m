% Benchmark for Terzaghi's 1D equation
clc;
close all;

% Parameters
P0 = 10e6;         % Face load in Pascals
cf = 1e-4;         % Diffusion constant
L = 25;            % Domain length in meters
N_max = 100;       % Fourier terms

% Spatial discretization
m = 50;
a = 0; b = L;
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

% Store results
p_all = zeros(length(xgrid), length(times_sec));
q_all = zeros(length(xgrid), length(times_sec));  % Will truncate later

% Plot pressure
figure(1);
hold on;
for i = 1:length(times_sec)
    t = times_sec(i);

    % Analytical pressure solution
    p = zeros(size(xgrid));
    for N = 0:N_max
        n = 2*N + 1;
        term = (1/n) * sin(n*pi*xgrid/(2*L)) .* exp(-(n^2)*(pi^2)*cf*t/(4*L^2));
        p = p + term;
    end
    p = (4/pi) * P0 * p;
    p_all(:,i) = p;

    semilogy(xgrid, p/1e6, '-o', 'DisplayName', ['t = ' num2str(times_hr(i)) ' hr']);
end
title('Pressure p(x,t) at various times');
xlabel('x (m)');
ylabel('Excess Pore Pressure p(x,t) [MPa]');
legend('Location', 'southeast');
grid on;

% Plot Darcy flux
figure(2);
hold on;
x_flux = linspace(a + dx/2, b - dx/2, m+1);
for i = 1:length(times_sec)
    p = p_all(:,i);
    dpdx = gradient(p, dx);
    q = - (K / mu) * (dpdx - rho * g);
    q_all(1:m+1,i) = q(1:m+1);  % avoid including ghost point
    semilogy(x_flux, q(1:m+1), '-s', 'DisplayName', ['t = ' num2str(times_hr(i)) ' hr']);
end
title('Darcy Flux q(x,t) at various times');
xlabel('x (m)');
ylabel('q(x,t) [m/s]');
legend('Location', 'southeast');
grid on;

% Print results
for i = 1:length(times_hr)
    fprintf('\nFinal pressure p(x,t = %.2f hr):\n', times_hr(i));
    disp(p_all(:,i)');
    fprintf('Final Darcy flux q(x,t = %.2f hr):\n', times_hr(i));
    disp(q_all(1:m+1,i)');
end
