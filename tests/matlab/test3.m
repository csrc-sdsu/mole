% Nullity test of Laplacian operator

addpath('../../src/matlab')

ks = [2, 4, 6, 8];  % Different orders of accuracy
tol = 1e-10;

for k = ks
    m = 2 * k + 1;
    dx = 1 / m;

    L = lap(k, m, dx);
    
    field = ones(m + 2, 1);
    
    sol = L * field;
    
    if (norm(sol) > tol)
        fprintf("Test FAILED!\n");
    end
end

fprintf("Test PASSED!\n");
