function [passed, total, testFunctions] = testValidateGridInputs(runTests)
% PURPOSE
% Test validate grid user inputs.
%
% SYNTAX
% testValidateGridInputs()
% [passed, total] = testValidateGridInputs()
% [~, total, testFunctions] = testValidateGridInputs(false)
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
    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end
    testFunctions = { ...
        @testGridOnly, ...
        @testAllowPartial, ...
        @testErrorLogger, ...
        @testInvalidInputTypes};
    total = numel(testFunctions);
    if ~runTests
        passed = 0;
        return;
    end
    grid_test_setup();
    [passed, total] = run_grid_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Incomplete', '%d of %d tests failed.', total - passed, total);
    end
end

function testGridOnly()
    % Call validate grid with grid struct only.
    p = struct('topology', 'uniform', 'm', 5, 'dx', .5);;
    g = validateGrid(p);
    assert(isequal(g.valid, true), 'Unexpected value for g.valid.');
end

function testAllowPartial()
    % Call validate grid with grid and allow partial. For second syntax case.
    p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
    g = validateGrid(p, true);
    assert(isequal(g.valid, true), 'Unexpected value for g.valid.');
end

function testErrorLogger()
    % Call validate grid with grid and error object. For thrid syntax case.
    p = struct('topology', 'uniform', 'm', 5, 'dx', .5);;
    errorObj = MOLE_errors();
    g = validateGrid(p, errorObj );
    assert(isequal(g.valid, true), 'Unexpected value for g.valid.');
end

function testInvalidInputTypes()
    % Call validate grid with invalid input types.
    p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
    errorObj = MOLE_errors();
    expect_mole_error(@() validateGrid(p, 56), 'MOLE_ERR_INVALID_INPUT_TYPE');
    expect_mole_error(@() validateGrid(p, false, true), 'MOLE_ERR_INVALID_INPUT_TYPE');
    expect_mole_error(@() validateGrid(p, errorObj, errorObj), 'MOLE_ERR_INVALID_INPUT_TYPE');
end

