classdef testEnergy < matlab.unittest.TestCase
    methods(Test)
        function testforEnergy(testCase)
            addpath ('../../src/matlab_octave')
            
            %parameteres
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

            for i= 1:length(expected)	
           	testCase.verifyLessThan(abs(real(eigval(i) / eigval(1)) - expected(i)),tol, ...
            		sprintf("Nullity test failed for k = %d", k));
             end
        end
    end
end

