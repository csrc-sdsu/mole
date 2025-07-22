classdef testDivergence < matlab.unittest.TestCase
    methods (Test)
        function testNullityOfDivergence(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;

            for k = ks
                m = 2 * k + 1;
                dx = 1 / m;

                D = div(k, m, dx);

                field = ones(m + 1, 1);

                sol = D * field;

                testCase.verifyLessThan(norm(sol), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end
    end
end
