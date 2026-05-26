% 3D Staggering example using a 3D Mimetic laplacian

clc
close all

addpath('../../src/matlab_octave')

k = 2; % Order of accuracy
m = 5; % -> 7
n = 6; % -> 8
o = 7; % -> 9

dc = [1; 1; 1; 1; 1; 1];
nc = [0; 0; 0; 0; 0; 0];
g = makeGrid('m', m, 'n', n, 'o', o, 'dx', 1, 'dy', 1, 'dz', 1, 'bc', struct('dc', dc, 'nc', nc));
L = lap(g, k); % 3D Mimetic laplacian operator
v = {zeros(n*o,1); zeros(n*o,1); zeros(o*(m+2),1); zeros(o*(m+2),1); zeros((n+2)*(m+2),1); zeros((n+2)*(m+2),1)};
[L_bc, ~] = addScalarBC(sparse(size(L,1), size(L,2)), zeros(size(L,1),1), k, g, v);
L = L + L_bc; % Dirichlet BC

RHS = zeros(m+2, n+2, o+2);

RHS(:, :, 1) = 100; % Known value at the cube's front face

RHS = reshape(RHS, (m+2)*(n+2)*(o+2), 1);

SOL = L\RHS;

SOL = reshape(SOL, m+2, n+2, o+2);

p = 2; % Page to be displayed

page = SOL(:, :, p);

imagesc(page)
title([num2str(p) ' page'])
xlabel('m')
ylabel('n')
set(gca, 'YDir', 'Normal')
colorbar
