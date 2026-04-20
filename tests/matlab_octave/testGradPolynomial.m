classdef testGradPolynomial < matlab.unittest.TestCase
    methods (Test)
        function testGradOfPolynomial1D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;
            x1 = 0;
            x2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2-x1) / m;

                G = grad(k, m, dx);

                sfield = [x1, x1+dx/2:dx:x2-dx/2, x2]';
                vfield = (x1:dx:x2)';

                approx = G * sfield.^k;
                analytic = k * vfield.^(k-1);
                
                err = norm(approx-analytic);

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end

        function testGradOfPolynomial2D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;
            x1 = 0;
            x2 = 1;
            y1 = 0;
            y2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2 - x1) / m;
                n = m + 2;
                dy = (y2 - y1) / n;

                G = grad2D(k, m, dx, n, dy);

                % staggered grid components
                nodes_x = (x1:dx:x2)';
                nodes_y = (y1:dy:y2)';
                centers_x = (x1+dx/2:dx:x2-dx/2)';
                centers_y = (y1+dy/2:dy:y2-dy/2)';

                % set up vector field
                [~, vfield_x] = meshgrid(centers_y, nodes_x);
                vfield_x = reshape(vfield_x, [], 1);                
                [vfield_y, ~] = meshgrid(nodes_y, centers_x);
                vfield_y = reshape(vfield_y, [], 1);

                % set up scalar field
                [sfield_y, sfield_x] = meshgrid([y1,centers_y',y2]', [x1,centers_x',x2]');
                sfield_x = reshape(sfield_x, [], 1);
                sfield_y = reshape(sfield_y, [], 1);

                % compute approximate and analytical solutions
                approx = G * (sfield_x.^k + sfield_y.^k);
                analytic_x = k * vfield_x.^(k-1);
                analytic_y = k * vfield_y.^(k-1);
                analytic_combined = [analytic_x; analytic_y];
                
                err = norm(approx - analytic_combined);

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end
    end
end