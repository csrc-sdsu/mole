% Tests the 3D curvilinear divergence
clc
close all

addpath('../mole_MATLAB')

% Parameters
k = 2;  % Order of accuracy
m = 20; % Number of nodes along x-axis
n = 20; % Number of nodes along y-axis
o = 20; % Number of nodes along z-axis

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);
% [X, Y, Z] = meshgrid(1:m, 1:n, 1:o);

Ux = (X(1:end-1, :, :) + X(2:end, :, :))/2;
Ux = (Ux(:, :, 1:end-1) + Ux(:, :, 2:end))/2;
Uy = (Y(1:end-1, :, :) + Y(2:end, :, :))/2;
Uy = (Uy(:, :, 1:end-1) + Uy(:, :, 2:end))/2;
Uz = (Z(1:end-1, :, :) + Z(2:end, :, :))/2;
Uz = (Uz(:, :, 1:end-1) + Uz(:, :, 2:end))/2;
Vx = (X(:, 1:end-1, :) + X(:, 2:end, :))/2;
Vx = (Vx(:, :, 1:end-1) + Vx(:, :, 2:end))/2;
Vy = (Y(:, 1:end-1, :) + Y(:, 2:end, :))/2;
Vy = (Vy(:, :, 1:end-1) + Vy(:, :, 2:end))/2;
Vz = (Z(:, 1:end-1, :) + Z(:, 2:end, :))/2;
Vz = (Vz(:, :, 1:end-1) + Vz(:, :, 2:end))/2;
Wx = (X(1:end-1, :, :) + X(2:end, :, :))/2;
Wx = (Wx(:, 1:end-1, :) + Wx(:, 2:end, :))/2;
Wy = (Y(1:end-1, :, :) + Y(2:end, :, :))/2;
Wy = (Wy(:, 1:end-1, :) + Wy(:, 2:end, :))/2;
Wz = (Z(1:end-1, :, :) + Z(2:end, :, :))/2;
Wz = (Wz(:, 1:end-1, :) + Wz(:, 2:end, :))/2;

% Interpolate U values
Ugiven = sin(X); %X.^2;
interpolant = scatteredInterpolant([X(:) Y(:) Z(:)], Ugiven(:));
U = interpolant(Ux, Uy, Uz);
% Interpolate V values
Vgiven = zeros(size(Y)); %Y.^2;
interpolant = scatteredInterpolant([X(:) Y(:) Z(:)], Vgiven(:));
V = interpolant(Vx, Vy, Vz);
% Interpolate W values
Wgiven = zeros(size(Z)); %Z.^2;
interpolant = scatteredInterpolant([X(:) Y(:) Z(:)], Wgiven(:));
W = interpolant(Wx, Wy, Wz);

U = reshape(permute(U, [2, 1, 3]), [], 1);
V = reshape(permute(V, [2, 1, 3]), [], 1);
W = reshape(permute(W, [2, 1, 3]), [], 1);

% Get 3D curvilinear mimetic divergence
D = div3DCurv(k, X, Y, Z);

% Apply the operator to the field
Ccomp = D*[U; V; W];

% Remove outer layers for visualization
Ccomp = permute(reshape(Ccomp, m+1, n+1, o+1), [2, 1, 3]);
Ccomp = Ccomp(2:end-1, 2:end-1, 2:end-1);

% Compute centroids
X = (X(1:end-1, :, :)+X(2:end, :, :))/2;
X = (X(:, 1:end-1, :)+X(:, 2:end, :))/2;
X = (X(:, :, 1:end-1)+X(:, :, 2:end))/2;
Y = (Y(1:end-1, :, :)+Y(2:end, :, :))/2;
Y = (Y(:, 1:end-1, :)+Y(:, 2:end, :))/2;
Y = (Y(:, :, 1:end-1)+Y(:, :, 2:end))/2;
Z = (Z(1:end-1, :, :)+Z(2:end, :, :))/2;
Z = (Z(:, 1:end-1, :)+Z(:, 2:end, :))/2;
Z = (Z(:, :, 1:end-1)+Z(:, :, 2:end))/2;

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