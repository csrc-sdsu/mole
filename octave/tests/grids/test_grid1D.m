function [passed, total] = test_grid1D()
% PURPOSE
% Test one-dimensional grid validation and coordinates.
%
% SYNTAX
% test_grid1D()
% [passed, total] = test_grid1D()
%
% DESCRIPTION
% Runs named test functions in MATLAB or GNU Octave and reports each result.
% Returns the number of successful cases and the total number of cases.
% Without output arguments, raises MOLETests:Incomplete if any case fails.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    grid_test_setup();
    testFunctions = { ...
        @testUniformGrid, ...
        @testNodeCoordinates, ...
        @testInvalidSpacing, ...
        @testUnknownTopology, ...
        @testOneDimensionalCurvilinear, ...
        @testFaceCoordinates, ...
        @testSuppliedNodes, ...
        @testSuppliedNodeSize, ...
        @testSpacingErrorLogger, ...
        @testInconsistentNodes};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testUniformGrid()
    % Generate a uniform one-dimensional grid.
    p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
    g = validate_clean(p);
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
    assert(isequal(numel(g.nodes.X), p.m + 1), 'Unexpected value for numel(g.nodes.X).');
    assert(isequal(numel(g.centers.X), p.m + 2), 'Unexpected value for numel(g.centers.X).');
end

function testNodeCoordinates()
    % Generate nodal coordinates from the cell spacing.
    p = struct('topology', 'uniform', 'm', 4, 'dx', 2);
    g = validate_clean(p);
    for i = 0:p.m
        assert(isequal(g.nodes.X(i+1), i*p.dx), 'Unexpected value for g.nodes.X(i+1).');
    end
end

function testInvalidSpacing()
    % Reject nonpositive cell spacing.
    p = struct('topology', 'uniform', 'm', 5, 'dx', -1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');
end

function testUnknownTopology()
    % Reject an unknown topology.
    p = struct('topology', 'z', 'm', 5, 'dx', 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');
end

function testOneDimensionalCurvilinear()
    % Reject curvilinear topology in one dimension.
    p = struct('topology', 'curvilinear', 'm', 5, 'dx', 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_1D_CURVILINEAR');
end

function testFaceCoordinates()
    % One-dimensional face and nodal coordinates agree.
    g = validate_clean(struct('topology', 'uniform', 'm', 3, 'dx', 1));
    assert(isequal(g.faces.X, g.nodes.X), 'Unexpected value for g.faces.X.');
end

function testSuppliedNodes()
    % Preserve valid user-supplied uniform nodes.
    p = struct('topology', 'uniform', 'm', 4, 'dx', .5);
    p.nodes.X = (0:p.m)'*p.dx;
    g = validate_clean(p);
    assert(isequal(g.nodes.X, p.nodes.X), 'Unexpected value for g.nodes.X.');
end

function testSuppliedNodeSize()
    % Reject supplied nodes with an incorrect size.
    p = struct('topology', 'uniform', 'm', 4, 'dx', .5);
    p.nodes.X = zeros(3,1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');
end

function testSpacingErrorLogger()
    % Record an aborting spacing error in the supplied logger.
    errors = MOLE_errors();
    p = struct('topology', 'uniform', 'm', 4, 'dx', 0);
    err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
    assert(isequal(errors.haveErrors(), true), 'Unexpected value for errors.haveErrors().');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
    assert(~isempty(strfind(err.message, 'MOLE_ERR_INVALID_GRID_SPACING')));
end

function testInconsistentNodes()
    % Reject supplied uniform nodes inconsistent with the cell spacing.
    p = struct('topology', 'uniform', 'm', 2, 'dx', 1);
    p.nodes.X = zeros(3, 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_NODAL_COORDINATES');
end
