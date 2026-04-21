classdef testAddScalarBC < matlab.unittest.TestCase
    methods(Test)
        function testBC1D(testCase)
            addpath('../../src/matlab_octave');

            k = 2;
            dx = 0.1;
            m = 8;
            n = m + 2;
            tol = 1e-10;

            A = (1/13)*reshape(1:(n*n), n, n);
            b = (1/7)*(1:n)';

            v = [7; 8];

            % First test case: no boundary conditions

            dc0 = [0; 0];
            nc0 = [0; 0];

            [A0, b0] = addScalarBC1D(A, b, k, m, dx, dc0, nc0, v);

            testCase.verifyEqual(A0, A, ...
                "Matrix A with no boundary conditions doesn't match expected result")
            testCase.verifyEqual(b0, b, ...
                "Vector b with no boundary conditions doesn't match expected result")

            % Second test case: with boundary conditions

            dc1 = [2; 3];
            nc1 = [4; 5];

            [A1, b1] = addScalarBC1D(A, b, k, m, dx, dc1, nc1, v);

            A_ref = A;
            b_ref = b;

            A_ref(1,:) = 0;
            A_ref(end,:) = 0;
            b_ref(1) = 0;
            b_ref(end) = 0;

            G = grad(k, m, dx);

            Al = zeros(n, n);
            Al(1,1) = dc1(1);
            Bl = zeros(n, m + 1);
            Bl(1,1) = -nc1(1);

            Ar = zeros(n, n);
            Ar(end,end) = dc1(2);
            Br = zeros(n, m + 1);
            Br(end,end) = nc1(2);

            A_ref = A_ref + (Al + Bl*G) + (Ar + Br*G);

            b_ref(1) = v(1);
            b_ref(end) = v(2);

            testCase.verifyEqual(A1, A_ref, ...
                "Matrix A with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
            testCase.verifyEqual(b1, b_ref, ...
                "Vector b with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
        end

        function testBC2D(testCase)
            addpath('../../src/matlab_octave');
        end
    end
end