 % ================================================== 
 % 2D Parabolic BVP: Dirchlet, Dirichlet
 % u_t = a(u_xx + u_yy), 0 < x,y < 2, t > 0, a = 0.1 
 % IC: u(x,y,0) = 2 in square [1,1.5] x [1,1.5], else 0
 % BC: Dirichlet (u = 0) on all boundaries
 % Exact solution: unknown 
 % Based on the following code implemented with the finite difference method:
 % https://www.mathworks.com/matlabcentral/fileexchange/38088-diffusion-in-1d-and-2d
 % =================================================== 

clc
close all

% Add paths to lap2D and addScalarBC2D in the src/matlab_octave
addpath('../../src/matlab_octave')

% Parameters
method = "implicit";

alpha = 0.1;                      % Diffusion coefficient/viscocity

k = 2;                            % Order of accuracy

nx = 40;                          % Number of steps in space (x)
ny = 50;                          % Number of steps in space (y)       

dx = 2/nx;                        % Width of space step (x)

dy = 2/ny;                        % Width of space step (y)

x = 0: dx :2;
y = 0: dy :2;

t = 3;                            % Number of time steps

if method == "explicit"
    dt = 0.001;                   % Width of each time step (explicit)
else
    dt = 0.01;                    % Width of each time step (implicit)
end

U = zeros(nx+2, ny+2);             % Preallocating u

xgrid = [0 dx/2: dx :2-dx/2 2];
ygrid = [0 dy/2: dy :2-dy/2 2];

% Initial Conditions: u(x, y, 0) = 2 
for i = 1:nx
    for j = 1:ny
        if ((1 <= y(j)) && (y(j) <= 1.5) && (1 <= x(i)) && (x(i) <= 1.5))
            U(i,j) = 2;
        end
    end
end

% set boundary conditions
dc = [1; 1; 1; 1];
nc = [0; 0; 0; 0];

bcl = zeros(ny, 1);
bcr = zeros(ny, 1);
bct = zeros(nx+2, 1);
bcb = zeros(nx+2, 1);

v = {bcl; bcr; bcb; bct};

U = reshape(U, [], 1);

L = lap2D(k, nx, dx, ny, dy);

[L,U] = addScalarBC2D(L, U, k, nx, dx, ny, dy, dc, nc, v);

U = reshape(U, nx+2, ny+2);

 switch method
    case "explicit"
        L = alpha*dt*L + speye(size(L));   
    case "implicit"
        L = speye(size(L)) - alpha*dt*L;
 end

for it = 0 : t/dt 
    surf(xgrid, ygrid, U')
    shading interp
    axis ([0 2 0 2 0 2])
    title({[method];['2-D Diffusion with {\nu} = ',num2str(alpha)];['time (\itt) = ',num2str(it*dt)]})
    xlabel('x')
    ylabel('y')
    zlabel('u')
    drawnow; 

    U = reshape(U, [], 1);

    switch method
        case "explicit"
            U = L*U;  
        case "implicit"
            U = L\U; 
    end
    
    U = reshape(U, nx+2, ny+2);

end
