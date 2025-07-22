% Tests the 2D curvilinear nodal laplacian on a sinusoidal grid
clc
close all

addpath('../../src/matlab_octave')

% Parameters
e = 1; % Controls "rectangularity" of the grid, e = 0 -> completely rectangular
k = 4;
m = 100;
n = 100;
a = -pi;
b = 2*pi;
c = -pi;
d = pi;

% Function handles
F = @(X, Y) sin(X)+cos(Y);
f = @(X, Y) -sin(X)-cos(Y);

dm = (b-a)/(m-1);
dn = (d-c)/(n-1);
[X, Y] = meshgrid(a:dm:b, c:dn:d);
Y = Y+e*cos(X);

% Construct nodal Laplacian
tic
[Nx, Ny] = nodal2DCurv(k, X, Y);
L = [Nx Ny]*[Nx; Ny];
toc

% Get indices of nodes at the boundaries
bdry_idx = boundaryIdx2D(m, n);

% Impose Dirichlet BC on Laplacian
L(bdry_idx, :) = 0;
for i = 1:numel(bdry_idx)
    L(bdry_idx(i), bdry_idx(i)) = 1;
end
spy(L)

RHS = f(X, Y);
RHS = reshape(RHS.', [], 1);

% Impose BC on RHS
BC = F(X, Y);
BC = reshape(BC.', [], 1);
RHS(bdry_idx) = BC(bdry_idx);

% Solve the system
Comp = L\RHS;
Comp = reshape(Comp, m, n)';

% Plot result
figure
surf(X, Y, Comp, 'EdgeColor', 'none')
view(0, 90)
xlabel('x')
ylabel('y')
colorbar

figure
surf(X, Y, F(X, Y), 'EdgeColor', 'none')
view(0, 90)
xlabel('x')
ylabel('y')
colorbar

fprintf('Maximum error: %.2f\n', max(max(abs(F(X, Y)-Comp))))
fprintf('Relative error: %.2f%%\n', 100*max(max(abs(F(X, Y)-Comp)))/(max(max(F(X, Y))) - min(min(F(X, Y)))))
