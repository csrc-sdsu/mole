% Benchmark for Terzaghi's 1D equation
%clc
%close all

% Parameters
P0 = 1;         % Initial pressure amplitude
cf = 0.01;      % Decay/diffusion constant
L = 1;          % Domain length
N_max = 100;    % Number of terms in Fourier series

% Spatial discretization
k = 2;                 % Order of accuracy (not used here, for consistency)
m = 50;                % Number of cells
a = 0; b = 1;          % Domain boundaries
dx = (b-a)/m;          % Step size
xgrid = [a a+dx/2 : dx : b-dx/2 b];  % Staggered grid

% Time parameters
TIME = 0.5;            % Final time
dt = 0.002;            % Time step (you can match CFL if needed)
t_vals = 0:dt:TIME;    % Time loop

% Fluid and medium properties
K = 1e-12;       % Permeability [m^2]
mu = 1e-3;       % Dynamic viscosity [Pa·s]
rho = 1000;      % Fluid density [kg/m^3]
g = 9.81;        % Gravity [m/s^2]

% Loop over time
for t = t_vals
    
    %compute analytical p(x,t)
    p = zeros(size(xgrid));
    for N = 0:N_max
        n = 2*N + 1;
        term = (1/n) * sin(n*pi*xgrid/(2*L)) .* exp(-(n^2)*(pi^2)*cf*t/(4*L^2));
        p = p + term;
    end
    p = (4/pi) * P0 * p;

   % Compute gradient of p (finite difference)
    dpdx = gradient(p, dx);

    % Compute Darcy flux q
    q = - (K/mu) * (dpdx - rho*g);

    % Plot p
    subplot(2,1,1);
    plot(xgrid, p, '-o')
    title(['Pressure p(x,t) at t = ' num2str(t, '%.2f')])
    xlabel('x'); ylabel('p(x,t)');
    axis([0 1 -0.2 1.2]); grid on;

    % Plot q
    subplot(2,1,2);
    plot(xgrid, q, '-s')
    title(['Darcy flux q(x,t) at t = ' num2str(t, '%.2f')])
    xlabel('x'); ylabel('q(x,t)');
    grid on;

    drawnow
end

%for comparing with benchmark
p_analytical = p;


%print the final pressure value
fprintf('\nFinal pressure p(x,t=%.2f):\n', t);
disp(p');

%print the final Darcy flux value
fprintf('\nFinal Darcy flux q(x,t=%.2f):\n', t);
disp(q');
