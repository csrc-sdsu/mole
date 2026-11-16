function [passed, total] = test_gradNonPeriodic()
% PURPOSE
% Test nonperiodic gradient dimensions, accuracy, and input errors.
% SYNTAX
% [passed, total] = test_gradNonPeriodic()
% DESCRIPTION
% Exercises orders 2, 4, 6, and 8 with endpoint-padded cell-center data.
% Checks polynomial differentiation at boundary and interior nodes.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    gradient_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Construct sparse rectangular matrices at the accepted minimum count.
%! for k = [2, 4, 6, 8]
%!     m = 2*k;
%!     grid = struct('m', m, 'dx', 1/m, 'valid', true);
%!     output = evalc('G = gradNonPeriodic(k, grid);');
%!     assert(issparse(G));
%!     assert(size(G), [m+1, m+2]);
%!     assert(nnz(G) > 0);
%! end

%!test
%! # Differentiate a constant to zero, including both boundary nodes.
%! for k = [2, 4, 6, 8]
%!     m = 2*k + 1;
%!     grid = struct('m', m, 'dx', .125, 'valid', true);
%!     output = evalc('G = gradNonPeriodic(k, grid);');
%!     tolerance = 64*eps*max(1, norm(G, inf));
%!     assert(G*ones(m+2, 1), zeros(m+1, 1), tolerance);
%! end

%!test
%! # Differentiate polynomials through the requested accuracy order.
%! for k = [2, 4, 6, 8]
%!     m = 2*k; dx = 1/m;
%!     grid = struct('m', m, 'dx', dx, 'valid', true);
%!     centers = [0; ((1:m)' - .5)*dx; m*dx];
%!     nodes = (0:m)'*dx;
%!     output = evalc('G = gradNonPeriodic(k, grid);');
%!     for degree = 1:k
%!         values = centers.^degree;
%!         expected = degree*nodes.^(degree-1);
%!         tolerance = 256*eps*max(1, norm(G, inf)*norm(values, inf));
%!         assert(G*values, expected, tolerance);
%!     end
%! end

%!test
%! # Check convergence over boundary and interior derivative values.
%! for k = [2, 4, 6, 8]
%!     derivativeError = zeros(1, 2);
%!     for level = 1:2
%!         m = 32*2^(level-1); dx = 1/m;
%!         grid = struct('m', m, 'dx', dx, 'valid', true);
%!         centers = [0; ((1:m)' - .5)*dx; m*dx];
%!         nodes = (0:m)'*dx;
%!         output = evalc('G = gradNonPeriodic(k, grid);');
%!         derivativeError(level) = max(abs(G*sin(2*pi*centers) - 2*pi*cos(2*pi*nodes)));
%!     end
%!     assert(all(isfinite(derivativeError)));
%!     assert(derivativeError(1) > 0);
%!     assert(derivativeError(2) < derivativeError(1)/2^(k-1), ...
%!            sprintf('Nonperiodic gradient did not converge at order %d.', k));
%! end

%!test
%! # Valid calls accept either logger form and remain quiet.
%! grid = struct('m', 17, 'dx', .125, 'valid', true);
%! errors = MOLE_errors();
%! defaultOutput = evalc('reference = gradNonPeriodic(8, grid);');
%! explicitOutput = evalc('G = gradNonPeriodic(8, grid, errors);');
%! assert(G, reference);
%! assert(errors.getNumErrors(), 0);
%! assert(errors.haveErrors(), false);
%! assert(isempty(defaultOutput), ['Unexpected gradient output: ' defaultOutput]);
%! assert(isempty(explicitOutput), ['Unexpected gradient output: ' explicitOutput]);

%!test
%! # Reject too few cells for the requested order.
%! errors = MOLE_errors();
%! grid = struct('m', 7, 'dx', 1, 'valid', true);
%! expect_gradient_error(@() gradNonPeriodic(4, grid, errors), errors, 'MOLE_ERR_OP_INSUFFICIENT_CELLS');

%!test
%! # Reject an odd accuracy order.
%! errors = MOLE_errors();
%! grid = struct('m', 16, 'dx', 1, 'valid', true);
%! expect_gradient_error(@() gradNonPeriodic(3, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');

%!test
%! # Reject an unimplemented even accuracy order.
%! errors = MOLE_errors();
%! grid = struct('m', 21, 'dx', 1, 'valid', true);
%! expect_gradient_error(@() gradNonPeriodic(10, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');

%!test
%! # Reject an accuracy order below two.
%! errors = MOLE_errors();
%! grid = struct('m', 16, 'dx', 1, 'valid', true);
%! expect_gradient_error(@() gradNonPeriodic(0, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');

%!test
%! # Reject a grid flagged as invalid.
%! grid = gradient_test_grid(17, .125, false);
%! grid.valid = false;
%! errors = MOLE_errors();
%! expect_gradient_error(@() gradNonPeriodic(4, grid, errors), errors, 'MOLE_ERR_OP_GRID_HAS_ERRORS');
