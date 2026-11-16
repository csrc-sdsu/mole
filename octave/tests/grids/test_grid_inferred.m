function [passed, total] = test_grid_inferred()
% PURPOSE
% Test inferred grid attributes.
%
% SYNTAX
% test_grid_inferred()
% [passed, total] = test_grid_inferred()
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
        @testInferredDimension, ...
        @testInvalidDimensions, ...
        @testMissingFirstCellCount, ...
        @testMissingSecondCellCount, ...
        @testMissingThirdCellCount, ...
        @testConflictingSecondAxis, ...
        @testConflictingThirdAxis, ...
        @testInferredTopology, ...
        @testUnknownTopology, ...
        @testUniformGrid, ...
        @testCurvilinearGrid};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testInferredDimension()
    % Infer an omitted dimension from the grid fields.
    g = validate_clean(struct('m', 5, 'dx', .2, 'topology', 'uniform'));
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
end

function testInvalidDimensions()
    % Reject dimensions outside the supported range.
    for dim = [0,4]
        p = struct('dim', dim, 'topology', 'uniform', 'm', 5, 'dx', .2);
        expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');
    end
end

function testMissingFirstCellCount()
    % Require m for a one-dimensional grid.
    p = struct('dim', 1, 'topology', 'uniform');
    errors = MOLE_errors();
    expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
end

function testMissingSecondCellCount()
    % Require n for a two-dimensional grid.
    p = struct('dim', 2, 'topology', 'uniform', 'm', 5);
    errors = MOLE_errors();
    expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
end

function testMissingThirdCellCount()
    % Require o for a three-dimensional grid.
    p = struct('dim', 3, 'topology', 'uniform', 'm', 5, 'n', 5);
    errors = MOLE_errors();
    expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
end

function testConflictingSecondAxis()
    % Reject second-axis data in a one-dimensional grid.
    p = struct('dim', 1, 'topology', 'uniform', 'm', 5, 'n', 3, 'dx', .2);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');
end

function testConflictingThirdAxis()
    % Reject third-axis data in a two-dimensional grid.
    p = struct('dim', 2, 'topology', 'uniform', 'm', 5, 'n', 5, 'o', 3, 'dx', .2, 'dy', .2);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');
end

function testInferredTopology()
    % Infer uniform topology when topology is omitted.
    g = validate_clean(struct('dim', 1, 'm', 5, 'dx', .2));
    assert(isequal(g.topology, 'uniform'), 'Unexpected value for g.topology.');
end

function testUnknownTopology()
    % Reject an unknown topology.
    p = struct('dim', 1, 'topology', 'x', 'm', 5, 'dx', .2);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');
end

function testUniformGrid()
    % Validate a complete uniform one-dimensional grid without logging errors.
    g = validate_clean(struct('dim', 1, 'topology', 'uniform', 'm', 5, 'dx', .2));
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
end

function testCurvilinearGrid()
    % Validate a curvilinear two-dimensional grid with supplied nodes.
    [X,Y] = ndgrid(0:5,0:5);
    p = struct('dim', 2, 'topology', 'curvilinear', 'm', 5, 'n', 5);
    p.nodes = struct('X', X, 'Y', Y);
    g = validate_clean(p);
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
    assert(isequal(g.topology, 'curvilinear'), 'Unexpected value for g.topology.');
end
