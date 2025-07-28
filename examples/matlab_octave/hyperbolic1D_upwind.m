% Solves the scalar advection equation with periodic boundary conditions
% and upwind scheme. First-order in space and time.

clc
close all

addpath('../../src/matlab_octave')

a = 1; % Velocity
west = 0; % Domain's limits
east = 1;

m = 20; % Number of cells
dx = (east-west)/m;

t = 1; % Simulation time
dt = dx/abs(a); % CFL condition for explicit schemes

S = sidedNodal(m, dx, 'backward'); % Use 'forward' if a < 0
% Line 19 can be rewritten in compact form, where based on the sign
% of (a) either forward or backward differencing is used.

% 1D nodal grid
grid = west : dx : east;

% IC
U = sin(2*pi*grid)';

% Premultiply out of the time loop (since it doesn't change)
S = speye(size(S))-a*dt*S;

% Time integration loop
for i = 1 : t/dt
    
    U = S*U; % Compute U^(n+1)
    
    plot(grid, U, 'o-') % Plot approximation
    hold on
    plot(grid, sin(2*pi*(grid - a*i*dt))) % Plot exact solution
    hold off
    str = sprintf('t = %.2f', i*dt);
    title(str)
    xlabel('x')
    ylabel('u(x, t)')
    axis([west east -1.5 1.5])
    pause(0.04)
end
