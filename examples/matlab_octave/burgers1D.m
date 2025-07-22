% Solves the 1D Inviscid Burgers' equation.
% Upwind scheme is used and the equation is written in conservative form.
% Initial Condition: exp(-x^2/50)

clc
close all

addpath('../../src/matlab_octave')

west = -15; % Domain's limits
east = 15;

k = 2; % Operator's order of accuracy
m = 300; % Number of cells
dx = (east-west)/m;

t = 10; % Simulation time
dt = dx; % CFL condition for explicit schemes

D = div(k, m, dx); % 1D Mimetic divergence operator
I = interpol(m, 1); % 1D interpolator
% Use I = interpol(m, 0) (downwind) if the fluid propagates to the left

% 1D Staggered grid
xgrid = [west west+dx/2: dx :east-dx/2 east];

% Impose IC
U = exp(-(xgrid.^2)/50)';

% Premultiply out of the time loop (since it doesn't change)
D = -dt/2*D*I;

% Time integration loop
for i = 0 : t/dt
    
    trapz(U) % Check for area conservation
    
    plot(xgrid, U, 'LineWidth', 2)
    str = sprintf('t = %.2f', i*dt);
    title(str)
    xlabel('x')
    ylabel('u(x, t)')
    grid on
    drawnow
    
    U2 = U + D*U.^2;
    U = U2;
end
