classdef testGridStruct < matlab.unittest.TestCase
% PURPOSE
% Unit tests for enriched grid struct coordinate arrays.
%
% DESCRIPTION
% Verifies that makeGrid and validateGrid populate grid.nodes,
% grid.faces, and grid.centers with correctly-sized meshgrid arrays
% for uniform 1-D, 2-D, and 3-D grids, curvilinear 2-D and 3-D grids,
% that size mismatches throw the correct error IDs, and that cell
% counts (m, n, o) and step sizes (dx, dy, dz) are validated.
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

        function test2DCurvilinearFacesFromNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            % Simple rectilinear node coords supplied as curvilinear
            [NX, NY] = ndgrid((0:m)*0.5, (0:n)*0.25);
            grid = makeGrid('m', m, 'n', n, 'dx', 0.5, 'dy', 0.25);
            grid.topology = 'curvilinear';
            grid.nodes.X = NX;
            grid.nodes.Y = NY;
            grid = validateGrid(grid);

            testCase.verifySize(grid.faces.u.X, [m+1, n]);
            testCase.verifySize(grid.faces.u.Y, [m+1, n]);
            testCase.verifySize(grid.faces.v.X, [m,   n+1]);
            testCase.verifySize(grid.faces.v.Y, [m,   n+1]);
            % u-face: average of adjacent nodes in y
            testCase.verifyEqual(grid.faces.u.X(1,1), 0.5*(NX(1,1)+NX(1,2)), 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.faces.u.Y(1,1), 0.5*(NY(1,1)+NY(1,2)), 'AbsTol', 1e-14);
            % v-face: average of adjacent nodes in x
            testCase.verifyEqual(grid.faces.v.X(1,1), 0.5*(NX(1,1)+NX(2,1)), 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.faces.v.Y(1,1), 0.5*(NY(1,1)+NY(2,1)), 'AbsTol', 1e-14);
        end

        function test2DCurvilinearCentersFromNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            [NX, NY] = ndgrid((0:m)*0.5, (0:n)*0.25);
            grid = makeGrid('m', m, 'n', n, 'dx', 0.5, 'dy', 0.25);
            grid.topology = 'curvilinear';
            grid.nodes.X = NX;
            grid.nodes.Y = NY;
            grid = validateGrid(grid);

            testCase.verifySize(grid.centers.X, [m, n]);
            testCase.verifySize(grid.centers.Y, [m, n]);
            % bilinear average of 4 surrounding nodes
            expectedX = 0.25*(NX(1,1)+NX(2,1)+NX(1,2)+NX(2,2));
            expectedY = 0.25*(NY(1,1)+NY(2,1)+NY(1,2)+NY(2,2));
            testCase.verifyEqual(grid.centers.X(1,1), expectedX, 'AbsTol', 1e-14);
            testCase.verifyEqual(grid.centers.Y(1,1), expectedY, 'AbsTol', 1e-14);
        end

        function test2DCurvilinearMissingNodesError(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            % Build a minimal curvilinear grid struct without nodes
            % (do NOT use makeGrid here, which would auto-populate nodes)
            grid = struct('m', m, 'n', n, 'dx', 0.5, 'dy', 0.25, ...
                          'topology', 'curvilinear', 'dim', 2);
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:CurvilinearMissingNodes');
        end

        function test2DNodeYSizeMismatchError(testCase)
            addpath('../../src/matlab_octave');
            m = 4; n = 5;
            good_X = zeros(m+1, n+1);
            bad_Y  = zeros(m+1, n);   % wrong: should be (m+1)×(n+1)
            grid = struct('m', m, 'n', n, 'dx', 1, 'dy', 1, ...
                          'topology', 'curvilinear', ...
                          'nodes', struct('X', good_X, 'Y', bad_Y));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:SizeMismatch');
        end

        function test2DCurvilinearAsymmetricMissingNodeFieldError(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            % Only nodes.X supplied; nodes.Y missing entirely (not just wrong size).
            grid = struct('m', m, 'n', n, 'topology', 'curvilinear', ...
                          'nodes', struct('X', zeros(m+1, n+1)));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:CurvilinearMissingNodes');
        end

        %% -- 3-D curvilinear grids ------------------------------------------

        function test3DCurvilinearMissingNodesError(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', 'dim', 3);
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:CurvilinearMissingNodes');
        end

        function test3DNodeSizeMismatchError(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            good = zeros(m+1, n+1, o+1);
            bad  = zeros(m+1, n+1, o);   % wrong: should be (m+1)x(n+1)x(o+1)
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', good, 'Y', bad, 'Z', good));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:SizeMismatch');
        end

        function test3DCurvilinearAsymmetricMissingNodeFieldError(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            % X and Y supplied; Z missing entirely.
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', zeros(m+1, n+1, o+1), 'Y', zeros(m+1, n+1, o+1)));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:CurvilinearMissingNodes');
        end

        function test3DCurvilinearFacesFromNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            [NX, NY, NZ] = ndgrid((0:m)*0.5, (0:n)*0.25, (0:o)*1.0);
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', NX, 'Y', NY, 'Z', NZ));
            grid = validateGrid(grid);

            testCase.verifySize(grid.faces.u.X, [m+1, n,   o  ]);
            testCase.verifySize(grid.faces.v.X, [m,   n+1, o  ]);
            testCase.verifySize(grid.faces.w.X, [m,   n,   o+1]);
            % u-face: bilinear average over y and z at fixed x-node
            expected = 0.25*(NX(1,1,1)+NX(1,2,1)+NX(1,1,2)+NX(1,2,2));
            testCase.verifyEqual(grid.faces.u.X(1,1,1), expected, 'AbsTol', 1e-14);
        end

        function test3DCurvilinearCentersFromNodes(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            [NX, NY, NZ] = ndgrid((0:m)*0.5, (0:n)*0.25, (0:o)*1.0);
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', NX, 'Y', NY, 'Z', NZ));
            grid = validateGrid(grid);

            testCase.verifySize(grid.centers.X, [m, n, o]);
            % trilinear average of the 8 surrounding nodes
            expected = 0.125*(NX(1,1,1)+NX(2,1,1)+NX(1,2,1)+NX(2,2,1)+ ...
                               NX(1,1,2)+NX(2,1,2)+NX(1,2,2)+NX(2,2,2));
            testCase.verifyEqual(grid.centers.X(1,1,1), expected, 'AbsTol', 1e-14);
        end

        %% -- grid.dim validation ----------------------------------------------

        function testInvalidDimRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('dim', 4, 'm', 5)), 'validateGrid:InvalidDim');
            testCase.verifyError(@() validateGrid(struct('dim', 0, 'm', 5)), 'validateGrid:InvalidDim');
        end

        %% -- Cell-count (m, n, o) validation ---------------------------------

        function testNonPositiveCellCountRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 0, 'dx', 1)),  'validateGrid:InvalidCellCount1D');
            testCase.verifyError(@() validateGrid(struct('m', -3, 'dx', 1)), 'validateGrid:InvalidCellCount1D');
        end

        function testNonIntegerCellCountRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 3.5, 'dx', 1)), 'validateGrid:InvalidCellCount1D');
        end

        function testNonPositiveCellCountRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 0, 'dx', 1, 'dy', 1)), ...
                                 'validateGrid:InvalidCellCount2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', -1, 'dx', 1, 'dy', 1, 'dz', 1)), ...
                                 'validateGrid:InvalidCellCount3D');
        end

        function testNonNumericCellCountRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 'a', 'dx', 1, 'dy', 1)), ...
                                 'validateGrid:InvalidCellCount2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', [1 2], 'dx', 1, 'dy', 1, 'dz', 1)), ...
                                 'validateGrid:InvalidCellCount3D');
        end

        function testComplexOrNonFiniteCellCountRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 3+2i, 'dx', 1, 'dy', 1)), ...
                                 'validateGrid:InvalidCellCount2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', NaN, 'dx', 1, 'dy', 1, 'dz', 1)), ...
                                 'validateGrid:InvalidCellCount3D');
        end

        %% -- Step-size (dx, dy, dz) validation --------------------------------

        function testNonPositiveSpacingRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', 0)),  'validateGrid:InvalidSpacing1D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', -1)), 'validateGrid:InvalidSpacing1D');
        end

        function testNonFiniteSpacingRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', NaN)), 'validateGrid:InvalidSpacing1D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', Inf)), 'validateGrid:InvalidSpacing1D');
        end

        function testNonNumericSpacingRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'dx', 'a')), 'validateGrid:InvalidSpacing1D');
        end

        function testNonPositiveSpacingRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'dx', 1, 'dy', -1)), ...
                                 'validateGrid:InvalidSpacing2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', 5, 'dx', 1, 'dy', 1, 'dz', 0)), ...
                                 'validateGrid:InvalidSpacing3D');
        end

        function testNonNumericOrNonScalarSpacingRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'dx', 1, 'dy', 'a')), ...
                                 'validateGrid:InvalidSpacing2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'dx', 1, 'dy', [1 2])), ...
                                 'validateGrid:InvalidSpacing2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', 5, 'dx', 1, 'dy', 1, 'dz', NaN)), ...
                                 'validateGrid:InvalidSpacing3D');
        end

        function testComplexOrNonFiniteSpacingRejected2D3D(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'dx', 1, 'dy', 1+2i)), ...
                                 'validateGrid:InvalidSpacing2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', 5, 'dx', 1, 'dy', 1, 'dz', Inf)), ...
                                 'validateGrid:InvalidSpacing3D');
        end

        %% -- Missing uniform-grid fields (m/n/o present, spacing absent) ------

        function testMissingUniformFieldsRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'topology', 'uniform')), ...
                                 'validateGrid:MissingUniform1D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'topology', 'uniform')), ...
                                 'validateGrid:MissingUniform2D');
            testCase.verifyError(@() validateGrid(struct('m', 5, 'n', 5, 'o', 5, 'topology', 'uniform')), ...
                                 'validateGrid:MissingUniform3D');
        end

        %% -- "nonuniform" topology removed: stray lowercase coordinate ------
        %% -- fields no longer produce a silent no-op ------------------------

        function testStrayLowercaseXFieldWithoutSpacingErrors1D(testCase)
            addpath('../../src/matlab_octave');
            % Previously inferred as topology='nonuniform' and silently
            % returned an unbuilt grid. Now reads as an incomplete uniform
            % grid (missing dx) and must error clearly.
            grid = struct('m', 5, 'x', (0:5)');
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:MissingUniform1D');
        end

        function testStrayLowercaseFieldsWithoutSpacingErrors2D(testCase)
            addpath('../../src/matlab_octave');
            grid = struct('m', 4, 'n', 5, 'x', (0:4)', 'y', (0:5)');
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:MissingUniform2D');
        end

        function testStrayLowercaseFieldsWithoutSpacingErrors3D(testCase)
            addpath('../../src/matlab_octave');
            grid = struct('m', 4, 'n', 5, 'o', 3, 'x', (0:4)', 'y', (0:5)', 'z', (0:3)');
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:MissingUniform3D');
        end

        %% -- Input struct shape validation ------------------------------------

        function testNonStructInputRejected(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() validateGrid(5), 'validateGrid:InvalidGrid');
        end

        function testNonScalarStructInputRejected(testCase)
            addpath('../../src/matlab_octave');
            badGrid = struct('m', {5, 6});   % 1x2 struct array, not a scalar struct
            testCase.verifyError(@() validateGrid(badGrid), 'validateGrid:InvalidGrid');
        end

        %% -- Conflicting metadata (explicit dim/topology vs. present fields) --

        function testExplicitDimConflictsWithPresentFieldsErrors(testCase)
            addpath('../../src/matlab_octave');
            % dim=1 explicit, but 'n' implies at least 2-D
            testCase.verifyError(@() validateGrid(struct('dim', 1, 'n', 5)), ...
                                 'validateGrid:DimMismatch');
            % dim=2 explicit, but 'o' implies 3-D
            testCase.verifyError(@() validateGrid(struct('dim', 2, 'o', 5)), ...
                                 'validateGrid:DimMismatch');
            % dim=1 explicit, but 'dz' implies 3-D
            testCase.verifyError(@() validateGrid(struct('dim', 1, 'dz', 0.1)), ...
                                 'validateGrid:DimMismatch');
        end

        function testExplicitTopologyConflictsWithLegacyFieldsErrors(testCase)
            addpath('../../src/matlab_octave');
            grid = struct('topology', 'uniform', 'X', zeros(2, 2));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:TopologyMismatch');
        end

        function testExplicitTopologyConflictsWithRawNodesErrors(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            [NX, NY] = ndgrid((0:m)*0.5, (0:n)*0.25);
            grid = struct('m', m, 'n', n, 'topology', 'uniform', ...
                          'nodes', struct('X', NX, 'Y', NY));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:TopologyMismatch');
        end

        function testCurvilinearInferredFromNestedNodesNoExplicitTopology(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            [NX, NY] = ndgrid((0:m)*0.5, (0:n)*0.25);
            grid = struct('m', m, 'n', n, 'nodes', struct('X', NX, 'Y', NY));
            grid = validateGrid(grid);
            testCase.verifyEqual(grid.topology, 'curvilinear');
            testCase.verifySize(grid.centers.X, [m, n]);
        end

        function testRevalidatedUniformGridNotFlaggedAsCurvilinear(testCase)
            addpath('../../src/matlab_octave');
            % grid.nodes.X/Y are validateGrid's own generated output here, not
            % raw caller input, and must not be mistaken for curvilinear evidence.
            grid = makeGrid('m', 4, 'n', 5, 'dx', 0.25, 'dy', 0.2);
            grid2 = validateGrid(grid);
            testCase.verifyEqual(grid2.topology, 'uniform');
        end

        %% -- Curvilinear node coordinate content validation -------------------

        function test2DCurvilinearNonNumericNodesRejected(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            grid = struct('m', m, 'n', n, 'topology', 'curvilinear', ...
                          'nodes', struct('X', false(m+1, n+1), 'Y', zeros(m+1, n+1)));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:InvalidCurvilinearNodes');
        end

        function test2DCurvilinearNaNNodesRejected(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4;
            X = zeros(m+1, n+1); X(1, 1) = NaN;
            grid = struct('m', m, 'n', n, 'topology', 'curvilinear', ...
                          'nodes', struct('X', X, 'Y', zeros(m+1, n+1)));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:InvalidCurvilinearNodes');
        end

        function test3DCurvilinearNonNumericNodesRejected(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', false(m+1, n+1, o+1), ...
                                          'Y', zeros(m+1, n+1, o+1), ...
                                          'Z', zeros(m+1, n+1, o+1)));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:InvalidCurvilinearNodes');
        end

        function test3DCurvilinearInfNodesRejected(testCase)
            addpath('../../src/matlab_octave');
            m = 3; n = 4; o = 2;
            Z = zeros(m+1, n+1, o+1); Z(end, end, end) = Inf;
            grid = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear', ...
                          'nodes', struct('X', zeros(m+1, n+1, o+1), ...
                                          'Y', zeros(m+1, n+1, o+1), ...
                                          'Z', Z));
            testCase.verifyError(@() validateGrid(grid), 'validateGrid:InvalidCurvilinearNodes');
        end

    end  % methods(Test)
end  % classdef
