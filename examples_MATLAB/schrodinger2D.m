% 2D Time-dependent Schrödinger's equation solved with Mimetic Methods
clc
close all

addpath('../mole_MATLAB')

% Parameters
Lxy = 1;              % Length of box in x and y
k = 2;                % Order of accuracy        
m = 50;               % Grid points in x     
n = 50;               % Grid points in y 
t = 1;                % Time
nx = 2;               % Energy level in x 
ny = 2;               % Energy level in y  
c = 1;                % Wave propagation speed
kx = @(nx) nx*pi/Lxy; % Wave vector in x
ky = @(ny) ny*pi/Lxy; % Wave vector in y
dx = Lxy / m;         % Step in x
dy = Lxy / n;         % Step in y
dt = dx/(2*c);        % Time step

% Spatial discretization
xGrid = [0 dx/2:dx:Lxy-dx/2 Lxy]; % Staggered grid x
yGrid = [0 dy/2:dy:Lxy-dy/2 Lxy]; % Staggered grid y 
[Y, X] = meshgrid(yGrid, xGrid);  % Grid

% Initial condition
A = 2/Lxy;
IC_Psi = @(x, y, nx, ny) A.*sin(kx(nx)*x).*sin(ky(ny)*y);
IC_v = @(x, y) zeros(2*m*n+m+n, 1);
vold = IC_v(X, Y);

% Mimetic Laplacian operator and interpolator
L = lap2D(k, m, dx, n, dy);
L = L + robinBC2D(k, m, dx, n, dy, 1, 0); 
I = interpol2D(m, n, 0.5, 0.5);
I2 = interpolD2D(m, n, 0.5, 0.5);

% Premultiplying for convenience 
I = dt*I; 
I2 = 0.5*dt*I2; 

% Hamiltonian function
H = @(x) 0.5*L*x;

% Initialization
Psi_old = IC_Psi(X, Y, nx, ny);
Psi_old = Psi_old(:);
v_old = IC_v(X, Y);

for i = 0:100
    
    % Position Verlet algorithm 
    Psi_old = Psi_old + I2*v_old; 
    v_new = v_old + I*H(Psi_old); 
    Psi_new = Psi_old + I2*v_new;
    Psi_re = reshape(Psi_new, m+2, n+2);
    
    % Plotting
    surf(X, Y, reshape(Psi_new, m+2, n+2))
    zlim([-A A]);
    xlabel('x')
    ylabel('y')
    zlabel('\psi')
    title(['nx = ',num2str(nx),', ny = ',num2str(ny),', t = ',num2str(i)]);
    drawnow
    
    % Updating
    Psi_old = Psi_new;
    v_old = v_new;
end
