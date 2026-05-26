% Tests the 3D curvilinear laplacian

clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 25; % Number of nodes along x-axis
n = 20; % Number of nodes along y-axis
o = 15; % Number of nodes along z-axis

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);

F = X.^2+Y.^2+Z.^2; % Unknown function

% Staggered logical grid
[Xs, Ys, Zs] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n], [1 1.5 : 1 : o-0.5 o]);
% Interpolate scalar field from nodal logical to staggered logical
RHS = interp3(F, Xs, Ys, Zs);

RHS = reshape(permute(RHS, [2, 1, 3]), [], 1);

% Build 3D curvilinear grid (X, Y, Z are meshgrid n×m×o; store as ndgrid m×n×o)
% Node counts: m, n, o → cell counts: m-1, n-1, o-1
dc = [1; 1; 1; 1; 1; 1];
nc = [0; 0; 0; 0; 0; 0];
g = struct('m', m-1, 'n', n-1, 'o', o-1, 'type', 'curvilinear', 'bc', struct('dc', dc, 'nc', nc));
g.nodes.X = permute(X, [2, 1, 3]);
g.nodes.Y = permute(Y, [2, 1, 3]);
g.nodes.Z = permute(Z, [2, 1, 3]);

% Get 3D curvilinear mimetic divergence
D = div(g, k);
% Get 3D curvilinear mimetic gradient
G = grad(g, k);
% Dirichlet BCs
v = {zeros((n-1)*(o-1),1); zeros((n-1)*(o-1),1); zeros((o-1)*(m+1),1); zeros((o-1)*(m+1),1); zeros((n+1)*(m+1),1); zeros((n+1)*(m+1),1)};
[BC, ~] = addScalarBC(sparse(size(D,1), size(D,1)), zeros(size(D,1),1), k, g, v);
% Laplacian operator with BCs
L = D*G+BC;

idx = find(~any(BC, 2)); % We use this to find the null rows of BC
RHS(idx) = 6; % RHS = f''(x, y, z) in the inner domain

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
