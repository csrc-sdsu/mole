clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 40; % Number of nodes along x-axis
n = 40; % Number of nodes along y-axis

[X, Y] = genCurvGrid(n, m);
% [X, Y] = meshgrid(1:m, 1:n);

mesh(X, Y, zeros(n, m), 'Marker', '.', 'MarkerSize', 10)
view([0 90])
axis equal
set(gcf, 'Color', 'w')

[J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);

N = nodal2D(k, m, 1, n, 1);
Ne = N(1:m*n, :);
Nn = N(m*n+1:end, :);

C = X.^2+Y.^2;

C_ = reshape(C', [], 1);

Ce = Ne*C_;
Cn = Nn*C_;

Nx = 1./J.*(Yn.*Ce-Ye.*Cn);
Ny = 1./J.*(-Xn.*Ce+Xe.*Cn);

Nx = reshape(Nx, m, n)';
Ny = reshape(Ny, m, n)';

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
subplot(3, 1, 2)
surf(X, Y, Nx, 'EdgeColor', 'none');
colorbar
xlabel('x')
ylabel('y')
title('U')
axis equal
view([0 90])
subplot(3, 1, 3)
surf(X, Y, Ny, 'EdgeColor', 'none');
colorbar
xlabel('x')
ylabel('y')
title('V')
axis equal
view([0 90])
