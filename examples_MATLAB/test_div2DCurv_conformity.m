% Testing the curvilinear divergence
clc
close all

addpath('../mole_MATLAB')

m = 10;
n = 7;

[X, Y] = genCurvGrid(n, m);
%[X, Y] = meshgrid(1:m, 1:n);
%[X, Y] = meshgrid([1 2 3 4 9 14 19 25 30 31], [0 1 2 3 8 13 14]);
mesh(X, Y, zeros(n, m), 'Marker', '.', 'MarkerSize', 10)
axis tight
%    Az  El
view([0 90])
set(gcf, 'Color', 'w')

tic
D = div2DCurv(2, X, Y);
toc
figure
spy(D)
Dnon = div2DNonUniform(2, X(1, :), Y(:, 1));
figure
spy(D-Dnon)
max(max(abs((D-Dnon))))
