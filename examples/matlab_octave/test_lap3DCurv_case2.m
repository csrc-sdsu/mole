% Tests the 3D curvilinear laplacian
clear
clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;                   % Order of accuracy
m = 20;                  % Number of nodes along x-axis
n = 20;                  % Number of nodes along y-axis
o = 10;                  % Number of nodes along z-axis
dx = 1 / (m - 1);        % Step size along x-axis
dy = 1 / (n - 1);        % Step size along y-axis
dz = 1 / (o - 1);        % Step size along z-axis
dc = [1; 1; 1; 1; 1; 1]; % Dirichlet Coefficients
nc = [0; 0; 0; 0; 0; 0]; % Neumann Coefficients

a = -pi; % xlim(0)
b =  pi; % xlim(1)
c = -pi; % ylim(0)
d =  pi; % ylim(1)
e =  -1; % zlim(0)
f =   1; % zlim(1)
[X, Y, Z] = meshgrid(linspace(a, b, m), linspace(c, d, n), linspace(e, f, o));
X = X + sin(Y);

% Interpolate Nodes to Centers
INC = interpolNodesToCenters3D(k, m - 1, n - 1, o - 1, dc, nc);

xc = INC * reshape(permute(X, [2, 1, 3]), [], 1);
yc = INC * reshape(permute(Y, [2, 1, 3]), [], 1);
zc = INC * reshape(permute(Z, [2, 1, 3]), [], 1);

ue = -(xc.^2 + yc.^2 + zc.^2); % Unknown function
RHS = ue;

% Get 3D curvilinear mimetic divergence
D = div3DCurv(k, xc, yc, zc, m - 1, dx, n - 1, dy, o - 1, dz, dc, nc);
% Get 3D curvilinear mimetic gradient
G = grad3DCurv(k, xc, yc, zc, m - 1, dx, n - 1, dy, o - 1, dz, dc, nc);
% Dirichlet BCs
BC = robinBC3D(k, m-1, 1, n-1, 1, o-1, 1, 1, 0);
% Laplacian operator with BCs
L = D*G+BC;

idx = find(~any(BC, 2)); % We use this to find the null rows of BC
RHS(idx) = -6; % RHS = f''(x, y, z) in the inner domain

% Solve the system of linear equations
SOL = L \ RHS;

% Plot the exact solution
subplot(2, 1, 1)
scatter3(xc, yc, zc, 100, ue, 'Filled');
title('Exact')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar

% Plot the approximation
subplot(2, 1, 2)
scatter3(xc, yc, zc, 100, SOL, 'Filled');
title('Approximation')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar

l2_norm = norm(ue - SOL);
disp("L2 norm of error: " + l2_norm)