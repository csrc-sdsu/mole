function [passed, total] = test_grid3D()
% PURPOSE
% Test three-dimensional grid validation and coordinates.
% SYNTAX
% [passed, total] = test_grid3D()
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
%! g = validate_clean(struct('topology', 'uniform', 'm', 3, 'n', 4, 'o', 2, 'dx', 1, 'dy', 1, 'dz', 1));
%! assert(g.dim, 3);


%!test
%! # Coordinate array dimensions follow the m, n, o axis order.
%! m = 3; n = 4; o = 2;
%! g = validate_clean(struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', 1, 'dy', 1, 'dz', 1));
%! assert(size(g.nodes.X), [m+1,n+1,o+1]);
%! assert(size(g.centers.X), [m+2,n+2,o+2]);
%! assert(size(g.faces.u.X), [m+1,n,o]);
%! assert(size(g.faces.v.X), [m,n+1,o]);
%! assert(size(g.faces.w.X), [m,n,o+1]);


%!test
%! # Preserve valid user-supplied uniform nodes.
%! m = 3; n = 4; o = 2; dx = 1; dy = 2; dz = .5;
%! [X,Y,Z] = ndgrid((0:m)*dx,(0:n)*dy,(0:o)*dz);
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', dx, 'dy', dy, 'dz', dz);
%! p.nodes = struct('X', X, 'Y', Y, 'Z', Z);
%! g = validate_clean(p);
%! assert(g.nodes.X, X);
%! assert(g.nodes.Y, Y);
%! assert(g.nodes.Z, Z);


%!test
%! # Reject supplied nodes with incorrect dimensions.
%! m = 3; n = 4; o = 2;
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, 'dx', 1, 'dy', 1, 'dz', 1);
%! p.nodes.X = zeros(n+1,m+1,o+1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');


%!test
%! # Reject negative cell spacing.
%! p = struct('topology', 'uniform', 'm', 2, 'n', 2, 'o', 2, 'dx', 1, 'dy', -1, 'dz', 1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');


%!test
%! # Reject a curvilinear grid without supplied nodes.
%! p = struct('topology', 'curvilinear', 'm', 2, 'n', 2, 'o', 2);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_CURVILINEAR_GRID');


%!test
%! # Include the spacing error code in the exception and update the logger.
%! errors = MOLE_errors();
%! p = struct('topology', 'uniform', 'm', 2, 'n', 2, 'o', 2, 'dx', 1, 'dy', -1, 'dz', 1);
%! err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
%! assert(errors.haveErrors(), true);
%! assert(errors.getNumErrors(), 1);
%! assert(~isempty(strfind(err.message, 'Code: 102')));

%!test
%! # Reject inconsistent supplied uniform coordinates on every axis.
%! m = 2; n = 3; o = 2;
%! [X, Y, Z] = ndgrid(0:m, 0:n, 0:o);
%! p = struct('topology', 'uniform', 'm', m, 'n', n, 'o', o, ...
%!            'dx', 1, 'dy', 1, 'dz', 1);
%! p.nodes = struct('X', X, 'Y', Y, 'Z', Z);
%! names = {'X', 'Y', 'Z'};
%! for i = 1:numel(names)
%!     q = p;
%!     values = q.nodes.(names{i});
%!     values(2, 2, 2) = 99;
%!     q.nodes.(names{i}) = values;
%!     expect_mole_error(@() validateGrid(q), 'MOLE_ERR_INVALID_NODAL_COORDINATES');
%! end
