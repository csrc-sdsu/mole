% Tests the 2D curvilinear nodal laplacian on a noisy grid
clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 50;
n = 50;

% Function handles
F = @(X, Y) (X-m/2).^2+(Y-n/2).^2;
f = @(X, Y) 4*ones(size(X));

[X, Y] = meshgrid(1:m, 1:n);
% Add some uniform random noise
rng(1);
X = X + rand(size(X));
Y = Y + rand(size(Y));

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
surf(X, Y, Comp)
xlabel('x')
ylabel('y')
colorbar

figure
surf(X, Y, F(X, Y))
xlabel('x')
ylabel('y')
colorbar

fprintf('Maximum error: %.2f\n', max(max(abs(F(X, Y)-Comp))))
fprintf('Relative error: %.2f%%\n', 100*max(max(abs(F(X, Y)-Comp)))/(max(max(F(X, Y))) - min(min(F(X, Y)))))
