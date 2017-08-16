% Solves the 2D Wave equation with MDM and position Verlet algorithm

clc
close all

addpath('../mole_MATLAB')

% Spatial discretization
k = 2;
m = 50;
n = m;
a = 0;
b = 1;
c = 0;
d = 1;
dx = (b-a)/m;
dy = (d-c)/n;

% 2D Staggered grid
xgrid = [a a+dx/2 : dx : b-dx/2 b];
ygrid = [c c+dy/2 : dy : d-dy/2 d];

[X, Y] = meshgrid(xgrid, ygrid);

% Mimetic operator (Laplacian)
L = lap2D(k, m, dx, n, dy);
L = L + robinBC2D(k, m, dx, n, dy, 1, 0);
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

%v = VideoWriter('membrane2D_Corbino.avi', 'Uncompressed AVI');
%v.FrameRate = 20;
%open(v);

% Time integration loop
for t = 0 : TIME/dt
    % Apply "position Verlet" algorithm -----------------------------------
    uold = uold + 0.5*dt*I2*vold;
    vnew = vold + dt*I*F(uold, c);
    unew = uold + 0.5*dt*I2*vnew;
    
    % Update
    uold = unew;
    vold = vnew;
    
    % Plot results
    mesh(X, Y, reshape(unew, m+2, n+2))
    title(['Elastic membrane with position Verlet \newlineTime = ' num2str(dt*t)])
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
