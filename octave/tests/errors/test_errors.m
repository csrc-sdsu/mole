%{
These are tests for our MOLE errors class.
The runner adds octave/src/sys relative to this file and runs all tests.
%}

function [passed, total] = test_errors()
    testDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(testDir, '..', '..', 'src', 'sys'));
    [passed, total] = test(mfilename('fullpath'), 'verbose');
    fprintf('\nPassed %d of %d tests.\n', passed, total);
endfunction

%!test
%! # testMoleLogErrors
%! # A fresh error object replaces MATLAB's TestMethodSetup.
%! TestError = MOLE_errors();
%! assert(TestError.getNumErrors(), 0);
%!
%! params = 'numelem = 5 ';
%! evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, params);');
%! assert(TestError.getNumErrors(), 1);
%!
%! params = 'original numelem = 5, requested resize = 10';
%! evalc('TestError.log_error(''MOLE_ERR_FAILED_ARRAY_RESIZE'', ''array1D Resize'', false, params);');
%! assert(TestError.getNumErrors(), 2);
%!
%! params = 'grid spacing = -1';
%! evalc('TestError.log_error(''MOLE_ERR_INVALID_GRID_SPACING'', ''grid1D[construct]'', false, params);');
%! assert(TestError.getNumErrors(), 3);

%!test
%! # testMoleLogErrorOutput
%! TestError = MOLE_errors();
%! params = 'numelem = 5 ';
%! output = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, params);');
%! expectedOutput = sprintf('========================================\nLogged MOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: numelem = 5 \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n');
%!
%! assert(output, expectedOutput);
%! assert(TestError.getNumErrors(), 1);

%!test
%! # testErrorStopExecution
%! TestError = MOLE_errors();
%! assert(TestError.getNumErrors(), 0);
%!
%! params = 'numelem = 5 ';
%! caughtId = '';
%! try
%!     TestError.log_error('MOLE_ERR_INVALID_ARRAY_SIZE', 'array1D Construction', true, params);
%! catch err
%!     caughtId = err.identifier;
%! end_try_catch
%! assert(caughtId, 'MOLE:MOLE_ERR_INVALID_ARRAY_SIZE');
%! assert(TestError.getNumErrors(), 1);
%!
%! params = 'original numelem = 5, requested resize = 10';
%! caughtId = '';
%! try
%!     TestError.log_error('MOLE_ERR_FAILED_ARRAY_RESIZE', 'array1D Resize', true, params);
%! catch err
%!     caughtId = err.identifier;
%! end_try_catch
%! assert(caughtId, 'MOLE:MOLE_ERR_FAILED_ARRAY_RESIZE');
%! assert(TestError.getNumErrors(), 2);

%!test
%! # testInvalidErrorNameType
%! TestError = MOLE_errors();
%! output = evalc('TestError.log_error(200, ''array1D Construction'', false, ''numelem = 5'');');
%! expectedOutput = sprintf('MOLE error name must be a character array\n');
%!
%! assert(output, expectedOutput);
%! assert(TestError.getNumErrors(), 0);

%!test
%! # testUnknownErrorName
%! TestError = MOLE_errors();
%! caughtId = '';
%! try
%!     TestError.log_error('MOLE_ERR_NOT_IN_MAP', 'array1D Construction', false, 'numelem = 5');
%! catch err
%!     caughtId = err.identifier;
%! end_try_catch
%! assert(caughtId, 'MOLE:UNKNOWN_ERROR_NAME');
%! assert(TestError.getNumErrors(), 0);

%!test
%! # testInvalidLocationAndParamsTypes
%! TestError = MOLE_errors();
%! locationOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', 25, false, ''numelem = 5'');');
%! paramsOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, 25);');
%! expectedOutput = sprintf('MOLE error location and params must be character arrays\n');
%!
%! assert(locationOutput, expectedOutput);
%! assert(paramsOutput, expectedOutput);
%! assert(TestError.getNumErrors(), 0);

%!test
%! # testInvalidAbortFlag
%! TestError = MOLE_errors();
%! typeOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', 1, ''numelem = 5'');');
%! sizeOutput = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', [true false], ''numelem = 5'');');
%! expectedOutput = sprintf('onErrorAbort must be true or false\n');
%!
%! assert(typeOutput, expectedOutput);
%! assert(sizeOutput, expectedOutput);
%! assert(TestError.getNumErrors(), 0);

%!test
%! # testDefaultInputs
%! TestError = MOLE_errors();
%! output = evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'');');
%! expectedOutput = sprintf('========================================\nLogged MOLE Error\n========================================\nError: MOLE_ERR_INVALID_ARRAY_SIZE\nCode: 200\nParams: \nLocations: array1D Construction\nMessage: Array dimensions need to be natural numbers >= 1\n');
%!
%! assert(output, expectedOutput);
%! assert(TestError.getNumErrors(), 1);

%!test
%! # testHaveErrors
%! TestError = MOLE_errors();
%! assert(TestError.haveErrors(), false);
%! evalc('TestError.log_error(''MOLE_ERR_INVALID_ARRAY_SIZE'', ''array1D Construction'', false, ''numelem = 5'');');
%! assert(TestError.haveErrors(), true);
