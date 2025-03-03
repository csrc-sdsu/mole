% Correctness test of gradienthelper

addpath('../../src/matlab')

tol = 1e-12;

for k = 1:4
    G_1=gradienthelper(2*k,4*k);
    G_2=grad(2*k,4*k,1);
    
    sol = reshape(G_1-G_2,[1,2+k*(12+16*k)]); 
    % flatten G_1-G_2 into a vector,(4k+2)(4k+1)=2+12k^2+16k^2
    % is the total number of elements in the matrix, 
    
    if (norm(sol,inf) > tol)
        fprintf("Test FAILED!\n");
    end
end

fprintf("Test PASSED!\n");