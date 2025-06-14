classdef testBCConsistency < matlab.unittest.TestCase
    methods(Test)
        function test1DCase(testCase)
            % 1D Boundary Conditions Consistency Test
            addpath('../../src/matlab_octave');
            
            k = 4;  % Order of accuracy
            m = 50; % Number of cells
            dx = 0.314; % Grid spacing

            % Dirichlet-Dirichlet Boundary Conditions
            RBC = robinBC(k, m, dx, 1, 0);
            MBC = mixedBC(k, m, dx, 'Dirichlet', 1, 'Dirichlet', 1);
            testCase.verifyEqual(RBC(1), MBC(1), "1D Dirichlet BCs do not match at west boundary");
            testCase.verifyEqual(RBC(end), MBC(end), "1D Dirichlet BCs do not match at east boundary");

            % Neumann-Neumann Boundary Conditions
            RBC = robinBC(k, m, dx, 0, 2);
            MBC = mixedBC(k, m, dx, 'Neumann', 2, 'Neumann', 2);
            testCase.verifyEqual(RBC(1, :), MBC(1, :), "1D Neumann BCs do not match at west boundary");
            testCase.verifyEqual(RBC(end, :), MBC(end, :), "1D Neumann BCs do not match at east boundary");

            % Robin-Robin Boundary Conditions
            RBC = robinBC(k, m, dx, 3, 4);
            MBC = mixedBC(k, m, dx, 'Robin', [3, 4], 'Robin', [3, 4]);
            testCase.verifyEqual(RBC(1, :), MBC(1, :), "1D Robin BCs do not match at west boundary");
            testCase.verifyEqual(RBC(end, :), MBC(end, :), "1D Robin BCs do not match at east boundary");

            % Mixed Robin BCs
            RBC2 = robinBC(k, m, dx, 5, 6);
            MBC = mixedBC(k, m, dx, 'Robin', [3, 4], 'Robin', [5, 6]);
            testCase.verifyEqual(RBC(1, :), MBC(1, :), "1D Mixed Robin BCs do not match at west boundary");
            testCase.verifyEqual(RBC2(end, :), MBC(end, :), "1D Mixed Robin BCs do not match at east boundary");
        end

        function test2DCase(testCase)
            % 2D Boundary Conditions Consistency Test
            addpath('../../src/matlab_octave');
            
            k = 4;  % Order of accuracy
            m = 50; % Number of cells (x-direction)
            n = 73; % Number of cells (y-direction)
            dx = 0.314; % x-direction grid spacing
            dy = 0.123; % y-direction grid spacing

            % Robin-Robin Boundary Conditions
            RBC = robinBC2D(k, m, dx, n, dy, 3, 4);
            MBC = mixedBC2D(k, m, dx, n, dy, 'Robin', [3, 4], 'Robin', [3, 4], 'Robin', [3, 4], 'Robin', [3, 4]);
            testCase.verifyEqual(RBC, MBC, "2D Robin BCs are not consistent");
        end

        function test3DCase(testCase)
            % 3D Boundary Conditions Consistency Test
            addpath('../../src/matlab_octave');
            
            k = 4;  % Order of accuracy
            m = 50; % Number of cells (x-direction)
            n = 73; % Number of cells (y-direction)
            o = 18; % Number of cells (z-direction)
            dx = 0.314; % x-direction grid spacing
            dy = 0.123; % y-direction grid spacing
            dz = 0.198; % z-direction grid spacing

            % Robin-Robin Boundary Conditions
            RBC = robinBC3D(k, m, dx, n, dy, o, dz, 6, 7);
            MBC = mixedBC3D(k, m, dx, n, dy, o, dz, 'Robin', [6, 7], 'Robin', [6, 7], ...
                'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7]);
            testCase.verifyEqual(RBC, MBC, "3D Robin BCs are not consistent");
        end
    end
end

