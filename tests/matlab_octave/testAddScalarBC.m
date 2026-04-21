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

            k = 2;
            dx = 0.1;
            dy = 0.1;
            m = 8;
            n = m + 12;
            tol = 1e-10;

            A = 2*ones((m+2)*(n+2));
            b = 3*ones((m+2)*(n+2),1);

            bclr = 4*ones(n,1);
            bcbt = 5*ones(m+2,1);

            v = {bclr; bclr; bcbt; bcbt};

            % First test case: no boundary conditions

            dc0 = [0; 0; 0; 0];
            nc0 = [0; 0; 0; 0];

            [A0, b0] = addScalarBC2D(A, b, k, m, dx, n, dy, dc0, nc0, v);

            testCase.verifyEqual(A0, A, ...
                "Matrix A with no boundary conditions doesn't match expected result")
            testCase.verifyEqual(b0, b, ...
                "Vector b with no boundary conditions doesn't match expected result")

            % Second test case: with boundary conditions

            A = zeros((m+2)*(n+2));
            b = zeros((m+2)*(n+2), 1);

            dc1 = [2; 3; 4; 5];
            nc1 = [6; 7; 8; 9];

            [A1, b1] = addScalarBC2D(A, b, k, m, dx, n, dy, dc1, nc1, v);

            A_ref = A;
            b_ref = b;

            Gx = grad(k, m, dx);
            In = eye(n + 2);
            In(1,1) = 0;
            In(end,end) = 0;

            Al = zeros(m + 2, m + 2);
            Al(1,1) = dc1(1);
            Bl = zeros(m + 2, m + 1);
            Bl(1,1) = -nc1(1);

            Ar = zeros(m + 2, m + 2);
            Ar(end,end) = dc1(2);
            Br = zeros(m + 2, m + 1);
            Br(end,end) = nc1(2);

            Al = Al + Bl*Gx;
            Ar = Ar + Br*Gx;
            Abclr = kron(In, Al + Ar);

            Gy = grad(k, n, dy);
            Im = eye(m + 2);
            
            Ab = zeros(n + 2, n + 2);
            Ab(1,1) = dc1(3);
            Bb = zeros(n + 2, n + 1);
            Bb(1,1) = -nc1(3);

            At = zeros(n + 2, n + 2);
            At(end,end) = dc1(4);
            Bt = zeros(n + 2, n + 1);
            Bt(end,end) = nc1(4);

            Ab = Ab + Bb*Gy;
            At = At + Bt*Gy;
            Abcbt = kron(Ab + At, Im);

            A_ref = A_ref + Abclr + Abcbt;

            b_ref = reshape(b_ref, m+2, n+2);
            b_ref(1,2:n+1) = v{1};
            b_ref(end,2:n+1) = v{2};
            b_ref(1:m+2,1) = v{3};
            b_ref(1:m+2,end) = v{4};
            b_ref = reshape(b_ref, [], 1);

            testCase.verifyEqual(A1, A_ref, ...
                "Matrix A with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
            testCase.verifyEqual(b1, b_ref, ...
                "Vector b with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
        end
        
    end
end