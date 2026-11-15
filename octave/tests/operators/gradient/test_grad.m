function [passed, total] = test_grad()
% PURPOSE
% Test one-dimensional gradient dispatch and error reporting.
% SYNTAX
% [passed, total] = test_grad()
% DESCRIPTION
% Exercises periodic and nonperiodic dispatch, optional logger arguments,
% grid validity errors, and integration with validateGrid.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    gradient_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Dispatch nonperiodic grids at every supported accuracy order.
%! grid = gradient_test_grid(17, .125, false);
%! for k = [2, 4, 6, 8]
%!     output = evalc('G = grad(k, grid);');
%!     output = evalc('expected = gradNonPeriodic(k, grid);');
%!     assert(size(G), [18, 19]);
%!     assert(G, expected);
%! end

%!test
%! # Accept an explicit logger without recording errors or printing output.
%! grid = gradient_test_grid(17, .125, false);
%! errors = MOLE_errors();
%! output = evalc('G = grad(4, grid, errors);');
%! assert(size(G), [18, 19]);
%! assert(errors.getNumErrors(), 0);
%! assert(errors.haveErrors(), false);
%! assert(isempty(output), ['Unexpected gradient output: ' output]);

%!test
%! # Dispatch periodic grids at every supported accuracy order.
%! grid = gradient_test_grid(17, .125, true);
%! for k = [2, 4, 6, 8]
%!     output = evalc('G = grad(k, grid);');
%!     output = evalc('expected = gradPeriodic(k, grid);');
%!     assert(size(G), [17, 17]);
%!     assert(G, expected);
%! end

%!test
%! # Preserve periodic dispatch when the logger is supplied explicitly.
%! grid = gradient_test_grid(17, .125, true);
%! errors = MOLE_errors();
%! output = evalc('G = grad(4, grid, errors);');
%! expectedOutput = evalc('expected = gradPeriodic(4, grid);');
%! assert(G, expected);
%! assert(errors.getNumErrors(), 0);
%! assert(errors.haveErrors(), false);
%! assert(isempty(output), ['Unexpected gradient output: ' output]);

%!test
%! # Accept a default nonperiodic grid returned by validateGrid.
%! grid = validateGrid(struct('topology', 'uniform', 'm', 17, 'dx', .125));
%! output = evalc('G = grad(4, grid);');
%! output = evalc('expected = gradNonPeriodic(4, grid);');
%! assert(size(G), [18, 19]);
%! assert(G, expected);

%!test
%! # Reject an odd accuracy order through the supplied logger.
%! grid = gradient_test_grid(17, .125, false);
%! errors = MOLE_errors();
%! expect_gradient_error(@() grad(3, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');

%!test
%! # Reject an even accuracy order without an implemented stencil.
%! grid = gradient_test_grid(21, .125, false);
%! errors = MOLE_errors();
%! expect_gradient_error(@() grad(10, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');

%!test
%! # Reject fewer than twice the requested accuracy order in cells.
%! grid = gradient_test_grid(7, .125, false);
%! errors = MOLE_errors();
%! expect_gradient_error(@() grad(4, grid, errors), errors, 'MOLE_ERR_OP_INSUFFICIENT_CELLS');

%!test
%! # Reject a grid flagged as invalid through the supplied logger.
%! grid = gradient_test_grid(17, .125, false);
%! grid.valid = false;
%! errors = MOLE_errors();
%! expect_gradient_error(@() grad(4, grid, errors), errors, 'MOLE_ERR_OP_GRID_HAS_ERRORS');

%!test
%! # Accept a periodic grid returned by validateGrid.
%! bc = struct('dc', zeros(2, 1), 'nc', zeros(2, 1));
%! params = struct('topology', 'uniform', 'm', 17, 'dx', .125, 'bc', bc);
%! grid = validateGrid(params);
%! output = evalc('G = grad(4, grid);');
%! output = evalc('expected = gradPeriodic(4, grid);');
%! assert(size(G), [17, 17]);
%! assert(G, expected);
