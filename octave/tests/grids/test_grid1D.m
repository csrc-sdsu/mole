function [passed, total] = test_grid1D()
% PURPOSE
% Test one-dimensional grid validation and coordinates.
% SYNTAX
% [passed, total] = test_grid1D()
% SPDX-License-Identifier: GPL-3.0-or-later
    grid_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Generate a uniform one-dimensional grid.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
%! g = validate_clean(p);
%! assert(g.dim, 1);
%! assert(numel(g.nodes.X), p.m + 1);
%! assert(numel(g.centers.X), p.m + 2);


%!test
%! # Generate nodal coordinates from the cell spacing.
%! p = struct('topology', 'uniform', 'm', 4, 'dx', 2);
%! g = validate_clean(p);
%! for i = 0:p.m
%!     assert(g.nodes.X(i+1), i*p.dx);
%! end


%!test
%! # Reject nonpositive cell spacing.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', -1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_SPACING');


%!test
%! # Reject an unknown topology.
%! p = struct('topology', 'z', 'm', 5, 'dx', 1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');


%!test
%! # Reject curvilinear topology in one dimension.
%! p = struct('topology', 'curvilinear', 'm', 5, 'dx', 1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_1D_CURVILINEAR');


%!test
%! # One-dimensional face and nodal coordinates agree.
%! g = validate_clean(struct('topology', 'uniform', 'm', 3, 'dx', 1));
%! assert(g.faces.X, g.nodes.X);


%!test
%! # Preserve valid user-supplied uniform nodes.
%! p = struct('topology', 'uniform', 'm', 4, 'dx', .5);
%! p.nodes.X = (0:p.m)'*p.dx;
%! g = validate_clean(p);
%! assert(g.nodes.X, p.nodes.X);


%!test
%! # Reject supplied nodes with an incorrect size.
%! p = struct('topology', 'uniform', 'm', 4, 'dx', .5);
%! p.nodes.X = zeros(3,1);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_GRID_NODAL_SZ_MISMATCH');


%!test
%! # Record an aborting spacing error in the supplied logger.
%! errors = MOLE_errors();
%! p = struct('topology', 'uniform', 'm', 4, 'dx', 0);
%! err = expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SPACING');
%! assert(errors.haveErrors(), true);
%! assert(errors.getNumErrors(), 1);
%! assert(~isempty(strfind(err.message, 'MOLE_ERR_INVALID_GRID_SPACING')));
