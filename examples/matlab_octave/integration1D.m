% Program that integrates numerically using mimetic quadratures

clc; close all;

addpath('../../src/matlab_octave')

% Domain limits
west = -5;
east = 5;

% Discretization parameters
k = 2;      % Order of mimetic quadrature
m = 50;     % Number of cells
dx = (east-west)/m;

% 1D staggered grid (cell centers)
grid = [west west+dx/2 : dx : east-dx/2 east];

% Function to integrate
fun = @(x) (1-x.^2).*exp(-x.^2/2);  % Ricker wavelet
f = fun(grid);

% Approximate the integral using Q's weights
w = weightsQ(k, m, dx);
w(1) = 0; w(end) = 0;
F = f*w;

% Exact integral for comparison
exact = integral(fun, west, east);

% Trapezoidal rule approximation
trapz_approx = trapz(grid, f);

% Output results
fprintf('Mimetic : %.6f\n', F);
fprintf('Exact   : %.6f\n', exact);
fprintf('trapz   : %.6f\n', trapz_approx);
