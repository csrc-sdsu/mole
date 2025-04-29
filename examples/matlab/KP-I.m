clear;
clc;

% path to mimetic operators
addpath('C:\Users\littl\sdsu\comp670\calderonTE-master\calderonTE\src\matlab');

% Parameters
k = 2;          % Order of accuracy
m = 99;          % Number of cells along x-axis
n = m;          % Number of cells along y-axis

a = 1;          % Used for solution
b = 0.5;        % Used for solution

% Spatial Discretization
x_1 = -10;      
x_2 = 10;
y_1 = -10;
y_2 = 10;
dx = (x_2 - x_1) / m;
dy = (y_2 - y_1) / n;
dt = dx;

% Staggered grid
xgrid = [x_1, x_1+dx/2:dx:x_2-dx/2, x_2];
ygrid = [y_1, y_1+dy/2:dy:y_2-dy/2, y_2];

num_steps = 1;
tgrid = 0:dt:(num_steps * dt);

% Mesh-grid implementation
[Y, X, T] = meshgrid(ygrid, xgrid, tgrid);

% Interpolation operators
I = interpolCentersToFacesD2D(k,m,n);
Ix = I(1:(n+2)*(m+2), 1:n*(m+1));
Iy = I((n+2)*(m+2)+1:end, n*(m+1)+1:end);


% Mimetic operators
G = grad2D(k, m, dx, n, dy);
Gx = G(1:end/2, :); % Gradient in x-direction (size: (m+1) x (m+2))
Gy = G(end/2+1:end,:); % Gradient in y-direction

D = div2D(k, m, dx, n, dy);
Dx = D(:, 1:end/2); % Divergence in x-direction
Dy = D(:,end/2+1:end); % Divergence in y-direction


Lyy = Dy*Gy;
Lxx = Dx*Gx;
Lxxxx = Lxx*Lxx;
Lx = Ix*Gx;

% Initial condition
num = - (X + a*Y + 3*T*(a^2 - b^2)).^2 + b^2*(Y + 6*a*T).^2 + (1/b^2);
den = ( (X + a*Y + 3*T*(a^2 - b^2)).^2 + b^2*(Y + 6*a*T).^2 + (1/b^2) ).^2;
u0 = 4 * num ./ den; %exact solution

u = u0(:,:,1);            
u = reshape(u,[],1);     % Vectorize [49x1]

% Boundary conditions (Dirichlet: u=0 at all boundaries)
dc = [1; 1; 1; 1];     % Dirichlet flags
nc = [0; 0; 0; 0];     % Neumann flags

v = cell(4,1);
v{1} = zeros(n,1);     % Left BC
v{2} = zeros(n,1);     % Right BC
v{3} = zeros(m+2,1);   % Bottom BC
v{4} = zeros(m+2,1);   % Top BC

% Time-stepping
for t = 1:num_steps

    u_at_faces = Ix.' * u;
    M1 = Ix * diag(u_at_faces) * Gx;
    
    % Build system matrix
    A = Lx - dt*(6*M1 + Lxxxx - 3*Lyy);
    b = u + dt*(6*M1 + Lxxxx - 3*Lyy)*u;
    
    % Apply boundary conditions
    [A0, b0] = addBC2D(A, b, k, m, dx, n, dy, dc, nc, v);
    
    % Solve
    u = A0 \ b0;
    
    u_2d = reshape(u, m+2, n+2);

 
    if t <= size(X,3)
        surf(X(:,:,t), Y(:,:,t), u_2d);
        title(['KP-I Solution at t = ', num2str(t)]);
        xlabel('x'); ylabel('y'); zlabel('u');
        colorbar;
        drawnow;
    end
end