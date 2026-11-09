%% Two-Dimensional Grid Validation Errors
%
% Validate an invalid grid, catch the MOLE exception, then correct the
% spacing and build a valid grid. Each validation uses a fresh logger.

% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Error Reporting
% Report unexpected results through the MOLE error catalog.
exampleErrors = MOLE_errors();

%% Problem Parameters

%% Problem Parameters
% m = n = 3 are the cell counts. dy = 1 is the y cell width.
% dx = 0 is intentionally invalid; dx = 1 gives the domain [0, 3]^2.
% Boundary metadata defaults to nonperiodic after correction.
params = struct('topology', 'uniform', 'm', 3, 'n', 3, ...
                'dx', 0, 'dy', 1);

%% Invalid Spacing
fprintf('Attempt 1: dx = 0\n');
errorObj = MOLE_errors();
caught = false;
try
    grid = validateGrid(params, false, errorObj);
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_GRID_SPACING')
        rethrow(err);
    end
    caught = true;
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end
if ~(caught)
    details = 'Expected invalid spacing to raise a MOLE exception.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'err_grid2D_basic', true, details);
end
if ~(isequal(errorObj.getNumErrors(), 1))
    details = sprintf('Expected logger count %s; received %s.', mat2str(1), mat2str(errorObj.getNumErrors()));
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'err_grid2D_basic', true, details);
end
fprintf('Recorded errors: %d\n\n', errorObj.getNumErrors());

%% Corrected Spacing
fprintf('Attempt 2: dx = 1\n');
params.dx = 1;
errorObj = MOLE_errors();
grid = validateGrid(params, false, errorObj);
if ~(isequal(size(grid.nodes.X), [4, 4]))
    details = 'Nodal coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_NODAL_SZ_MISMATCH', 'err_grid2D_basic', true, details);
end
if ~(isequal(errorObj.getNumErrors(), 0))
    details = sprintf('Expected logger count %s; received %s.', mat2str(0), mat2str(errorObj.getNumErrors()));
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'err_grid2D_basic', true, details);
end
if ~(isequal(errorObj.haveErrors(), false))
    details = 'The logger error flag does not match the expected reporting state.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'err_grid2D_basic', true, details);
end
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Recorded errors: %d\n', errorObj.getNumErrors());

