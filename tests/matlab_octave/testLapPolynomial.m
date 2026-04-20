classdef testLapPolynomial < matlab.unittest.TestCase
    methods (Test)
        function testLapOfPolynomial1D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;
            x1 = 0;
            x2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2-x1) / m;

                L = lap(k, m, dx);

                sfield = [x1, x1+dx/2:dx:x2-dx/2, x2]';

                approx = L * sfield.^k;
                analytic = k * (k-1) * sfield.^(k-2);
                
                % Note: ignore boundary points (because of divergence)
                err = norm(approx(2:end-1)-analytic(2:end-1));

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end

        function testLapOfPolynomial2D(testCase)
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

                L = lap2D(k, m, dx, n, dy);

                % staggered grid components (only centers needed)
                centers_x = (x1+dx/2:dx:x2-dx/2)';
                centers_y = (y1+dy/2:dy:y2-dy/2)';

                % set up scalar field only (vector field not needed)
                [sfield_y, sfield_x] = meshgrid([y1,centers_y',y2]', [x1,centers_x',x2]');
                sfield_x = reshape(sfield_x, [], 1);
                sfield_y = reshape(sfield_y, [], 1);

                % compute approximate and analytical solutions
                approx = L * (sfield_x.^k + sfield_y.^k);
                analytic = k * (k-1) * sfield_x.^(k-2) + ...
                           k * (k-1) * sfield_y.^(k-2);

                % remove boundary (because of divergence); int(erior) only
                analytic = reshape(analytic, m+2, n+2);
                analytic_int = zeros(m+2, n+2);
                analytic_int(2:end-1, 2:end-1) = analytic(2:end-1, 2:end-1);
                analytic_int = reshape(analytic_int, [], 1);

                err = norm(approx - analytic_int);

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end

        function testLapOfPolynomial3D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-10;
            x1 = 0;
            x2 = 1;
            y1 = 0;
            y2 = 1;
            z1 = 0;
            z2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2 - x1) / m;
                n = m + 2;
                dy = (y2 - y1) / n;
                o = n + 2;
                dz = (z2 - z1) / o;

                L = lap3D(k, m, dx, n, dy, o, dz);

                % staggered grid components (only centers needed)
                centers_x = (x1+dx/2:dx:x2-dx/2)';
                centers_y = (y1+dy/2:dy:y2-dy/2)';
                centers_z = (z1+dz/2:dz:z2-dz/2)';

                % set up scalar field only (vector field not needed)
                [sfield_y, sfield_x, sfield_z] = meshgrid([y1,centers_y',y2]', ...
                           [x1,centers_x',x2]', [z1,centers_z',z2]');
                sfield_x = reshape(sfield_x, [], 1);
                sfield_y = reshape(sfield_y, [], 1);
                sfield_z = reshape(sfield_z, [], 1);

                % compute approximate and analytical solutions
                approx = L * (sfield_x.^k + sfield_y.^k + sfield_z.^k);
                analytic = k * (k-1) * sfield_x.^(k-2) + ...
                           k * (k-1) * sfield_y.^(k-2) + ...
                           k * (k-1) * sfield_z.^(k-2);

                % remove boundary (because of divergence); int(erior) only
                analytic = reshape(analytic, m+2, n+2, o+2);
                analytic_int = zeros(m+2, n+2, o+2);
                analytic_int(2:end-1, 2:end-1, 2:end-1) = analytic(2:end-1, 2:end-1, 2:end-1);
                analytic_int = reshape(analytic_int, [], 1);

                err = norm(approx - analytic_int);

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end
    end
end