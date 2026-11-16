function [passed, total] = testMakeGrid()
% PURPOSE
% Test curvilinear grid construction from supplied nodal coordinates.
%
% SYNTAX
% testMakeGrid()
% [passed, total] = testMakeGrid()
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
        @testSuppliedCurvilinearNodes};
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testSuppliedCurvilinearNodes()
    % Construct and revalidate a curvilinear grid from supplied nodes.
    m = 3; n = 4;
    [Xi, Eta] = ndgrid(0:m, 0:n);
    p = struct('m', m, 'n', n, 'topology', 'curvilinear');
    p.nodes = struct('X', Xi + Eta/4, 'Y', Eta);
    g = makeGrid(p);
    g = validate_clean(g);
    assert(isequal(g.dim, 2), 'Unexpected value for g.dim.');
    assert(isequal(g.topology, 'curvilinear'), 'Unexpected value for g.topology.');
    assert(isequal(g.nodes.X, p.nodes.X), 'Unexpected value for g.nodes.X.');
    assert(isequal(g.nodes.Y, p.nodes.Y), 'Unexpected value for g.nodes.Y.');
    [XiC, EtaC] = ndgrid(0.5:m-0.5, 0.5:n-0.5);
    assert(isequal(g.centers.X, XiC + EtaC/4), 'Unexpected value for g.centers.X.');
    assert(isequal(g.centers.Y, EtaC), 'Unexpected value for g.centers.Y.');
    [XiU, EtaU] = ndgrid(0:m, 0.5:n-0.5);
    assert(isequal(g.faces.u.X, XiU + EtaU/4), 'Unexpected value for g.faces.u.X.');
    assert(isequal(g.faces.u.Y, EtaU), 'Unexpected value for g.faces.u.Y.');
    [XiV, EtaV] = ndgrid(0.5:m-0.5, 0:n);
    assert(isequal(g.faces.v.X, XiV + EtaV/4), 'Unexpected value for g.faces.v.X.');
    assert(isequal(g.faces.v.Y, EtaV), 'Unexpected value for g.faces.v.Y.');
end
