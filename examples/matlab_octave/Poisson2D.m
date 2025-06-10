% 2D Staggering example using a 2D Mimetic laplacian

clc
close all

addpath('../../src/matlab_octave')

k = 2; % Order of accuracy
m = 5; % Vertical resolution - minimal number of grid points required for the operator
n = 6; % Horizontal resolution - minimal number of grid points required for the operator

L = lap2D(k, m, 1, n, 1); % 2D Mimetic laplacian operator
L = L + robinBC2D(k, m, 1, n, 1, 1, 0); % Dirichlet BC

RHS = zeros(m+2, n+2);

RHS(1, :) = 100; % Known value at the bottom boundary

RHS = reshape(RHS, [], 1);

SOL = L\RHS;

SOL = reshape(SOL, m+2, n+2);

imagesc(SOL)
title('2D Poisson''s equation')
xlabel('m')
ylabel('n')
set(gca, 'YDir', 'Normal')
colorbar
