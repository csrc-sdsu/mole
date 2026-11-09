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
assert(caught, 'Expected invalid spacing to raise a MOLE exception.');
assert(errorObj.getNumErrors(), 1);
fprintf('Recorded errors: %d\n\n', errorObj.getNumErrors());

%% Corrected Spacing
fprintf('Attempt 2: dx = 1\n');
params.dx = 1;
errorObj = MOLE_errors();
grid = validateGrid(params, false, errorObj);
assert(size(grid.nodes.X), [4, 4]);
if size(grid.nodes.X) != [4, 4]
    
assert(errorObj.getNumErrors(), 0);
assert(errorObj.haveErrors(), false);
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Recorded errors: %d\n', errorObj.getNumErrors());

