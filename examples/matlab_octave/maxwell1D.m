% Solution to 1D Maxwell's equations using mimetic operators and leapfrog
clear; clc; close all;

addpath('../../src/matlab_octave');

nt = 150;         % number of time steps
m = 100;          % number of cells
east = 1;         % domain's limits
west = 0;
dx = (east - west)/m;
dt = 0.5*dx;      % time step based on CFL

% Grids
xE = [west west+dx/2 : dx : east-dx/2 east];
xB = west : dx : east;

% Mimetic operators
k = 2; % Order of accuracy
D = dt*div(k, m, dx);
G = dt*grad(k, m, dx);

% Initialize magnetic field
B = zeros(m+1, 1);

% Initial condition: Gaussian pulse in E
E = exp(-100*(xE-0.5).^2).';

% Leapfrog: stagger B by half step
B = B - 0.5*G*E;  % half-step backward for leapfrog start

figure;

% Time-stepping
for n = 1:nt
    % Update B (edges)
    B = B - G*E;

    % Store bdry values
    El = E(2);
    Er = E(end-1);
    
    % Update E (centers)
    E = E - D*B;

    % Absorbing boundary condition
    E(1)   = El;    % left boundary
    E(end) = Er;    % right boundary
    
    % Plot E field (subplot 1)
    subplot(2, 1, 1);
    plot(xE, E, 'b-', 'LineWidth', 2);
    title('Electric Field');
    xlabel('x');
    ylabel('E(x,t)');
    xlim([0 1]);
    ylim([-1 1]);
    grid on;

    % Plot B field (subplot 2)
    subplot(2, 1, 2);
    plot(xB, B, 'r-', 'LineWidth', 2);
    title('Magnetic Field');
    xlabel('x');
    ylabel('B(x,t)');
    xlim([0 1]);
    ylim([-1 1]);
    grid on;

    pause(0.01)
end
