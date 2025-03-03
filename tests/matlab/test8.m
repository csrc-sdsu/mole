% Correctness test of divergencehelper

addpath('../../src/matlab')

tol = 1e-12;

for k = 1:4
    D_1=divergencehelper(2*k,4*k+1);
    D_2=divergence(2*k,4*k+1,1);
    sol = reshape(D_1-D_2,[1,6+k*(20+16*k)]); 
    %flatten G_1-G_2 into a vector,(4k+3)(4k+2)=16k^2+20k+6
    % is the total number of elements in the matrix.  
    
    if (norm(sol,inf) > tol)
        fprintf("Test FAILED!\n");
    end
end

fprintf("Test PASSED!\n");