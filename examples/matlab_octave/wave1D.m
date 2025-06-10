% Solves the 1D Wave equation with MDM and position Verlet algorithm

clc
close all

addpath('../../src/matlab_octave')

% Spatial discretization
k = 2;         % Order of accuracy (spatial)
m = 50;        % Number of cells
a = 0;         % Left boundary
b = 1;         % Right boundary
dx = (b-a)/m;  % Step length

verlet = 1;    % If verlet = 0 then it uses 4th order accurate for time (FR)

% 1D Staggered grid
xgrid = [a a+dx/2 : dx : b-dx/2 b];

% Mimetic operator (Laplacian)
L = lap(k, m, dx);

% Wave propagation speed
c = 2;  % (T/p) Tension over density

% "Force" function
F = @(x) (c^2)*L*x;  % c^2 DivGrad x

% Simulation time
TIME = 1;

% Temporal discretization based on CFL condition
dt = dx/(2*c); % dt = h on Young's paper

% Initial condition
ICU = @(x) sin(pi*x);      % Initial position of particles
ICV = @(x) zeros(m+1, 1);  % Initial velocity of particles

uold = ICU(xgrid');
vold = ICV(xgrid);
vold = [vold; vold(end)];

theta = 1/(2-2^(1/3)); % From Peter Young's paper

% Time integration loop
for t = 0 : TIME/dt
    % Apply "position Verlet" algorithm (2nd-order in time)----------------
    if verlet
        uold = uold + 0.5*dt*vold;
        vnew = vold + dt*F(uold);
        unew = uold + 0.5*dt*vnew;
    % Apply "Forest-Ruth" algorithm (4th-order in time)--------------------
    else
        unew = uold + theta*0.5*dt*vold;
        vnew = vold + theta*dt*F(unew);
        unew = unew + (1-theta)*0.5*dt*vnew;
        vnew = vnew + (1-2*theta)*dt*F(unew);
        unew = unew + (1-theta)*0.5*dt*vnew;
        vnew = vnew + theta*dt*F(unew);
        unew = unew + theta*0.5*dt*vnew;
    end
    
    uold = unew;
    vold = vnew;
    
    drawnow
    
    % Plot results
    plot(xgrid, unew, '-o')
    title(['1D Wave equation t = ' num2str(dt*t)])
    xlabel('x')
    ylabel('u(x)')
    axis([0 1 -1.5 1.5])  % If initial condition changes, then change this line too
    grid on
end
