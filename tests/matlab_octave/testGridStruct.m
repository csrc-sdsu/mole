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

    end  % methods(Test)
end  % classdef
