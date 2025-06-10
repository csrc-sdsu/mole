classdef testPoissonAccuracy < matlab.unittest.TestCase
    methods(Test)
        function testforEnergy(testCase)
            addpath ('../../src/matlab_octave')
            
            west = 0;  % Domain's limits
	    east = 1;

            ks = [2, 4, 6, 8];  % Different orders of accuracy
            grid_sizes = [20, 40];  % Grid sizes to test

            for k = ks

                errors = zeros(size(grid_sizes));
    
            for i = 1:numel(grid_sizes)
                m = grid_sizes(i);  % Number of cells
                dx = (east - west) / m;  % Step length

                L = lap(k, m, dx);  % 1D Mimetic Laplacian operator

                % Impose Robin BC on Laplacian operator
                a = 1;
                b = 1;
                L = L + robinBC(k, m, dx, a, b);

                % 1D Staggered grid
                grid = [west west+dx/2 : dx : east-dx/2 east];

                % RHS
                U = exp(grid)';
                U(1) = 0;  % West BC
                U(end) = 2*exp(1);  % East BC

                % Solve a linear system of equations
                computed_solution = L\U;

                % Compute error using L2 norm
                analytical_solution = exp(grid);
                errors(i) = max(abs(computed_solution' - analytical_solution));
            end 

            % Compute order of accuracy
            order = zeros(numel(errors) - 1, 1);
            for i = 1:numel(errors) - 1
                order(i) = log2(errors(i) / errors(i + 1));
                
                testCase.verifyGreaterThan(order(i),k-0.5, ...
            		sprintf("Test failed for k = %d", k));
		end
            end
        end
    end
end


