function [passed, total] = test_makeGrid()
% PURPOSE
% Test grid construction from structs and name/value pairs.
% SYNTAX
% [passed, total] = test_makeGrid()
% DESCRIPTION
% Adds the grid sources, error logger, and test helpers to the Octave path.
% Runs the embedded BIST cases with verbose output. passed is the number of
% successful cases; total is the number of cases executed.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    grid_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Construct a one-dimensional grid from name/value pairs.
%! output = evalc("g = makeGrid('dim', 1, 'm', 5, 'dx', .2, 'topology', 'uniform');");
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 1);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Construct a two-dimensional grid from name/value pairs.
%! output = evalc("g = makeGrid('dim', 2, 'm', 5, 'n', 5, 'dx', .2, 'dy', .2, 'topology', 'uniform');");
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 2);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Construct a three-dimensional grid from name/value pairs.
%! output = evalc("g = makeGrid('dim', 3, 'm', 5, 'n', 5, 'o', 5, 'dx', .2, 'dy', .2, 'dz', .2, 'topology', 'uniform');");
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 3);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Infer the dimension when omitted from name/value pairs.
%! g = makeGrid('m', 5, 'dx', .2, 'topology', 'uniform');
%! assert(g.dim, 1);


%!test
%! # Preserve supplied periodic boundary flags during construction.
%! bc = struct('isPeriodic', [true;false]);
%! g = makeGrid('dim', 2, 'm', 5, 'n', 5, 'dx', .2, 'dy', .2, 'topology', 'uniform', 'bc', bc);
%! assert(g.dim, 2);
%! assert(g.bc.isPeriodic, [true;false]);


%!test
%! # Reject a periodic flag vector with an incorrect length.
%! bc = struct('isPeriodic', true);
%! action = @() makeGrid('dim', 2, 'm', 5, 'n', 5, 'dx', .2, 'dy', .2, 'topology', 'uniform', 'bc', bc);
%! expect_mole_error(action, 'MOLE_ERR_INVALID_ISPERIODIC_DIM');


%!test
%! # Validate periodic flag length when boundary data precedes dimension.
%! bc = struct('isPeriodic', true);
%! action = @() makeGrid('bc', bc, 'dim', 2, 'm', 5, 'n', 5, 'dx', .2, 'dy', .2, 'topology', 'uniform');
%! expect_mole_error(action, 'MOLE_ERR_INVALID_ISPERIODIC_DIM');


%!test
%! # Construct a one-dimensional grid from a parameter struct.
%! p = struct('topology','uniform','m',4,'dx',1);
%! output = evalc('g = makeGrid(p);');
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 1);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Construct a two-dimensional grid from a parameter struct.
%! p = struct('topology','uniform','m',3,'n',4,'dx',1,'dy',1);
%! output = evalc('g = makeGrid(p);');
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 2);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Construct a three-dimensional grid from a parameter struct.
%! p = struct('topology','uniform','m',2,'n',3,'o',2,'dx',1,'dy',1,'dz',1);
%! output = evalc('g = makeGrid(p);');
%! assert(isstruct(g) && isscalar(g));
%! assert(g.dim, 3);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Construct a valid grid without printing an error report.
%! output = evalc("g = makeGrid(struct('topology','uniform','m',3,'n',3,'dx',1,'dy',1));");
%! assert(g.dim, 2);
%! assert(isempty(output), ['Unexpected constructor output: ' output]);


%!test
%! # Reject an unknown topology supplied in a parameter struct.
%! p = struct('topology','q','m',3,'n',3,'dx',1,'dy',1);
%! expect_mole_error(@() makeGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');

