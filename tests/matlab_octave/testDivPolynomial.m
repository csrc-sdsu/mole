classdef testDivPolynomial < matlab.unittest.TestCase
    methods (Test)
        function testDivOfPolynomial1D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-11;
            x1 = 0;
            x2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2 - x1) / m;

                D = div(k, m, dx);

                sfield = [x1, x1+dx/2:dx:x2-dx/2, x2]';
                vfield = (x1:dx:x2)';

                approx = D * vfield.^k;
                analytic = k * sfield.^(k-1);
                
                % Note: ignore boundary points for divergence
                err = approx(2:end-1) - analytic(2:end-1);

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end

        function testDivOfPolynomial2D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-11;
            x1 = 0;
            x2 = 1;
            y1 = 0;
            y2 = 1;

            for k = ks
                m = 2 * k + 1;
                dx = (x2 - x1) / m;
                n = m + 2;
                dy = (y2 - y1) / n;

                D = div2D(k, m, dx, n, dy);

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

                % compute approximate and analytical solutions
                approx = D * [vfield_x; vfield_y].^k;
                analytic = k * sfield_x.^(k-1) + k * sfield_y.^(k-1);
                
                % remove boundary for divergence; int(erior) only
                analytic_int = zeros(m+2, n+2);
                analytic_int(2:end-1, 2:end-1) = analytic(2:end-1, 2:end-1);
                analytic_int = reshape(analytic_int, [], 1);
                
                err = approx - analytic_int;

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end

        function testDivOfPolynomial3D(testCase)
            addpath('../../src/matlab_octave')
            
            ks = [2, 4, 6, 8];  % Different orders of accuracy
            tol = 1e-11;
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

                D = div3D(k, m, dx, n, dy, o, dz);

                % staggered grid components
                nodes_x = (x1:dx:x2)';
                nodes_y = (y1:dy:y2)';
                nodes_z = (z1:dz:z2)';
                centers_x = (x1+dx/2:dx:x2-dx/2)';
                centers_y = (y1+dy/2:dy:y2-dy/2)';
                centers_z = (z1+dz/2:dz:z2-dz/2)';

                % set up vector field
                [~, vfield_x, ~] = meshgrid(centers_y, nodes_x, centers_z);
                vfield_x = reshape(vfield_x, [], 1);                
                [vfield_y, ~, ~] = meshgrid(nodes_y, centers_x, centers_z);
                vfield_y = reshape(vfield_y, [], 1);
                [~, ~, vfield_z] = meshgrid(centers_y, centers_x, nodes_z);
                vfield_z = reshape(vfield_z, [], 1);

                % set up scalar field
                [sfield_y, sfield_x, sfield_z] = meshgrid([y1,centers_y',y2]', ...
                           [x1,centers_x',x2]', [z1,centers_z',z2]');

                % compute approximate and analytical solutions
                approx = D * [vfield_x; vfield_y; vfield_z].^k;
                analytic = k * sfield_x.^(k-1) + k * sfield_y.^(k-1) + ...
                           k * sfield_z.^(k-1);
                
                % remove boundary for divergence; int(erior) only
                analytic_int = zeros(m+2, n+2, o+2);
                analytic_int(2:end-1, 2:end-1, 2:end-1) = analytic(2:end-1, 2:end-1, 2:end-1);
                analytic_int = reshape(analytic_int, [], 1);
                
                err = approx - analytic_int;

                testCase.verifyLessThan(norm(err), tol, ...
                    sprintf("Nullity test failed for k = %d", k));
            end
        end
    end
end