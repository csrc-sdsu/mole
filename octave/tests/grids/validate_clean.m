function [grid, errors, output] = validate_clean(params)
% PURPOSE
% Validate a grid and require an empty error report.
% SYNTAX
% grid = validate_clean(params)
% [grid, errors, output] = validate_clean(params)
% DESCRIPTION
% params is a scalar grid parameter structure passed to validateGrid.
% Returns the validated grid, its fresh MOLE_errors logger, and captured
% console output. Requires zero recorded errors and no console output.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    errors = MOLE_errors();
    output = evalc('grid = validateGrid(params, false, errors);');
    assert(isstruct(grid) && isscalar(grid), 'Expected a scalar grid struct.');
    assert(errors.getNumErrors() == 0, ['Valid input recorded MOLE errors: ' output]);
    assert(errors.haveErrors(), false);
    assert(isempty(output), ['Valid input produced unexpected output: ' output]);
end
