% Energy test

addpath('../../src/matlab')

% Parameters
k = 4;
a = -5;
b = 5;
m = 500;
grid = linspace(a, b, m);
dx = grid(2) - grid(1);
tol = 1e-6;

% Laplacian
L = lap(k, m - 2, dx);

% Transform grid using an anonymous function
grid = arrayfun(@(x) x^2, grid);

% Potential matrix V
V = spdiags(grid', 0, m, m);  % Transpose grid to match dimension

% Hamiltonian H
H = -0.5 * L + V;

% Eigenvalue computation
eigval = eig(full(H));  % Convert sparse matrix to full for eig function
eigval = sort(eigval);

% Expected eigenvalues
expected = [1, 3, 5, 7, 9];

% Test for failure
failed = false;
for i = 1:length(expected)
    if (abs(real(eigval(i) / eigval(1)) - expected(i)) > tol)
        fprintf(2, 'Test FAILED!\n');
        failed = true;
    end
end

if ~failed
    fprintf(1, 'Test PASSED!\n');
end
