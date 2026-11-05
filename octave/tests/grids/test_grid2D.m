function [passed, total] = test_grid2D()
% PURPOSE
% Test two-dimensional grid validation and coordinates.
% SYNTAX
% [passed, total] = test_grid2D()
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
%! # Validate a uniform grid with different cell counts on each axis.
%! g = validate_clean(struct('topology', 'uniform', 'm', 3, 'n', 5, 'dx', 1, 'dy', 1));
%! assert(g.dim, 2);


%!test
%! # Coordinate array dimensions follow the m, n axis order.
%! m = 3; n = 5;
%! g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1));
%! assert(size(g.nodes.X), [m+1,n+1]);
%! assert(size(g.nodes.Y), [m+1,n+1]);
%! assert(size(g.centers.X), [m+2,n+2]);
%! assert(size(g.faces.u.X), [m+1,n]);
%! assert(size(g.faces.v.X), [m,n+1]);


%!test
%! # Generate nodal coordinates from the spacing on each axis.
%! m = 3; n = 4; dx = 1.5; dy = .5;
%! g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'dx', dx, 'dy', dy));
%! for i = 0:m
%!     for j = 0:n
%!         assert(g.nodes.X(i+1,j+1), i*dx);
%!         assert(g.nodes.Y(i+1,j+1), j*dy);
%!     end
%! end


%!test
%! # Preserve valid user-supplied uniform nodes.
%! m = 3; n = 5;
%! [X,Y] = ndgrid(0:m,0:n);
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
%! p.nodes = struct('X', X, 'Y', Y);
%! g = validate_clean(p);
%! assert(g.nodes.X, X);
%! assert(g.nodes.Y, Y);


%!test
%! # Reject supplied nodes with transposed dimensions.
%! m = 3; n = 5;
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
%! p.nodes = struct('X', zeros(n+1,m+1), 'Y', zeros(n+1,m+1));
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');


%!test
%! # Reject uniform nodes inconsistent with the cell spacing.
%! m = 3; n = 5;
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'dx', 1, 'dy', 1);
%! p.nodes = struct('X', zeros(m+1,n+1), 'Y', zeros(m+1,n+1));
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_NODAL_COORDINATES');


%!test
%! # Reject an unknown topology.
%! p = struct('topology', 'x', 'm', 3, 'n', 3, 'dx', 1, 'dy', 1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');


%!test
%! # Reject zero cell spacing.
%! p = struct('topology', 'uniform', 'm', 3, 'n', 3, 'dx', 0, 'dy', 1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');


%!test
%! # Reject a curvilinear grid without supplied nodes.
%! p = struct('topology', 'curvilinear', 'm', 3, 'n', 3);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_CURVILINEAR_GRID');


%!test
%! # Preserve periodic boundary flags.
%! p = struct('topology', 'uniform', 'm', 3, 'n', 3, 'dx', 1, 'dy', 1);
%! p.bc.isPeriodic = [true; false];
%! g = validate_clean(p);
%! assert(g.bc.isPeriodic, [true; false]);


%!test
%! # Include the spacing error code in the exception and update the logger.
%! errors = MOLE_errors();
%! p = struct('topology', 'uniform', 'm', 3, 'n', 3, 'dx', 0, 'dy', 1);
%! err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
%! assert(errors.haveErrors(), true);
%! assert(errors.getNumErrors(), 1);
%! assert(~isempty(strfind(err.message, 'Code: 102')));
