function [passed, total] = test_grid_inferred()
% PURPOSE
% Test validate grid user inputs.
    grid_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Call validate grid with grid struct only.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', .5);;
%! g = validateGrid(p);
%! assert(g.valid,true);

%!test
%! # Call validate grid with grid and error object.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', .5);;
%! errorObj = MOLE_errors();
%! g = validateGrid(p, errorObj );
%! assert(g.valid, true);

%!test
%! # Call validate grid with grid and allow partial.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
%! g = validateGrid(p, true);
%! assert(g.valid, true);

%!test
%! # Call validate grid with invalid input types.
%! p = struct('topology', 'uniform', 'm', 5, 'dx', .5);
%! errorObj = MOLE_errors();
%! expect_mole_error(@() validateGrid(p, 56), 'MOLE_ERR_INVALID_INPUT_TYPE');
%! expect_mole_error(@() validateGrid(p, false, true), 'MOLE_ERR_INVALID_INPUT_TYPE');
%! expect_mole_error(@() validateGrid(p, errorObj, errorObj), 'MOLE_ERR_INVALID_INPUT_TYPE');
