classdef testGridFirstV2Migration < matlab.unittest.TestCase
    methods(Test)
        function testGridFirstOperatorsMatchLegacy1D(testCase)
            addpath('../../src/matlab_octave');

            k = 4;
            m = 20;
            dx = 0.1;
            grid = makeGrid('m', m, 'dx', dx);

            Gnew = grad(grid, k);
            Gold = gradNonPeriodic(k, m, dx);
            Dnew = div(grid, k);
            Dold = divNonPeriodic(k, m, dx);
            Lnew = lap(grid, k);
            Lold = lapNonPeriodic(k, m, dx);

            testCase.verifyLessThan(norm(Gnew - Gold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Dnew - Dold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Lnew - Lold, 'fro'), 1e-12);

            N = nodal(grid, k);
            testCase.verifySize(N, [m+1, m+1]);
        end

        function testGridFirstOperatorsMatchLegacy2D(testCase)
            addpath('../../src/matlab_octave');

            k = 2;
            m = 12;
            n = 13;
            dx = 1 / m;
            dy = 1 / n;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            Gnew = grad(grid, k);
            Gold = gradOp_impl(grid, k);
            Dnew = div(grid, k);
            Dold = divOp_impl(grid, k);
            Lnew = lap(grid, k);
            Lold = lapOp_impl(grid, k);

            testCase.verifyLessThan(norm(Gnew - Gold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Dnew - Dold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Lnew - Lold, 'fro'), 1e-12);

            N = nodal(grid, k);
            nodes = (m + 1) * (n + 1);
            testCase.verifySize(N, [2*nodes, nodes]);
        end

        function testGridFirstOperatorsMatchLegacy3D(testCase)
            addpath('../../src/matlab_octave');

            k = 2;
            m = 8;
            n = 7;
            o = 6;
            dx = 1 / m;
            dy = 1 / n;
            dz = 1 / o;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            Gnew = grad(grid, k);
            Gold = gradOp_impl(grid, k);
            Dnew = div(grid, k);
            Dold = divOp_impl(grid, k);
            Lnew = lap(grid, k);
            Lold = lapOp_impl(grid, k);

            testCase.verifyLessThan(norm(Gnew - Gold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Dnew - Dold, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(Lnew - Lold, 'fro'), 1e-12);

            N = nodal(grid, k);
            nodes = (m + 1) * (n + 1) * (o + 1);
            testCase.verifySize(N, [3*nodes, nodes]);
        end

        function testTransferFamiliesCompatibilityAndPeriodic(testCase)
            addpath('../../src/matlab_octave');

            m = 10;
            n = 8;
            o = 7;
            k = 2;

            g1 = makeGrid('m', m, 'dx', 1/m);
            g2 = makeGrid('m', m, 'n', n, 'dx', 1/m, 'dy', 1/n);
            g3 = makeGrid('m', m, 'n', n, 'o', o, 'dx', 1/m, 'dy', 1/n, 'dz', 1/o);

            % Unified interpol(grid, direction) vs _impl baseline.
            testCase.verifyLessThan(norm(interpol(g1, 'CentersToFaces') - interpolCentersToFacesD1D_impl(k, m), 'fro'), 1e-12);
            testCase.verifyLessThan(norm(interpol(g1, 'FacesToCenters') - interpolFacesToCentersG1D_impl(k, m), 'fro'), 1e-12);
            testCase.verifyLessThan(norm(interpol(g2, 'CentersToFaces') - interpolCentersToFacesD2D_impl(k, m, n), 'fro'), 1e-12);
            testCase.verifyLessThan(norm(interpol(g2, 'FacesToCenters') - interpolFacesToCentersG2D_impl(k, m, n), 'fro'), 1e-12);
            testCase.verifyLessThan(norm(interpol(g3, 'CentersToFaces') - interpolCentersToFacesD3D_impl(k, m, n, o), 'fro'), 1e-12);
            testCase.verifyLessThan(norm(interpol(g3, 'FacesToCenters') - interpolFacesToCentersG3D_impl(k, m, n, o), 'fro'), 1e-12);

            % Periodic impl consistency: all-zero dc/nc → periodic result.
            dc2 = zeros(4, 1);
            nc2 = zeros(4, 1);
            I2a = interpolCentersToFacesD2D_impl(k, m, n, dc2, nc2);
            I2b = interpolCentersToFacesD2DPeriodic_impl(k, m, n);
            testCase.verifyLessThan(norm(I2a - I2b, 'fro'), 1e-12);

            dc3 = zeros(6, 1);
            nc3 = zeros(6, 1);
            I3a = interpolFacesToCentersG3D_impl(k, m, n, o, dc3, nc3);
            I3b = interpolFacesToCentersG3DPeriodic_impl(k, m, n, o);
            testCase.verifyLessThan(norm(I3a - I3b, 'fro'), 1e-12);
        end

        function testGridTemplateRelocationResolution(testCase)
            addpath('../../src/matlab_octave');

            p = resolveGridTemplatePath('chevron');
            expectedFragment = [filesep 'geometry' filesep 'templates' filesep 'chevron'];

            testCase.verifyTrue(contains(p, expectedFragment));
            testCase.verifyTrue(isfile(fullfile(p, 'top.m')));
            testCase.verifyTrue(isfile(fullfile(p, 'bottom.m')));
            testCase.verifyTrue(isfile(fullfile(p, 'left.m')));
            testCase.verifyTrue(isfile(fullfile(p, 'right.m')));
        end

        function testTemplateDrivenGridBuildersWork(testCase)
            addpath('../../src/matlab_octave');

            [X1, Y1] = tfi('chevron', 8, 9, false);
            testCase.verifySize(X1, [8, 9]);
            testCase.verifySize(Y1, [8, 9]);
            testCase.verifyTrue(all(isfinite(X1(:))));
            testCase.verifyTrue(all(isfinite(Y1(:))));

            [X2, Y2] = ttm('chevron', 8, 9, 2, false);
            testCase.verifySize(X2, [8, 9]);
            testCase.verifySize(Y2, [8, 9]);
            testCase.verifyTrue(all(isfinite(X2(:))));
            testCase.verifyTrue(all(isfinite(Y2(:))));
        end

        function testGridApiHelpers(testCase)
            addpath('../../src/matlab_octave');

            g = makeGrid('m', 6, 'n', 7, 'dx', 0.2, 'dy', 0.25);
            testCase.verifyEqual(g.dim, 2);
            testCase.verifyTrue(isfield(g, 'bc'));

            g2 = validateGrid(struct('m', 5, 'dx', 0.1));
            testCase.verifyEqual(g2.dim, 1);
            testCase.verifyTrue(isfield(g2, 'bc'));
        end

        function testValidateGridRejectsPartialBoundarySpec(testCase)
            addpath('../../src/matlab_octave');

            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', 0.1, 'bc', struct('dc', 1))), ...
                                 'validateGrid:InvalidBC1D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 6, 'dx', 0.1, 'dy', 0.2, 'bc', struct('dc', [1;1;1;1], 'nc', []))), ...
                                 'validateGrid:InvalidBC2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 6, 'o', 7, 'dx', 0.1, 'dy', 0.2, 'dz', 0.3, 'bc', struct('nc', 1))), ...
                                 'validateGrid:InvalidBC3D');
        end

        function testDeprecatedDimensionalOperatorsDeleted(testCase)
            addpath('../../src/matlab_octave');
            % Confirm that the deprecated dimensional variant files are gone.
            testCase.verifyError(@() grad2D(2, 10, 0.1, 8, 0.125), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() div2D(2, 10, 0.1, 8, 0.125),  'MATLAB:UndefinedFunction');
            testCase.verifyError(@() lap2D(2, 10, 0.1, 8, 0.125),  'MATLAB:UndefinedFunction');
            testCase.verifyError(@() grad3D(2, 10, 0.1, 8, 0.125, 6, 0.1), 'MATLAB:UndefinedFunction');
        end

        function testDeprecatedInterpolFunctionsDeleted(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() interpol2D(10, 0.5, 0.5),  'MATLAB:UndefinedFunction');
            testCase.verifyError(@() interpolD(10, 0.5),         'MATLAB:UndefinedFunction');
            testCase.verifyError(@() interpolCentersToFacesD1D(2, 10), 'MATLAB:UndefinedFunction');
        end
    end
end
