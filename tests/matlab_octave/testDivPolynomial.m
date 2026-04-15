classdef testDivPolynomial < matlab.unittest.TestCase
    methods (Test)
        function testDivOfPolynomial1D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;
            x1 = 0;
            x2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2-x1) / m;

                D = div(k, m, dx);

                sfield = [x1, x1+dx/2:dx:x2-dx/2, x2]';
                vfield = (x1:dx:x2)';

                approx = D * vfield.^k;
                analytic = k * sfield.^(k-1);
                
                % Note: ignore boundary points for divergence
                err = norm(approx(2:end-1)-analytic(2:end-1));

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end
    end
end