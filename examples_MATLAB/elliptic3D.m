% 3D Staggering example using a 3D Mimetic laplacian

clc
close all

addpath('../mole_MATLAB')

m = 5; % -> 7
n = 6; % -> 8
o = 7; % -> 9

L = lap3D(2, m, 1, n, 1, o, 1); % 3D Mimetic laplacian operator

for i = 1 : (m+2)*(n+2)*(o+2)
    if L(i,i) == 0
        L(i,i) = 1; % Impose Dirichlet BC
    end
end

RHS = zeros((m+2), (n+2), (o+2));

RHS(:, :, 1) = 100; % Known value at the cube's front face

RHS = reshape(RHS, (m+2)*(n+2)*(o+2), 1);

SOL = L\RHS;

SOL = reshape(SOL, (m+2), (n+2), (o+2));

p = 2; % Page to be displayed

page = SOL(:, :, p);

imagesc(reshape(page, (m+2), (n+2))')
title([num2str(p) ' page'])
xlabel('m')
ylabel('n')
set(gca, 'YDir', 'Normal')
colorbar
