% 2D Time-dependent Schrödinger's equation solved with Mimetic Methods
clc
close all

addpath('../../src/matlab_octave')

% Parameters
Lxy = 1;              % Length of box in x and y
k = 2;                % Order of accuracy
m = 50;               % Grid points in x
n = 50;               % Grid points in y
nx = 2;               % Energy level in x
ny = 2;               % Energy level in y
kx = @(nx) nx*pi/Lxy; % Wave vector in x
ky = @(ny) ny*pi/Lxy; % Wave vector in y
dx = Lxy/m;           % Step in x
dy = Lxy/n;           % Step in y
dt = dx;              % Time step

% 2D Staggered grid
xgrid = [0 dx/2:dx:Lxy-dx/2 Lxy]; % Staggered grid x
ygrid = [0 dy/2:dy:Lxy-dy/2 Lxy]; % Staggered grid y

[X, Y] = meshgrid(xgrid, ygrid);  % Grid

% Mimetic Laplacian operator and interpolator
L = lap2D(k, m, dx, n, dy);
L = L + robinBC2D(k, m, dx, n, dy, 1, 0);
I = interpol2D(m, n, 0.5, 0.5);
I2 = interpolD2D(m, n, 0.5, 0.5);

% Premultiplying
I = dt*I;
I2 = 0.5*dt*I2;

% Hamiltonian
H = @(x) 0.5*L*x;

% Initialization
A = 2/Lxy;
psi_old = A*sin(kx(nx)*X).*sin(ky(ny)*Y);
psi_old = psi_old(:);
v_old = zeros(2*m*n+m+n, 1);

for i = 0:105
    % Position Verlet algorithm
    psi_old = psi_old + I2*v_old;
    v_new = v_old + I*H(psi_old);
    psi_new = psi_old + I2*v_new;
    Psi_re = reshape(psi_new, m+2, n+2);
    
    % Plotting
    surf(X, Y, reshape(psi_new, m+2, n+2))
    xlabel('x')
    ylabel('y')
    zlabel('\psi')
    zlim([-A A]);
    title(['n_x = ',num2str(nx),', n_y = ',num2str(ny),', t = ',num2str(i)]);
    drawnow
    
    % Updating
    psi_old = psi_new;
    v_old = v_new;
end
