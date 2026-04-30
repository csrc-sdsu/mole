% Tests the 3D curvilinear divergence
clc
close all
clear

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 20; % Number of nodes along xi-axis
n = 30; % Number of nodes along eta-axis
o = 40; % Number of nodes along kappa-axis
dx = 1 / (m - 1);
dy = 1 / (n - 1);
dz = 1 / (o - 1);
dc = [1; 1; 1; 1; 1; 1];
nc = [0; 0; 0; 0; 0; 0];

xlength = linspace(1,m,m);
ylength = linspace(1,n,n);
zlength = linspace(1,o,o);

% [X, Y, Z] = meshgrid(xlength,ylength,zlength);

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);

X = permute(X, [2 1 3]);
Y = permute(Y, [2 1 3]);
Z = permute(Z, [2 1 3]);

% Interpolators
NtoC = interpolNodesToCenters3D(k, m - 1, n - 1, o - 1, dc, nc);

CtoU = interpolCentersToFacesD1D(k, m - 1);
CtoU = kron(kron(speye(o + 1), speye(n + 1)), CtoU);

CtoV = interpolCentersToFacesD1D(k, n - 1);
CtoV = kron(kron(speye(o + 1), CtoV), speye(m + 1));

CtoW = interpolCentersToFacesD1D(k, o - 1);
CtoW = kron(kron(CtoW, speye(n + 1)), speye(m + 1));

xc = NtoC * reshape(X, [], 1);
yc = NtoC * reshape(Y, [], 1);
zc = NtoC * reshape(Z, [], 1);

U = CtoU * sin(xc);
V = CtoV * zeros(size(yc));
W = CtoW * zeros(size(zc));

D = div3DCurv(k, xc, yc, zc, m - 1, dx, n - 1, dy, o - 1, dz, dc, nc);

% Apply the operator to the field
Ccomp = D*[U; V; W];

% Remove outer layers for visualization
Ccomp = reshape(Ccomp, m+1, n+1, o+1);
Ccomp = Ccomp(2:end-1, 2:end-1, 2:end-1);

X = reshape(xc, m + 1, n + 1, o + 1);
Y = reshape(yc, m + 1, n + 1, o + 1);
Z = reshape(zc, m + 1, n + 1, o + 1);

X = X(2:end-1, 2:end-1, 2:end-1);
Y = Y(2:end-1, 2:end-1, 2:end-1);
Z = Z(2:end-1, 2:end-1, 2:end-1);

figure
scatter3(X(:), Y(:), Z(:), 50, Ccomp(:), 'Filled');
title('Divergence of the field')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar
view([140 40])

figure
surf(X(:, :, o/2), Y(:, :, o/2), Ccomp(:, :, o/2))
title('Slice')
xlabel('x')
ylabel('y')
axis equal
colorbar
view([0 90])
shading interp

% Analytical divergence
div = cos(X);

figure
scatter3(X(:), Y(:), Z(:), 50, div(:), 'Filled');
title('Analytical')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar
view([140 40])

figure
surf(X(:, :, o/2), Y(:, :, o/2), div(:, :, o/2))
title('Analytical')
xlabel('x')
ylabel('y')
axis equal
colorbar
view([0 90])
shading interp

l2_norm = norm(div(:) - Ccomp(:));
disp("L2 norm: " + l2_norm)