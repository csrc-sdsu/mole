% 3D Staggering example using a 3D Mimetic laplacian
% same as example elliptic3D using addScalarBC3D
%

clc
close all

addpath('../../src/matlab_octave')

k = 2; % Order of accuracy
m = 5; % -> 7
n = 6; % -> 8
o = 7; % -> 9

% boundary type
dc = [1;1;1;1;1;1];
nc = [0;0;0;0;0;0];
bcl = zeros(n*o,1);
bcr = zeros(n*o,1);
bcb = zeros((m+2)*o,1);
bct = zeros((m+2)*o,1);
bcf = 100*ones((n+2)*(m+2),1); % Dirichlet boundary condition
bcz = zeros((n+2)*(m+2),1);
v = {bcl;bcr;bcb;bct;bcf;bcz};

L = lap3D(k, m, 1, n, 1, o, 1, dc, nc); % 3D Mimetic laplacian operator
RHS = zeros(m+2, n+2, o+2);
RHS = reshape(RHS, [], 1);

[L0, RHS0] = addScalarBC3D(L,RHS,k,m,1,n,1,o,1,dc,nc,v); % add BC to linear system
SOL = L0\RHS0;
SOL = reshape(SOL, m+2, n+2, o+2);

p = 2; % Page to be displayed

page = SOL(:, :, p);

imagesc(page)
title([num2str(p) ' page'])
xlabel('m')
ylabel('n')
set(gca, 'YDir', 'Normal')
colorbar
