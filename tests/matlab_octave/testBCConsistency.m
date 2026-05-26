classdef testBCConsistency < matlab.unittest.TestCase
    methods(Test)
        function test1DCase(testCase)
            % 1D addScalarBC consistency: explicit _impl vs unified grid entry.
            addpath('../../src/matlab_octave');

            k = 4;
            m = 50;
            dx = 0.314;
            dc = [3; 5];
            nc = [4; 6];

            A0 = speye(m+2);
            b0 = ones(m+2, 1);
            v = [2; 7];

            [A1, b1] = addScalarBC1D_impl(A0, b0, k, m, dx, dc, nc, v);
            grid = makeGrid('m', m, 'dx', dx, 'bc', struct('dc', dc, 'nc', nc));
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);

            testCase.verifyLessThan(norm(A1 - A2, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1 - b2), 1e-12);
        end

        function test2DCase(testCase)
            % 2D addScalarBC consistency: explicit _impl vs unified grid entry.
            addpath('../../src/matlab_octave');

            k = 4;
            m = 50;
            n = 73;
            dx = 0.314;
            dy = 0.123;
            dc = [3; 5; 7; 9];
            nc = [4; 6; 8; 10];

            A0 = speye((m+2)*(n+2));
            b0 = ones((m+2)*(n+2), 1);
            v = {
                ones(n, 1), ...
                2*ones(n, 1), ...
                3*ones(m+2, 1), ...
                4*ones(m+2, 1)
            }';

            [A1, b1] = addScalarBC2D_impl(A0, b0, k, m, dx, n, dy, dc, nc, v);
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy, 'bc', struct('dc', dc, 'nc', nc));
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);

            testCase.verifyLessThan(norm(A1 - A2, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1 - b2), 1e-12);
        end

        function test3DCase(testCase)
            % 3D addScalarBC consistency: explicit _impl vs unified grid entry.
            addpath('../../src/matlab_octave');

            k = 4;
            m = 14;
            n = 12;
            o = 10;
            dx = 0.314;
            dy = 0.123;
            dz = 0.198;
            dc = [3; 5; 7; 9; 11; 13];
            nc = [4; 6; 8; 10; 12; 14];

            A0 = speye((m+2)*(n+2)*(o+2));
            b0 = ones((m+2)*(n+2)*(o+2), 1);
            v = {
                ones(o*n, 1), ...
                2*ones(o*n, 1), ...
                3*ones(o*(m+2), 1), ...
                4*ones(o*(m+2), 1), ...
                5*ones((n+2)*(m+2), 1), ...
                6*ones((n+2)*(m+2), 1)
            }';

            [A1, b1] = addScalarBC3D_impl(A0, b0, k, m, dx, n, dy, o, dz, dc, nc, v);
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz, ...
                            'bc', struct('dc', dc, 'nc', nc));
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);

            testCase.verifyLessThan(norm(A1 - A2, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1 - b2), 1e-12);
        end

        function testScalarBoundaryShorthandInGrid(testCase)
            addpath('../../src/matlab_octave');

            k = 4;

            m1 = 30;
            dx1 = 0.2;
            A1 = speye(m1+2);
            b1 = zeros(m1+2, 1);
            v1 = [0; 0];
            [Ae1, be1] = addScalarBC1D_impl(A1, b1, k, m1, dx1, [3; 3], [5; 5], v1);
            g1 = makeGrid('m', m1, 'dx', dx1, 'bc', struct('dc', 3, 'nc', 5));
            [Ag1, bg1] = addScalarBC(A1, b1, k, g1, v1);
            testCase.verifyLessThan(norm(Ae1 - Ag1, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(be1 - bg1), 1e-12);

            m2 = 16;
            n2 = 14;
            dx2 = 0.11;
            dy2 = 0.09;
            A2 = speye((m2+2)*(n2+2));
            b2 = zeros((m2+2)*(n2+2), 1);
            v2 = {zeros(n2, 1), zeros(n2, 1), zeros(m2+2, 1), zeros(m2+2, 1)}';
            [Ae2, be2] = addScalarBC2D_impl(A2, b2, k, m2, dx2, n2, dy2, 2*ones(4,1), 7*ones(4,1), v2);
            g2 = makeGrid('m', m2, 'n', n2, 'dx', dx2, 'dy', dy2, 'bc', struct('dc', 2, 'nc', 7));
            [Ag2, bg2] = addScalarBC(A2, b2, k, g2, v2);
            testCase.verifyLessThan(norm(Ae2 - Ag2, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(be2 - bg2), 1e-12);

            m3 = 10;
            n3 = 10;
            o3 = 10;
            dx3 = 0.21;
            dy3 = 0.16;
            dz3 = 0.13;
            A3 = speye((m3+2)*(n3+2)*(o3+2));
            b3 = zeros((m3+2)*(n3+2)*(o3+2), 1);
            v3 = {
                zeros(o3*n3, 1), ...
                zeros(o3*n3, 1), ...
                zeros(o3*(m3+2), 1), ...
                zeros(o3*(m3+2), 1), ...
                zeros((n3+2)*(m3+2), 1), ...
                zeros((n3+2)*(m3+2), 1)
            }';
            [Ae3, be3] = addScalarBC3D_impl(A3, b3, k, m3, dx3, n3, dy3, o3, dz3, 4*ones(6,1), ones(6,1), v3);
            g3 = makeGrid('m', m3, 'n', n3, 'o', o3, 'dx', dx3, 'dy', dy3, 'dz', dz3, 'bc', struct('dc', 4, 'nc', 1));
            [Ag3, bg3] = addScalarBC(A3, b3, k, g3, v3);
            testCase.verifyLessThan(norm(Ae3 - Ag3, 'fro'), 1e-12);
            testCase.verifyLessThan(norm(be3 - bg3), 1e-12);
        end

        function testAddScalarBCInvalidSignature(testCase)
            addpath('../../src/matlab_octave');
            % Unified addScalarBC only accepts (A, b, k, grid, v).
            A1 = speye(6); b1 = zeros(6, 1);
            testCase.verifyError(@() addScalarBC(A1, b1, 4, 10, [0; 0]), ...
                                 'addScalarBC:InvalidSignature');
        end

        function testBoundaryValueShapeValidation(testCase)
            addpath('../../src/matlab_octave');

            % 1D non-periodic: v must be a 2-by-1 column vector.
            k1 = 2;
            m1 = 20;
            dx1 = 1 / m1;
            A1 = speye(m1+2);
            b1 = zeros(m1+2, 1);
            dc1 = [1; 1];
            nc1 = [0; 0];
            v1Bad = [0; 0; 0];

            localVerifyFailsWithIdAndMessage(testCase, ...
                @() addScalarBC1D_impl(A1, b1, k1, m1, dx1, dc1, nc1, v1Bad), ...
                'addScalarBC1D:InvalidBoundaryValueSize', ...
                'v (1-D boundary values) expected size');

            % 2D case: periodic in x, Dirichlet in y.
            k = 2;
            m = 12;
            n = 9;
            dx = 1 / m;
            dy = 1 / n;
            A2 = speye((m+2)*(n+2));
            b2 = zeros((m+2)*(n+2), 1);
            dc2 = [0; 0; 1; 1];
            nc2 = [0; 0; 0; 0];

            v2BadBottom = {0; 0; zeros(m+2,1); zeros(m,1)};
            localVerifyFailsWithIdAndMessage(testCase, ...
                @() addScalarBC2D_impl(A2, b2, k, m, dx, n, dy, dc2, nc2, v2BadBottom), ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'v{3} (bottom boundary values) expected size');

            % 2D non-periodic x/y: left and right must be n-by-1.
            dc2np = [1; 1; 1; 1];
            nc2np = [0; 0; 0; 0];
            v2BadLeft = {zeros(n+1,1); zeros(n,1); zeros(m+2,1); zeros(m+2,1)};
            localVerifyFailsWithIdAndMessage(testCase, ...
                @() addScalarBC2D_impl(A2, b2, k, m, dx, n, dy, dc2np, nc2np, v2BadLeft), ...
                'addScalarBC2D:InvalidBoundaryValueSize', ...
                'v{1} (left boundary values) expected size');

            % 3D mismatch on front/back sizes.
            m3 = 8; n3 = 8; o3 = 8;
            dx3 = 1/m3; dy3 = 1/n3; dz3 = 1/o3;
            A3 = speye((m3+2)*(n3+2)*(o3+2));
            b3 = zeros((m3+2)*(n3+2)*(o3+2), 1);
            dc3 = [1; 1; 1; 1; 1; 1];
            nc3 = [0; 0; 0; 0; 0; 0];
            v3BadFront = {
                zeros(o3*n3,1); ...
                zeros(o3*n3,1); ...
                zeros(o3*(m3+2),1); ...
                zeros(o3*(m3+2),1); ...
                zeros((n3+2)*(m3+2)-1,1); ...
                zeros((n3+2)*(m3+2),1)
            };
            localVerifyFailsWithIdAndMessage(testCase, ...
                @() addScalarBC3D_impl(A3, b3, k, m3, dx3, n3, dy3, o3, dz3, dc3, nc3, v3BadFront), ...
                'addScalarBC3D:InvalidBoundaryValueSize', ...
                'v{5} (front boundary values) expected size');
        end

        function testDeprecatedBCFunctionsDeleted(testCase)
            addpath('../../src/matlab_octave');
            % Confirm all deprecated BC wrappers are gone.
            testCase.verifyError(@() robinBC(4, 10, 0.1, 1, 0),  'MATLAB:UndefinedFunction');
            testCase.verifyError(@() robinBC2D(4, 10, 0.1, 8, 0.125, 1, 0), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() robinBC3D(4, 10, 0.1, 8, 0.125, 6, 0.1, 1, 0), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() mixedBC(4, 10, 0.1, 'Dirichlet', 1, 'Neumann', 0), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() addScalarBC1D(sparse(6,6), zeros(6,1), 2, 4, 0.25, [1;1], [0;0], [0;0]), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() addScalarBC2D(sparse(16,16), zeros(16,1), 2, 4, 0.25, 3, 0.33, ones(4,1), zeros(4,1), {zeros(3,1);zeros(3,1);zeros(6,1);zeros(6,1)}), 'MATLAB:UndefinedFunction');
            testCase.verifyError(@() addScalarBC3D(sparse(64,64), zeros(64,1), 2, 4, 0.25, 3, 0.33, 4, 0.25, ones(6,1), zeros(6,1), {zeros(12,1);zeros(12,1);zeros(16,1);zeros(16,1);zeros(18,1);zeros(18,1)}), 'MATLAB:UndefinedFunction');
        end
    end
end

function localVerifyFailsWithIdAndMessage(testCase, fcn, expectedId, expectedSnippet)
    didThrow = false;
    try
        fcn();
    catch ME
        didThrow = true;
        testCase.verifyEqual(ME.identifier, expectedId, ...
            sprintf('Expected error id "%s", but got "%s".', expectedId, ME.identifier));
        testCase.verifyTrue(contains(ME.message, expectedSnippet), ...
            sprintf('Expected error message to contain "%s", but got: %s', expectedSnippet, ME.message));
    end
    testCase.verifyTrue(didThrow, 'Expected function to throw an error, but it did not.');
end
