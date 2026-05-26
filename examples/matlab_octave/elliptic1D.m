% Solves the 1D Poisson's equation with Robin boundary conditions

clc
close all

addpath('../../src/matlab_octave')

west = 0;  % Domain's limits
east = 1;

k = 6;  % Operator's order of accuracy
m = 2*k+1;  % Minimum number of cells to attain the desired accuracy
dx = (east-west)/m;  % Step length

% Impose Robin BC on laplacian operator
a = 1;
b = 1;
dc = [a; a];
nc = [b; b];
v = [0; 0];
g = makeGrid('m', m, 'dx', dx, 'bc', struct('dc', dc, 'nc', nc));
L = lap(g, k);  % 1D Mimetic laplacian operator
[L_bc, ~] = addScalarBC(sparse(size(L,1), size(L,2)), zeros(size(L,1),1), k, g, v);
L = L + L_bc;

% 1D Staggered grid
grid = [west west+dx/2 : dx : east-dx/2 east];

% RHS
U = exp(grid)';
U(1) = 0;  % West BC
U(end) = 2*exp(1);  % East BC

U = L\U;  % Solve a linear system of equations

% Plot result
plot(grid, U, 'o')
hold on
plot(grid, exp(grid))
legend('Approximated', 'Analytical', 'Location', 'NorthWest')
title('Poisson''s equation with Robin BC')
xlabel('x')
ylabel('u(x)')
