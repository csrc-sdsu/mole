classdef testAddScalarBC < matlab.unittest.TestCase
    methods(Test)
        function testBC1D(testCase)
            addpath('../../src/matlab_octave');

            k = 2;
            dx = 0.1;
            m = 8;
            tol = 1e-10;

            A = (1/13)*reshape(1:(m+2)^2, m+2, m+2);
            b = (1/7)*(1:m+2)';

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

            Al = zeros(m + 2);
            Al(1,1) = dc1(1);
            Bl = zeros(m + 2, m + 1);
            Bl(1,1) = -nc1(1);

            Ar = zeros(m + 2);
            Ar(end,end) = dc1(2);
            Br = zeros(m + 2, m + 1);
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
            n = m + 2;
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
            b_ref(1,2:n+1) = bclr;
            b_ref(end,2:n+1) = bclr;
            b_ref(1:m+2,1) = bcbt;
            b_ref(1:m+2,end) = bcbt;
            b_ref = reshape(b_ref, [], 1);

            testCase.verifyEqual(A1, A_ref, ...
                "Matrix A with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
            testCase.verifyEqual(b1, b_ref, ...
                "Vector b with boundary conditions doesn't match expected result", ...
                'AbsTol', tol);
        end
        
        function testBC3D(testCase)
            addpath('../../src/matlab_octave');

            k = 2;
            dx = 0.1;
            dy = 0.1;
            dz = 0.1;
            m = 8;
            n = m + 2;
            o = n + 2;
            tol = 1e-10;

            A = 2*ones((m+2)*(n+2)*(o+2));
            b = 3*ones((m+2)*(n+2)*(o+2),1);

            bclr = 4*ones(n*o,1);
            bcbt = 5*ones((m+2)*o,1);
            bcfz = 6*ones((m+2)*(n+2),1);

            v = {bclr; bclr; bcbt; bcbt; bcfz; bcfz};

            % First test case: no boundary conditions
            
            dc0 = [0; 0; 0; 0; 0; 0];
            nc0 = [0; 0; 0; 0; 0; 0];
            
            [A0, b0] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc0, nc0, v);
            
            testCase.verifyEqual(A0, A, ...
                "Matrix A with no boundary conditions doesn't match expected result")
            testCase.verifyEqual(b0, b, ...
                "Vector b with no boundary conditions doesn't match expected result")

            % Second test case: with boundary conditions
            
            A = zeros((m+2)*(n+2)*(o+2));
            b = zeros((m+2)*(n+2)*(o+2), 1);
            
            dc1 = [2; 3; 4; 5; 6; 7];
            nc1 = [8; 9; 10; 11; 12; 13];
            
            [A1, b1] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc1, nc1, v);
            
            A_ref = A;
            b_ref = b;

            Gx = grad(k, m, dx);
            Gy = grad(k, n, dy);
            Gz = grad(k, o, dz);
            
            Im = eye(m + 2);
            
            In = eye(n + 2);
            In(1,1) = 0;
            In(end,end) = 0;
            
            Io = eye(o + 2);
            Io(1,1) = 0;
            Io(end,end) = 0;
            
            Al = zeros(m+2, m+2);
            Al(1,1) = dc1(1);
            Bl = zeros(m + 2, m + 1);
            Bl(1,1) = -nc1(1);
            
            Ar = zeros(m+2, m+2);
            Ar(end,end) = dc1(2);
            Br = zeros(m + 2, m + 1);
            Br(end,end) = nc1(2);
            
            Al = Al + Bl*Gx;
            Ar = Ar + Br*Gx;
            
            Abclr = kron(kron(Io, In), Al+Ar);
            
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
            
            Abcbt = kron(kron(Io, Ab+At), Im);
            
            Af = zeros(o + 2, o + 2);
            Af(1,1) = dc1(5);
            Bf = zeros(o + 2, o + 1);
            Bf(1,1) = -nc1(5);
            
            Az = zeros(o + 2, o + 2);
            Az(end,end) = dc1(6);
            Bz = zeros(o + 2, o + 1);
            Bz(end,end) = nc1(6);
            
            Af = Af + Bf*Gz;
            Az = Az + Bz*Gz;
            In(1,1) = 1;
            In(end,end) = 1;
            Abcfz = kron(kron(Af+Az, In), Im);
            
            A_ref = A_ref + Abclr + Abcbt + Abcfz;

            b_ref(1:(m+2)*(n+2)) = bcfz;
            b_ref((end-(m+2)*(n+2)+1):end) = bcfz;
            
            b_ref = reshape(b_ref, m+2, n+2, o+2);
            for i=1:o
                b_ref(1,2:n+1,i+1) = bclr(((i-1)*n+1):i*n);
                b_ref(end,2:n+1,i+1) = bclr(((i-1)*n+1):i*n);
                
                b_ref(1:m+2,1,i+1) = bcbt(((i-1)*(m+2)+1):i*(m+2));
                b_ref(1:m+2,end,i+1) = bcbt(((i-1)*(m+2)+1):i*(m+2));
            end
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