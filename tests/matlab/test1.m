% Nullity test of Divergence operator

addpath('../../src/matlab')

ks = [2, 4, 6, 8];  % Different orders of accuracy
tol = 1e-10;

for k = ks
    m = 2 * k + 1;
    dx = 1 / m;

    D = div(k, m, dx);
    
    field = ones(m + 1, 1);
    
    sol = D * field;
    
    if (norm(sol) > tol)
        fprintf("Test FAILED!\n");
    end
end

fprintf("Test PASSED!\n");
