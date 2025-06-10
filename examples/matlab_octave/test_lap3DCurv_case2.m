% Tests the 3D curvilinear laplacian

clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 20; % Number of nodes along x-axis
n = 20; % Number of nodes along y-axis
o = 10; % Number of nodes along z-axis

a = -pi; % xlim(0)
b =  pi; % xlim(1)
c = -pi; % ylim(0)
d =  pi; % ylim(1)
e =  -1; % zlim(0)
f =   1; % zlim(1)
[X, Y, Z] = meshgrid(linspace(a, b, m), linspace(c, d, n), linspace(e, f, o));
X = X + sin(Y);

F = -(X.^2+Y.^2+Z.^2); % Unknown function

% Staggered logical grid
[Xs, Ys, Zs] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n], [1 1.5 : 1 : o-0.5 o]);
% Interpolate scalar field from nodal logical to staggered logical
RHS = interp3(F, Xs, Ys, Zs);

RHS = reshape(permute(RHS, [2, 1, 3]), [], 1);

% Get 3D curvilinear mimetic divergence
D = div3DCurv(k, X, Y, Z);
% Get 3D curvilinear mimetic gradient
G = grad3DCurv(k, X, Y, Z);
% Dirichlet BCs
BC = robinBC3D(k, m-1, 1, n-1, 1, o-1, 1, 1, 0);
% Laplacian operator with BCs
L = D*G+BC;

idx = find(~any(BC, 2)); % We use this to find the null rows of BC
RHS(idx) = -6; % RHS = f''(x, y, z) in the inner domain

% Solve the system of linear equations
SOL = L\RHS;

SOL = permute(reshape(SOL, m+1, n+1, o+1), [2, 1, 3]);

% Plot the exact solution
subplot(2, 1, 1)
scatter3(X(:), Y(:), Z(:), 100, F(:), 'Filled');
title('Exact')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar

% Plot the approximation
subplot(2, 1, 2)
SOL = SOL(2:end, 2:end, 2:end); % So we can plot with X, Y and Z
scatter3(X(:), Y(:), Z(:), 100, SOL(:), 'Filled');
title('Approximation')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar
