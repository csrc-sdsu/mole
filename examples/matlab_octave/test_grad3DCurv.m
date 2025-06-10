clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 20; % Number of nodes along x-axis
n = 20; % Number of nodes along y-axis
o = 20; % Number of nodes along z-axis

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);

C = X.^2+Y.^2+Z.^2; % Given scalar field (on a nodal grid)

% Plot the physical grid
scatter3(X(:), Y(:), Z(:), 50, C(:), 'Filled');
title('Given scalar field')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal

% Staggered logical grid
[Xs, Ys, Zs] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n], [1 1.5 : 1 : o-0.5 o]);
% Interpolate scalar field from nodal logical to staggered logical
Cs = interp3(C, Xs, Ys, Zs);
% Reshape the field so it can be multiplied by the operator later on
C_ = reshape(permute(Cs, [2, 1, 3]), [], 1);

% Get 3D curvilinear mimetic gradient
G = grad3DCurv(k, X, Y, Z);

% Apply the operator to the field
TMP = G*C_;
Gx = TMP(1:m*(n-1)*(o-1));
Gy = TMP(m*(n-1)*(o-1)+1:m*(n-1)*(o-1)+(m-1)*n*(o-1));
Gz = TMP(m*(n-1)*(o-1)+(m-1)*n*(o-1)+1:end);

% Reshape for visualization
Gx = Gx(1:m*(n-1));
Gx = reshape(Gx, m, n-1)';
Gy = Gy(1:(m-1)*n);
Gy = reshape(Gy, m-1, n)';
Gz = reshape(Gz, m-1, n-1, o);
Gz = squeeze(Gz(:, 1, :))';

figure
Xu = (X(1:end-1, :, 1)+X(2:end, :, 1))/2;
Yu = (Y(1:end-1, :, 1)+Y(2:end, :, 1))/2;
surf(Xu, Yu, Gx, 'EdgeColor', 'none')
title('Gx')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
view([0 90])
shading interp

figure
Xv = (X(:, 1:end-1, 1)+X(:, 2:end, 1))/2;
Yv = (Y(:, 1:end-1, 1)+Y(:, 2:end, 1))/2;
surf(Xv, Yv, Gy, 'EdgeColor', 'none')
title('Gy')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
view([0 90])
shading interp

figure
Xw = squeeze((X(1, 1:end-1, :)+X(1, 2:end, :))/2);
Zw = squeeze((Z(1, 1:end-1, :)+Z(1, 2:end, :))/2);
surf(Xw, Zw, Gz', 'EdgeColor', 'none')
title('Gz')
xlabel('x')
ylabel('z')
zlabel('y')
axis equal
view([0 90])
shading interp
