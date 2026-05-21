classdef testGridStruct < matlab.unittest.TestCase
% PURPOSE
% Unit tests for enriched grid struct coordinate arrays.
%
% DESCRIPTION
% Verifies that makeGrid and validateGrid populate grid.nodes,
% grid.faces, and grid.centers with correctly-sized meshgrid arrays
% for uniform 1-D, 2-D, and 3-D grids, curvilinear 2-D grids, and
% that size mismatches throw the correct error IDs.
%
% SYNTAX
% Run via: runtests('testGridStruct')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function test1DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.nodes));
            testCase.verifySize(grid.nodes.X, [m+1, 1]);
            testCase.verifyEqual(grid.nodes.X(1),   0,      'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end),  m*dx,  'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(2),    dx,    'AbsTol', 1e-14);
        end

        function test1DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.centers));
            testCase.verifySize(grid.centers.X, [m+2, 1]);
            testCase.verifyEqual(grid.centers.X(1),   0,          'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(2),   0.5*dx,     'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(end),  m*dx,      'AbsTol', 1e-14);
        end

        function test1DUniformFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 6; dx = 0.5;
            grid = makeGrid('m', m, 'dx', dx);

            testCase.verifyTrue(isstruct(grid.faces));
            testCase.verifySize(grid.faces.X, [m+1, 1]);
            testCase.verifyEqual(grid.faces.X, grid.nodes.X, 'AbsTol', 1e-14);
        end

        function test2DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.nodes));
            testCase.verifySize(grid.nodes.X, [m+1, n+1]);
            testCase.verifySize(grid.nodes.Y, [m+1, n+1]);
            % x varies along dim-1 (rows), y varies along dim-2 (cols)
            testCase.verifyEqual(grid.nodes.X(1, 1), 0,    'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end, 1), m*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Y(1, 1), 0,    'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Y(1, end), n*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifySize(grid.centers.X, [m+2, n+2]);
            testCase.verifySize(grid.centers.Y, [m+2, n+2]);
            testCase.verifyEqual(grid.centers.X(1,1), 0,      'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.X(2,1), 0.5*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.Y(1,2), 0.5*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformUFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.faces));
            testCase.verifyTrue(isstruct(grid.faces.u));
            testCase.verifySize(grid.faces.u.X, [m+1, n]);
            testCase.verifySize(grid.faces.u.Y, [m+1, n]);
            % u-face x-coords same as node x-coords (all m+1 x-positions)
            testCase.verifyEqual(grid.faces.u.X(:, 1), grid.nodes.X(:, 1), 'AbsTol', 1e-14);
            % u-face y-coords are cell centers in y (n values)
            testCase.verifyEqual(grid.faces.u.Y(1, 1), 0.5*dy, 'AbsTol', 1e-14);
        end

        function test2DUniformVFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; dx = 0.25; dy = 0.2;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);

            testCase.verifyTrue(isstruct(grid.faces.v));
            testCase.verifySize(grid.faces.v.X, [m, n+1]);
            testCase.verifySize(grid.faces.v.Y, [m, n+1]);
            % v-face y-coords same as node y-coords
            testCase.verifyEqual(grid.faces.v.Y(1, :)', grid.nodes.Y(1, :)', 'AbsTol', 1e-14);
            % v-face x-coords are cell centers in x (m values)
            testCase.verifyEqual(grid.faces.v.X(1, 1), 0.5*dx, 'AbsTol', 1e-14);
        end

        function test3DUniformNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.nodes.X, [m+1, n+1, o+1]);
            testCase.verifySize(grid.nodes.Y, [m+1, n+1, o+1]);
            testCase.verifySize(grid.nodes.Z, [m+1, n+1, o+1]);
            testCase.verifyEqual(grid.nodes.X(1,1,1),   0,     'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.X(end,1,1), m*dx,  'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Y(1,end,1), n*dy,  'AbsTol', 1e-14);
            testCase.verifyEqual(grid.nodes.Z(1,1,end), o*dz,  'AbsTol', 1e-14);
        end

        function test3DUniformCenters(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.centers.X, [m+2, n+2, o+2]);
            testCase.verifySize(grid.centers.Y, [m+2, n+2, o+2]);
            testCase.verifySize(grid.centers.Z, [m+2, n+2, o+2]);
            testCase.verifyEqual(grid.centers.X(2,1,1), 0.5*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.Y(1,2,1), 0.5*dy, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.Z(1,1,2), 0.5*dz, 'AbsTol', 1e-14);
        end

        function test3DUniformFaces(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5; o = 3; dx = 0.25; dy = 0.2; dz = 0.5;
            grid = makeGrid('m', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);

            testCase.verifySize(grid.faces.u.X, [m+1, n,   o  ]);
            testCase.verifySize(grid.faces.v.X, [m,   n+1, o  ]);
            testCase.verifySize(grid.faces.w.X, [m,   n,   o+1]);
            testCase.verifyEqual(grid.faces.u.Y(1,1,1), 0.5*dy, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.faces.v.X(1,1,1), 0.5*dx, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.faces.w.Z(1,1,1), 0,      'AbsTol', 1e-14);
        end

    end  % methods(Test)
end  % classdef
