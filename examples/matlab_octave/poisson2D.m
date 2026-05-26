% 2D Staggering example using a 2D Mimetic laplacian

clc
close all

addpath('../../src/matlab_octave')

k = 2; % Order of accuracy
m = 5; % Vertical resolution - minimal number of grid points required for the operator
n = 6; % Horizontal resolution - minimal number of grid points required for the operator

dc = [1; 1; 1; 1];
nc = [0; 0; 0; 0];
g = makeGrid('m', m, 'n', n, 'dx', 1, 'dy', 1, 'bc', struct('dc', dc, 'nc', nc));
L = lap(g, k); % 2D Mimetic laplacian operator
v = {zeros(n,1); zeros(n,1); zeros(m+2,1); zeros(m+2,1)};
[L_bc, ~] = addScalarBC(sparse(size(L,1), size(L,2)), zeros(size(L,1),1), k, g, v); % Dirichlet BC
L = L + L_bc;

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
