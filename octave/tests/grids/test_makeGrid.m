function [passed, total] = test_makeGrid()
% PURPOSE
% Test grid construction from structs and name/value pairs.
%
% SYNTAX
% test_makeGrid()
% [passed, total] = test_makeGrid()
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
        @testNameValueGrid1D, ...
        @testNameValueGrid2D, ...
        @testNameValueGrid3D, ...
        @testInferredDimension, ...
        @testStructGrid1D, ...
        @testStructGrid2D, ...
        @testStructGrid3D, ...
        @testQuietConstruction, ...
        @testUnknownTopology};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testNameValueGrid1D()
    % Construct a one-dimensional grid from name/value pairs.
    output = evalc('g = makeGrid(''dim'', 1, ''m'', 5, ''dx'', .2, ''topology'', ''uniform'');');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testNameValueGrid2D()
    % Construct a two-dimensional grid from name/value pairs.
    output = evalc('g = makeGrid(''dim'', 2, ''m'', 5, ''n'', 5, ''dx'', .2, ''dy'', .2, ''topology'', ''uniform'');');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testNameValueGrid3D()
    % Construct a three-dimensional grid from name/value pairs.
    output = evalc('g = makeGrid(''dim'', 3, ''m'', 5, ''n'', 5, ''o'', 5, ''dx'', .2, ''dy'', .2, ''dz'', .2, ''topology'', ''uniform'');');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 3), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testInferredDimension()
    % Infer the dimension when omitted from name/value pairs.
    g = makeGrid('m', 5, 'dx', .2, 'topology', 'uniform');
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
end

function testStructGrid1D()
    % Construct a one-dimensional grid from a parameter struct.
    p = struct('topology','uniform','m',4,'dx',1);
    output = evalc('g = makeGrid(p);');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 1), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testStructGrid2D()
    % Construct a two-dimensional grid from a parameter struct.
    p = struct('topology','uniform','m',3,'n',4,'dx',1,'dy',1);
    output = evalc('g = makeGrid(p);');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testStructGrid3D()
    % Construct a three-dimensional grid from a parameter struct.
    p = struct('topology','uniform','m',2,'n',3,'o',2,'dx',1,'dy',1,'dz',1);
    output = evalc('g = makeGrid(p);');
    assert(isstruct(g) && isscalar(g));
    assert(isequal(g.dim, 3), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testQuietConstruction()
    % Construct a valid grid without printing an error report.
    output = evalc('g = makeGrid(struct(''topology'',''uniform'',''m'',3,''n'',3,''dx'',1,''dy'',1));');
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
    assert(isempty(output), ['Unexpected constructor output: ' output]);
end

function testUnknownTopology()
    % Reject an unknown topology supplied in a parameter struct.
    p = struct('topology','q','m',3,'n',3,'dx',1,'dy',1);
    expect_mole_error(@() makeGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');
end
