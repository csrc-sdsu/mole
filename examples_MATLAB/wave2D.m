% Solves the 2D Wave equation with MDM and position Verlet algorithm

clc
close all

addpath('../mole_MATLAB')

% Spatial discretization
k = 2;  % Order of accuracy
m = 50;  % Number of cells along the x-axis
n = m;  % Number of cells along the y-axis
a = 0;  % West
b = 1;  % East
c = 0;  % South
d = 1;  % North
dx = (b-a)/m;  % Step length along the x-axis
dy = (d-c)/n;  % Step length along the y-axis

% 2D Staggered grid
xgrid = [a a+dx/2 : dx : b-dx/2 b];
ygrid = [c c+dy/2 : dy : d-dy/2 d];

[X, Y] = meshgrid(xgrid, ygrid);

% Mimetic operator (Laplacian)
L = lap2D(k, m, dx, n, dy);
L = L + robinBC2D(k, m, dx, n, dy, 1, 0); % Dirichlet BC
I = interpol2D(m, n, 0.5, 0.5);
I2 = interpolD2D(m, n, 0.5, 0.5);

% Wave propagation speed
c = 1;  % (T/p) Tension over density

% "Force" function
F = @(x, c) (c^2)*L*x;

% Simulation time
TIME = 1;

% Temporal discretization based on CFL condition
dt = dx/(2*c); % dt = h on Young's paper

% Initial condition
ICU = @(x, y) sin(pi.*x).*sin(pi.*y);
uold = ICU(X, Y);
ICV = @(x, y) zeros(2*m*n+m+n, 1);
vold = ICV(X, Y);

uold = reshape(uold, (m+2)*(n+2), 1);

theta = 1/(2-2^(1/3)); % From Peter Young's paper

% Premultiply I and I2
I = dt*I;
I2 = 0.5*dt*I2;

%v = VideoWriter('membrane2D_Corbino.avi', 'Uncompressed AVI');
%v.FrameRate = 20;
%open(v);

% Time loop
for t = 0 : TIME/dt
    % Apply "position Verlet" algorithm -----------------------------------
    uold = uold + I2*vold;
    vnew = vold + I*F(uold, c);
    unew = uold + I2*vnew;
    
    % Update
    uold = unew;
    vold = vnew;
    
    % Plot result
    mesh(X, Y, reshape(unew, m+2, n+2))
    title(['Elastic membrane with position Verlet \newlineTime = ' num2str(dt*t, '%1.2f')])
    xlabel('x')
    ylabel('y')
    colorbar
    caxis([-1, 1])
    axis([0 1 0 1 -1 1])
    drawnow
    
    %M(t+1) = getframe(gcf);
end

%writeVideo(v, M)
%close(v)
