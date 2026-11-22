function [passed, total, testFunctions] = test_errors(runTests)
% PURPOSE
% Test MOLE error logging, validation, and abort behavior.
%
% SYNTAX
% test_errors()
% [passed, total] = test_errors()
% [~, total, testFunctions] = test_errors(false)
%
% DESCRIPTION
% Adds src/sys relative to this file when saved in tests/errors. Runs each
% test function with a fresh logger and prints individual results and a
% summary. Checks console output, identifiers, error counts, and input
% rejection using syntax shared by MATLAB and GNU Octave.
%
% Returns the number of successful tests and the total number of tests.
% When called without output arguments, raises MOLE:TEST_FAILURE if any
% test fails. All tests are attempted before reporting the overall failure.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    testDir = fileparts(mfilename('fullpath'));
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));
    addpath(fullfile(testDir, '..', '..', 'src', 'sys'));

    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end
    testFunctions = { ...
        @testMoleLogErrors, ...
        @testMoleLogErrorOutput, ...
        @testErrorStopExecution, ...
        @testInvalidErrorNameType, ...
        @testUnknownErrorName, ...
        @testInvalidLocationAndParamsTypes, ...
        @testInvalidAbortFlag, ...
        @testDefaultInputs, ...
        @testHaveErrors, ...
        @testAdditionalInvalidAbortFlags, ...
        @testIndependentErrorObjects, ...
        @testAbortMessage};

    total = numel(testFunctions);
    if ~runTests
        passed = 0;
        return;
    end
    passed = 0;
    for index = 1:total
        currentTest = testFunctions{index};
        testName = func2str(currentTest);
        try
            currentTest();
            passed = passed + 1;
            fprintf('%s: passed\n', testName);
        catch err
            fprintf('%s: failed [%s]\n%s\n', ...
                    testName, err.identifier, err.message);
        end
    end
    fprintf('\nPassed %d of %d tests.\n', passed, total);

    if nargout == 0 && passed ~= total
        error('MOLE:TEST_FAILURE', '%d of %d tests failed.', ...
              total - passed, total);
    end
end

function testMoleLogErrors()
    TestError = MOLE_errors();
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');

    params = 'numelem = 5 ';
    evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, params);');
    assert(isequal(TestError.getNumErrors(), 1), 'Unexpected number of recorded errors.');

    params = 'original numelem = 5, requested resize = 10';
    evalc('TestError.log_error(''MOLE_ERR_FAILED_ARRAY_RESIZE'', ''array1D Resize'', false, params);');
    assert(isequal(TestError.getNumErrors(), 2), 'Unexpected number of recorded errors.');

    params = 'grid spacing = -1';
    evalc('TestError.log_error(''MOLE_ERR_INVALID_GRID_SPACING'', ''grid1D[construct]'', false, params);');
    assert(isequal(TestError.getNumErrors(), 3), 'Unexpected number of recorded errors.');
end

function testMoleLogErrorOutput()
    TestError = MOLE_errors();
    params = 'numelem = 5 ';
    output = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, params);');
    expectedOutput = sprintf('========================================\nMOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: numelem = 5 \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n');

    assert(isequal(output, expectedOutput), 'Unexpected console output.');
    assert(isequal(TestError.getNumErrors(), 1), 'Unexpected number of recorded errors.');
end

function testErrorStopExecution()
    TestError = MOLE_errors();
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');

    params = 'numelem = 5 ';
    caughtId = '';
    try
        TestError.log_error('MOLE_ERR_INVALID_ARRAY_SIZE', 'array1D Construction', true, params);
    catch err
        caughtId = err.identifier;
    end
    assert(isequal(caughtId, 'MOLE:MOLE_ERR_INVALID_ARRAY_SIZE'), 'Unexpected exception identifier.');
    assert(isequal(TestError.getNumErrors(), 1), 'Unexpected number of recorded errors.');

    params = 'original numelem = 5, requested resize = 10';
    caughtId = '';
    try
        TestError.log_error('MOLE_ERR_FAILED_ARRAY_RESIZE', 'array1D Resize', true, params);
    catch err
        caughtId = err.identifier;
    end
    assert(isequal(caughtId, 'MOLE:MOLE_ERR_FAILED_ARRAY_RESIZE'), 'Unexpected exception identifier.');
    assert(isequal(TestError.getNumErrors(), 2), 'Unexpected number of recorded errors.');
end

function testInvalidErrorNameType()
    TestError = MOLE_errors();
    caughtId = '';
    try
        TestError.log_error(200, 'array1D Construction', false, 'numelem = 5');
    catch err
        caughtId = err.identifier;
    end
    assert(isequal(caughtId, 'MOLE:UNKNOWN_ERROR_NAME'), 'Unexpected exception identifier.');
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');
end

function testUnknownErrorName()
    TestError = MOLE_errors();
    caughtId = '';
    try
        TestError.log_error('MOLE_ERR_NOT_IN_MAP', 'array1D Construction', false, 'numelem = 5');
    catch err
        caughtId = err.identifier;
    end
    assert(isequal(caughtId, 'MOLE:UNKNOWN_ERROR_NAME'), 'Unexpected exception identifier.');
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');
end

function testInvalidLocationAndParamsTypes()
    TestError = MOLE_errors();
    locationOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', 25, false, ''numelem = 5'');');
    paramsOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, 25);');
    expectedOutput = sprintf('MOLE error location and params must be character arrays\n');

    assert(isequal(locationOutput, expectedOutput), 'Unexpected console output.');
    assert(isequal(paramsOutput, expectedOutput), 'Unexpected console output.');
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');
end

function testInvalidAbortFlag()
    TestError = MOLE_errors();
    typeOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', 5, ''numelem = 5'');');
    sizeOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', [true false], ''numelem = 5'');');
    expectedOutput = sprintf('onErrorAbort must be true or false\n');

    assert(isequal(typeOutput, expectedOutput), 'Unexpected console output.');
    assert(isequal(sizeOutput, expectedOutput), 'Unexpected console output.');
    assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');
end

function testDefaultInputs()
    TestError = MOLE_errors();
    output = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'');');
    expectedOutput = sprintf('========================================\nMOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n');

    assert(isequal(output, expectedOutput), 'Unexpected console output.');
    assert(isequal(TestError.getNumErrors(), 1), 'Unexpected number of recorded errors.');
end

function testHaveErrors()
    TestError = MOLE_errors();
    assert(isequal(TestError.haveErrors(), false), 'Unexpected recorded-error status.');
    evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, ''numelem = 5'');');
    assert(isequal(TestError.haveErrors(), true), 'Unexpected recorded-error status.');
end

function testAdditionalInvalidAbortFlags()
    TestError = MOLE_errors();
    invalidFlags = {0, 1, false(0, 0), true(2), [false; true]};
    expectedOutput = sprintf('onErrorAbort must be true or false\n');
    for index = 1:numel(invalidFlags)
        flag = invalidFlags{index};
        output = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', flag);');
        assert(isequal(output, expectedOutput), 'Unexpected console output.');
        assert(isequal(TestError.getNumErrors(), 0), 'Unexpected number of recorded errors.');
        assert(isequal(TestError.haveErrors(), false), 'Unexpected recorded-error status.');
    end
end

function testIndependentErrorObjects()
    first = MOLE_errors();
    second = MOLE_errors();
    evalc('first.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'');');
    assert(isequal(first.getNumErrors(), 1), 'Unexpected number of recorded errors.');
    assert(isequal(first.haveErrors(), true), 'Unexpected recorded-error status.');
    assert(isequal(second.getNumErrors(), 0), 'Unexpected number of recorded errors.');
    assert(isequal(second.haveErrors(), false), 'Unexpected recorded-error status.');
end

function testAbortMessage()
    TestError = MOLE_errors();
    caughtId = '';
    caughtMessage = '';
    try
        TestError.log_error('MOLE_ERR_INVALID_ARRAY_SIZE', 'array1D Construction', true, 'numelem = 5 ');
    catch err
        caughtId = err.identifier;
        caughtMessage = err.message;
    end
    % Normalize CRLF line endings and one optional terminal newline.
    caughtMessage = strrep(caughtMessage, sprintf('\r\n'), sprintf('\n'));
    if ~isempty(caughtMessage) && caughtMessage(end) == sprintf('\n')
        caughtMessage(end) = [];
    end
    expectedMessage = sprintf('Error: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: numelem = 5 \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1');
    assert(isequal(caughtId, 'MOLE:MOLE_ERR_INVALID_ARRAY_SIZE'), 'Unexpected exception identifier.');
    assert(isequal(caughtMessage, expectedMessage), 'Unexpected exception message.');
    assert(isequal(TestError.getNumErrors(), 1), 'Unexpected number of recorded errors.');
    assert(isequal(TestError.haveErrors(), true), 'Unexpected recorded-error status.');
end

