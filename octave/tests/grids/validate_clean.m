function [grid, errors, output] = validate_clean(params)
% Validate a grid and require an empty error report.
% SPDX-License-Identifier: GPL-3.0-or-later
    errors = MOLE_errors();
    output = evalc('grid = validateGrid(params, false, errors);');
    assert(isstruct(grid) && isscalar(grid), 'Expected a scalar grid struct.');
    assert(errors.getNumErrors() == 0, ['Valid input recorded MOLE errors: ' output]);
    assert(errors.haveErrors(), false);
    assert(isempty(output), ['Valid input produced unexpected output: ' output]);
end
