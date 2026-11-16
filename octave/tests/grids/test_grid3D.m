function [passed, total] = test_grid3D()
% PURPOSE
% Test three-dimensional grid validation and coordinates.
%
% SYNTAX
% test_grid3D()
% [passed, total] = test_grid3D()
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
        @testSuppliedNodes, ...
        @testSuppliedNodeSize, ...
        @testInvalidSpacing, ...
        @testMissingCurvilinearNodes, ...
        @testSpacingErrorLogger, ...
        @testInconsistentNodes};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testUniformGrid()
    % Validate a uniform grid with different cell counts on each axis.
    g = validate_clean(struct('topology', 'uniform', 'm', 3, 'n', 4, 'o', 2, 'dx', 1, 'dy', 1, 'dz', 1));
    assert(isequal(g.dim, 3), 'Unexpected value for g.dim.');
end

function testCoordinateSizes()
    % Coordinate array dimensions follow the m, n, o axis order.
    m = 3; n = 4; o = 2;
    g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', 1, 'dy', 1, 'dz', 1));
    assert(isequal(size(g.nodes.X), [m+1,n+1,o+1]), 'Unexpected value for size(g.nodes.X).');
    assert(isequal(size(g.centers.X), [m+2,n+2,o+2]), 'Unexpected value for size(g.centers.X).');
    assert(isequal(size(g.faces.u.X), [m+1,n,o]), 'Unexpected value for size(g.faces.u.X).');
    assert(isequal(size(g.faces.v.X), [m,n+1,o]), 'Unexpected value for size(g.faces.v.X).');
    assert(isequal(size(g.faces.w.X), [m,n,o+1]), 'Unexpected value for size(g.faces.w.X).');
end

function testSuppliedNodes()
    % Preserve valid user-supplied uniform nodes.
    m = 3; n = 4; o = 2; dx = 1; dy = 2; dz = .5;
    [X,Y,Z] = ndgrid((0:m)*dx,(0:n)*dy,(0:o)*dz);
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);
    p.nodes = struct('X', X, 'Y', Y, 'Z', Z);
    g = validate_clean(p);
    assert(isequal(g.nodes.X, X), 'Unexpected value for g.nodes.X.');
    assert(isequal(g.nodes.Y, Y), 'Unexpected value for g.nodes.Y.');
    assert(isequal(g.nodes.Z, Z), 'Unexpected value for g.nodes.Z.');
end

function testSuppliedNodeSize()
    % Reject supplied nodes with incorrect dimensions.
    m = 3; n = 4; o = 2;
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', 1, 'dy', 1, 'dz', 1);
    p.nodes.X = zeros(n+1,m+1,o+1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');
end

function testInvalidSpacing()
    % Reject negative cell spacing.
    p = struct('topology', 'uniform', 'm', 2, 'n', 2, 'o', 2, 'dx', 1, 'dy', -1, 'dz', 1);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');
end

function testMissingCurvilinearNodes()
    % Reject a curvilinear grid without supplied nodes.
    p = struct('topology', 'curvilinear', 'm', 2, 'n', 2, 'o', 2);
    expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_CURVILINEAR_GRID');
end

function testSpacingErrorLogger()
    % Include the spacing error code in the exception and update the logger.
    errors = MOLE_errors();
    p = struct('topology', 'uniform', 'm', 2, 'n', 2, 'o', 2, 'dx', 1, 'dy', -1, 'dz', 1);
    err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
    assert(isequal(errors.haveErrors(), true), 'Unexpected value for errors.haveErrors().');
    assert(isequal(errors.getNumErrors(), 1), 'Unexpected value for errors.getNumErrors().');
    assert(~isempty(strfind(err.message, 'Code: 102')));
end

function testInconsistentNodes()
    % Reject inconsistent supplied uniform coordinates on every axis.
    m = 2; n = 3; o = 2;
    [X, Y, Z] = ndgrid(0:m, 0:n, 0:o);
    p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, ...
               'dx', 1, 'dy', 1, 'dz', 1);
    p.nodes = struct('X', X, 'Y', Y, 'Z', Z);
    names = {'X', 'Y', 'Z'};
    for i = 1:numel(names)
        q = p;
        values = q.nodes.(names{i});
        values(2, 2, 2) = 99;
        q.nodes.(names{i}) = values;
        expect_mole_error(@() validateGrid(q), 'MOLE_ERR_INVALID_NODAL_COORDINATES');
    end
end
