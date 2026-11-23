function [passed, total, testFunctions] = test_grad(runTests)
% PURPOSE
% Test one-dimensional gradient dispatch and error reporting.
% SYNTAX
% test_grad()
% [passed, total] = test_grad()
% [~, total, testFunctions] = test_grad(false)
% DESCRIPTION
% Exercises periodic and nonperiodic dispatch, optional logger arguments,
% grid validity errors, and integration with validateGrid.
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
        @testNonperiodicDispatch, ...
        @testExplicitLogger, ...
        @testPeriodicDispatch, ...
        @testExplicitPeriodicLogger, ...
        @testValidatedNonperiodicGrid, ...
        @testOddOrder, ...
        @testUnsupportedEvenOrder, ...
        @testInsufficientCells, ...
        @testInvalidGrid, ...
        @testValidatedPeriodicGrid};
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

function testNonperiodicDispatch()
    % Dispatch nonperiodic grids at every supported accuracy order.
    grid = gradient_test_grid(17, .125, false);
    for k = [2, 4, 6, 8]
        output = evalc('G = grad(k, grid);');
        output = evalc('expected = gradNonPeriodic(k, grid);');
        assert(isequal(size(G), [18, 19]), 'Unexpected value for size(G).');
        assert(isequal(G, expected), 'Unexpected value for G.');
    end
end

function testExplicitLogger()
    % Accept an explicit logger without recording errors or printing output.
    grid = gradient_test_grid(17, .125, false);
    errors = MOLE_errors();
    output = evalc('G = grad(4, grid, errors);');
    assert(isequal(size(G), [18, 19]), 'Unexpected value for size(G).');
    assert(isequal(errors.getNumErrors(), 0), 'Unexpected value for errors.getNumErrors().');
    assert(isequal(errors.haveErrors(), false), 'Unexpected value for errors.haveErrors().');
    assert(isempty(output), ['Unexpected gradient output: ' output]);
end

function testPeriodicDispatch()
    % Dispatch periodic grids at every supported accuracy order.
    grid = gradient_test_grid(17, .125, true);
    for k = [2, 4, 6, 8]
        output = evalc('G = grad(k, grid);');
        output = evalc('expected = gradPeriodic(k, grid);');
        assert(isequal(size(G), [17, 17]), 'Unexpected value for size(G).');
        assert(isequal(G, expected), 'Unexpected value for G.');
    end
end

function testExplicitPeriodicLogger()
    % Preserve periodic dispatch when the logger is supplied explicitly.
    grid = gradient_test_grid(17, .125, true);
    errors = MOLE_errors();
    output = evalc('G = grad(4, grid, errors);');
    expectedOutput = evalc('expected = gradPeriodic(4, grid);');
    assert(isequal(G, expected), 'Unexpected value for G.');
    assert(isequal(errors.getNumErrors(), 0), 'Unexpected value for errors.getNumErrors().');
    assert(isequal(errors.haveErrors(), false), 'Unexpected value for errors.haveErrors().');
    assert(isempty(output), ['Unexpected gradient output: ' output]);
end

function testValidatedNonperiodicGrid()
    % Accept a default nonperiodic grid returned by validateGrid.
    grid = validateGrid(struct('topology', 'uniform', 'm', 17, 'dx', .125));
    output = evalc('G = grad(4, grid);');
    output = evalc('expected = gradNonPeriodic(4, grid);');
    assert(isequal(size(G), [18, 19]), 'Unexpected value for size(G).');
    assert(isequal(G, expected), 'Unexpected value for G.');
end

function testOddOrder()
    % Reject an odd accuracy order through the supplied logger.
    grid = gradient_test_grid(17, .125, false);
    errors = MOLE_errors();
    expect_gradient_error(@() grad(3, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');
end

function testUnsupportedEvenOrder()
    % Reject an even accuracy order without an implemented stencil.
    grid = gradient_test_grid(21, .125, false);
    errors = MOLE_errors();
    expect_gradient_error(@() grad(10, grid, errors), errors, 'MOLE_ERR_OP_INVALID_ORDER');
end

function testInsufficientCells()
    % Reject fewer than twice the requested accuracy order in cells.
    grid = gradient_test_grid(7, .125, false);
    errors = MOLE_errors();
    expect_gradient_error(@() grad(4, grid, errors), errors, 'MOLE_ERR_OP_INSUFFICIENT_CELLS');
end

function testInvalidGrid()
    % Reject a grid flagged as invalid through the supplied logger.
    grid = gradient_test_grid(17, .125, false);
    grid.valid = false;
    errors = MOLE_errors();
    expect_gradient_error(@() grad(4, grid, errors), errors, 'MOLE_ERR_OP_GRID_HAS_ERRORS');
end

function testValidatedPeriodicGrid()
    % Accept a periodic grid returned by validateGrid.
    bc = struct('dc', zeros(2, 1), 'nc', zeros(2, 1));
    params = struct('topology', 'uniform', 'm', 17, 'dx', .125, 'bc', bc);
    grid = validateGrid(params);
    output = evalc('G = grad(4, grid);');
    output = evalc('expected = gradPeriodic(4, grid);');
    assert(isequal(size(G), [17, 17]), 'Unexpected value for size(G).');
    assert(isequal(G, expected), 'Unexpected value for G.');
end
