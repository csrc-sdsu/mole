function [passed, total] = test_grid2D()
% PURPOSE
% Test two-dimensional grid validation and coordinates.
%
% SYNTAX
% test_grid2D()
% [passed, total] = test_grid2D()
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
        @testCoordinateSizes, ...
        @testNodeCoordinates, ...
        @testSuppliedNodes, ...
        @testSuppliedNodeSize, ...
        @testInconsistentNodes, ...
        @testUnknownTopology, ...
        @testZeroSpacing, ...
        @testMissingCurvilinearNodes, ...
        @testSpacingErrorLogger};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testUniformGrid()
    % Validate a uniform grid with different cell counts on each axis.
    g = validate_clean(struct('topology', 'uniform', 'm', 3, 'n', 5, 'dx', 1, 'dy', 1));
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
end

function testCoordinateSizes()
    % Coordinate array dimensions follow the m, n axis order.
    m = 3; n = 5;
    g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1));
    assert(isequal(size(g.nodes.X), [m+1,n+1]), 'Unexpected value for size(g.nodes.X).');
    assert(isequal(size(g.nodes.Y), [m+1,n+1]), 'Unexpected value for size(g.nodes.Y).');
    assert(isequal(size(g.centers.X), [m+2,n+2]), 'Unexpected value for size(g.centers.X).');
    assert(isequal(size(g.faces.u.X), [m+1,n]), 'Unexpected value for size(g.faces.u.X).');
    assert(isequal(size(g.faces.v.X), [m,n+1]), 'Unexpected value for size(g.faces.v.X).');
end

function testNodeCoordinates()
    % Generate nodal coordinates from the spacing on each axis.
    m = 3; n = 4; dx = 1.5; dy = .5;
    g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'dx', dx, 'dy', dy));
    for i = 0:m
        for j = 0:n
            assert(isequal(g.nodes.X(i+1,j+1), i*dx), 'Unexpected value for g.nodes.X(i+1,j+1).');
            assert(isequal(g.nodes.Y(i+1,j+1), j*dy), 'Unexpected value for g.nodes.Y(i+1,j+1).');
        end
    end
end

function testSuppliedNodes()
    % Preserve valid user-supplied uniform nodes.
    m = 3; n = 5;
    [X,Y] = ndgrid(0:m,0:n);
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
    p.nodes = struct('X', X, 'Y', Y);
    g = validate_clean(p);
    assert(isequal(g.nodes.X, X), 'Unexpected value for g.nodes.X.');
    assert(isequal(g.nodes.Y, Y), 'Unexpected value for g.nodes.Y.');
end

function testSuppliedNodeSize()
    % Reject supplied nodes with transposed dimensions.
    m = 3; n = 5;
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
    p.nodes = struct('X', zeros(n+1,m+1), 'Y', zeros(n+1,m+1));
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');
end

function testInconsistentNodes()
    % Reject uniform nodes inconsistent with the cell spacing.
    m = 3; n = 5;
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
    p.nodes = struct('X', zeros(m+1,n+1), 'Y', zeros(m+1,n+1));
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_NODAL_COORDINATES');
end

function testUnknownTopology()
    % Reject an unknown topology.
    p = struct('topology', 'x', 'm', 3, 'n', 3, 'dx', 1, 'dy', 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');
end

function testZeroSpacing()
    % Reject zero cell spacing.
    p = struct('topology', 'uniform', 'm', 3, 'n', 3, 'dx', 0, 'dy', 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');
end

function testMissingCurvilinearNodes()
    % Reject a curvilinear grid without supplied nodes.
    p = struct('topology', 'curvilinear', 'm', 3, 'n', 3);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_CURVILINEAR_GRID');
end

function testSpacingErrorLogger()
    % Include the spacing error code in the exception and update the logger.
    errors = MOLE_errors();
    p = struct('topology', 'uniform', 'm', 3, 'n', 3, 'dx', 0, 'dy', 1);
    err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
    assert(isequal(errors.haveErrors(), true), 'Unexpected value for errors.haveErrors().');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
    assert(~isempty(strfind(err.message, 'Code: 102')));
end
