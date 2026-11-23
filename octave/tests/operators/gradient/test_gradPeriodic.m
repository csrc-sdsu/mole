function [passed, total, testFunctions] = test_gradPeriodic(runTests)
% PURPOSE
% Test periodic gradient dimensions, differentiation, and input errors.
% SYNTAX
% test_gradPeriodic()
% [passed, total] = test_gradPeriodic()
% [~, total, testFunctions] = test_gradPeriodic(false)
% DESCRIPTION
% Exercises orders 2, 4, 6, and 8 using unique periodic cell centers and
% compares derivatives with an analytical periodic function.
% Runs named cases in MATLAB or GNU Octave and reports every result.
% Passing false lists case handles without executing them.
% Without output arguments, raises MOLETests:Failed if any case fails.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end
    testFunctions = { ...
        @testSparseMatrixDimensions, ...
        @testConstantDerivative, ...
        @testPeriodicWraparound, ...
        @testConvergence, ...
        @testLoggerForms, ...
        @testInsufficientCells, ...
        @testOddOrder, ...
        @testUnsupportedEvenOrder, ...
        @testOrderBelowTwo, ...
        @testInvalidGrid};
    total = numel(testFunctions);
    if ~runTests
        passed = 0;
        return;
    end
    gradient_test_setup();
    [passed, total] = run_gradient_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Failed', '%d of %d gradient test cases failed.', total - passed, total);
    end
end

function testSparseMatrixDimensions()
    % Construct sparse square matrices at the accepted minimum cell count.
    for k = [2, 4, 6, 8]
        m = 2*k;
        grid = struct('m', m, 'dx', 1/m, 'valid', true);
        output = evalc('G = gradPeriodic(k, grid);');
        assert(issparse(G));
        assert(isequal(size(G), [m, m]), 'Unexpected value for size(G).');
        assert(nnz(G) > 0);
    end
end

function testConstantDerivative()
    % Differentiate a constant to zero at every periodic node.
    for k = [2, 4, 6, 8]
        m = 2*k + 1;
        grid = struct('m', m, 'dx', 1/m, 'valid', true);
        output = evalc('G = gradPeriodic(k, grid);');
        tolerance = 64*eps*max(1, norm(G, inf));
        assert_gradient_close(G*ones(m, 1), zeros(m, 1), tolerance);
    end
end

function testPeriodicWraparound()
    % Second-order differences wrap from the last center to the first.
    m = 8; dx = .25;
    grid = struct('m', m, 'dx', dx, 'valid', true);
    u = sin((1:m)') + cos(2*(1:m)');
    output = evalc('G = gradPeriodic(2, grid);');
    expected = (u - circshift(u, 1))/dx;
    tolerance = 64*eps*max(1, norm(G, inf)*norm(u, inf));
    assert_gradient_close(G*u, expected, tolerance);
end

function testConvergence()
    % Refinement produces the expected order of periodic differentiation.
    for k = [2, 4, 6, 8]
        derivativeError = zeros(1, 2);
        for level = 1:2
            m = 32*2^(level-1); dx = 1/m;
            grid = struct('m', m, 'dx', dx, 'valid', true);
            centers = ((0:m-1)' + .5)*dx;
            nodes = (0:m-1)'*dx;
            output = evalc('G = gradPeriodic(k, grid);');
            derivativeError(level) = max(abs(G*sin(2*pi*centers) - 2*pi*cos(2*pi*nodes)));
        end
        assert(all(isfinite(derivativeError)));
        assert(derivativeError(1) > 0);
        assert(derivativeError(2) < derivativeError(1)/2^(k-1), ...
               sprintf('Periodic gradient did not converge at order %d.', k));
    end
end

function testLoggerForms()
    % Valid calls accept either logger form and remain quiet.
    grid = struct('m', 17, 'dx', .125, 'valid', true);
    errors = MOLE_errors();
    defaultOutput = evalc('reference = gradPeriodic(8, grid);');
    explicitOutput = evalc('G = gradPeriodic(8, grid, errors);');
    assert(isequal(G, reference), 'Unexpected value for G.');
    assert(isequal(errors.getNumErrors(), 0), 'Unexpected value for errors.getNumErrors().');
    assert(isequal(errors.haveErrors(), false), 'Unexpected value for errors.haveErrors().');
    assert(isempty(defaultOutput), ['Unexpected gradient output: ' defaultOutput]);
    assert(isempty(explicitOutput), ['Unexpected gradient output: ' explicitOutput]);
end

function testInsufficientCells()
    % Reject too few cells for the requested order.
    errors = MOLE_errors();
    grid = struct('m', 7, 'dx', 1, 'valid', true);
    expect_gradient_error(@() gradPeriodic(4, grid, errors), errors, 'MOLE_ERR_OP_INSUFFICIENT_CELLS');
end

function testOddOrder()
    % Reject an odd accuracy order.
    errors = MOLE_errors();
    grid = struct('m', 16, 'dx', 1, 'valid', true);
    expect_gradient_error(@() gradPeriodic(3, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');
end

function testUnsupportedEvenOrder()
    % Reject an unimplemented even accuracy order.
    errors = MOLE_errors();
    grid = struct('m', 21, 'dx', 1, 'valid', true);
    expect_gradient_error(@() gradPeriodic(10, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');
end

function testOrderBelowTwo()
    % Reject an accuracy order below two.
    errors = MOLE_errors();
    grid = struct('m', 16, 'dx', 1, 'valid', true);
    expect_gradient_error(@() gradPeriodic(0, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');
end

function testInvalidGrid()
    % Reject a grid flagged as invalid.
    grid = gradient_test_grid(17, .125, true);
    grid.valid = false;
    errors = MOLE_errors();
    expect_gradient_error(@() gradPeriodic(4, grid, errors), errors, 'MOLE_ERR_OP_GRID_HAS_ERRORS');
end
