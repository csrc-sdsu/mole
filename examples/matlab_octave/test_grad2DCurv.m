clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 40; % Number of nodes along x-axis
n = 40; % Number of nodes along y-axis

[X, Y] = genCurvGrid(n, m);
% [X, Y] = meshgrid(1:m, 1:n);

% Plot the physical grid
mesh(X, Y, zeros(n, m), 'Marker', '.', 'MarkerSize', 10)
view([0 90])
axis equal
set(gcf, 'Color', 'w')

C = X.^2+Y.^2; % Given scalar field (on a nodal grid)
% Staggered logical grid
[Xs, Ys] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n]);
% Interpolate scalar field from nodal logical to staggered logical
Cs = interp2(C, Xs, Ys);
% Reshape the field so it can be multiplied by the operator later on
C_ = reshape(Cs', [], 1);

% Get 2D curvilinear mimetic gradient
G = grad2DCurv(k, X, Y);

% Apply the operator to the field
TMP = G*C_;
Gx = TMP(1:m*(n-1));
Gy = TMP(m*(n-1)+1:end);

% Reshape for visualization
Gx = reshape(Gx, m, n-1)';
Gy = reshape(Gy, m-1, n)';

% Plot results
figure
set(gcf, 'Color', 'w')
subplot(3, 1, 1)
surf(X, Y, C, 'EdgeColor', 'none');
colorbar
xlabel('x')
ylabel('y')
title('C')
axis equal
view([0 90])
shading interp
subplot(3, 1, 2)
surf((X(1:end-1, :)+X(2:end, :))/2, (Y(1:end-1, :)+Y(2:end, :))/2, Gx, 'EdgeColor', 'none');
colorbar
xlabel('x')
ylabel('y')
title('U')
axis equal
view([0 90])
shading interp
subplot(3, 1, 3)
surf((X(:, 1:end-1)+X(:, 2:end))/2, (Y(:, 1:end-1)+Y(:, 2:end))/2, Gy, 'EdgeColor', 'none');
colorbar
xlabel('x')
ylabel('y')
title('V')
axis equal
view([0 90])
shading interp
