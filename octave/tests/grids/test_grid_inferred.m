function [passed, total] = test_grid_inferred()
% PURPOSE
% Test inferred grid attributes.
    grid_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Infer an omitted dimension from the grid fields.
%! g = validate_clean(struct('m', 5, 'dx', .2, 'topology', 'uniform'));
%! assert(g.dim, 1);

%!test
%! # Reject dimensions outside the supported range.
%! for dim = [0,4]
%!     p = struct('dim', dim, 'topology', 'uniform', 'm', 5, 'dx', .2);
%!     expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');
%! end


%!test
%! # Require m for a one-dimensional grid.
%! p = struct('dim', 1, 'topology', 'uniform');
%! errors = MOLE_errors();
%! expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
%! assert(errors.getNumErrors(), 1);


%!test
%! # Require n for a two-dimensional grid.
%! p = struct('dim', 2, 'topology', 'uniform', 'm', 5);
%! errors = MOLE_errors();
%! expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
%! assert(errors.getNumErrors(), 1);


%!test
%! # Require o for a three-dimensional grid.
%! p = struct('dim', 3, 'topology', 'uniform', 'm', 5, 'n', 5);
%! errors = MOLE_errors();
%! expect_mole_error(@() validateGrid(p, false, errors), 'MOLE_ERR_INVALID_GRID_SIZE');
%! assert(errors.getNumErrors(), 1);


%!test
%! # Reject second-axis data in a one-dimensional grid.
%! p = struct('dim', 1, 'topology', 'uniform', 'm', 5, 'n', 3, 'dx', .2);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');


%!test
%! # Reject third-axis data in a two-dimensional grid.
%! p = struct('dim', 2, 'topology', 'uniform', 'm', 5, 'n', 5, 'o', 3, 'dx', .2, 'dy', .2);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_DIM');


%!test
%! # Infer uniform topology when topology is omitted.
%! g = validate_clean(struct('dim', 1, 'm', 5, 'dx', .2));
%! assert(g.topology, 'uniform');


%!test
%! # Reject an unknown topology.
%! p = struct('dim', 1, 'topology', 'x', 'm', 5, 'dx', .2);
%! expect_mole_error(@() validateGrid(p), 'MOLE_ERR_INVALID_GRID_TOPOLOGY');


%!test
%! # Validate a complete uniform one-dimensional grid without logging errors.
%! g = validate_clean(struct('dim', 1, 'topology', 'uniform', 'm', 5, 'dx', .2));
%! assert(g.dim, 1);


%!test
%! # Validate a curvilinear two-dimensional grid with supplied nodes.
%! [X,Y] = ndgrid(0:5,0:5);
%! p = struct('dim', 2, 'topology', 'curvilinear', 'm', 5, 'n', 5);
%! p.nodes = struct('X', X, 'Y', Y);
%! g = validate_clean(p);
%! assert(g.dim, 2);
%! assert(g.topology, 'curvilinear');
