% Solves the 1D Inviscid Burgers' equation
% Initial Condition: exp(-x^2/50)

clc
close all

addpath('../mole_MATLAB')

west = -15; % Domain's limits
east = 15;

k = 2; % Operator's order of accuracy
m = 300; % Number of cells
dx = (east-west)/m;

t = 5; % Simulation time
dt = dx; % CFL condition for explicit schemes

D = div(k, m, dx); % 1D Mimetic divergence operator
I = interpol(m, 0.5); % 1D 2nd order interpolator

% 1D Staggered grid
xgrid = [west west+dx/2: dx :east-dx/2 east];

% Impose IC
U = exp(-(xgrid.^2)/50)';

% Premultiply out of the time loop (since it doesn't change)
D = -dt*D*I;

% Time integration loop
for i = 0 : t/dt
    
    trapz(U) % Check for area conservation
    
    plot(xgrid, U, 'LineWidth', 2)
    axis([west east 0.1 1.1])
    str = sprintf('t = %.2f', i*dt);
    title(str)
    xlabel('x')
    ylabel('u(x)')
    grid on
    drawnow
    
    U2 = U + U.*D*U; % Euler's scheme
    U = U2;
end
