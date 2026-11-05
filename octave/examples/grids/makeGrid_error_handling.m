%% Grid Construction Errors
%
% Catch individual construction errors and continue to the next example.
% MOLE exceptions identify the failed check through err.identifier and
% provide the formatted error details through err.message.

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

%% Problem Parameters
% dim selects the number of axes; m, n, o are cell counts and dx, dy
% are cell widths. The corrected input has m = n = 3 and dx = dy = 1,
% giving a nonperiodic grid on [0, 3]^2 with dim inferred as 2.

%% Incomplete Name/Value Pair
fprintf('Attempt 1: a name without its value\n');
caught = false;
try
    grid = makeGrid('m', 4, 'dx');
catch err
    if ~strcmp(err.identifier, 'MOLE:MAKE_GRID_INVALID_INPUT_ARGS')
        rethrow(err);
    end
    caught = true;
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end
assert(caught, 'Expected an incomplete-pair error.');

%% Field Conflicting with the Dimension
fprintf('Attempt 2: third-axis data in a two-dimensional grid\n');
caught = false;
try
    grid = makeGrid('dim', 2, 'm', 3, 'n', 3, 'o', 3, ...
                    'dx', 1, 'dy', 1, 'topology', 'uniform');
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_GRID_DIM')
        rethrow(err);
    end
    caught = true;
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end
assert(caught, 'Expected a conflicting-dimension error.');

%% Invalid Cell Count
fprintf('Attempt 3: zero cells\n');
caught = false;
try
    grid = makeGrid('dim', 1, 'm', 0, 'dx', 1, 'topology', 'uniform');
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_CELL_COUNT')
        rethrow(err);
    end
    caught = true;
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end
assert(caught, 'Expected an invalid-cell-count error.');

%% Valid Grid with Inferred Dimension
fprintf('Attempt 4: valid two-dimensional parameters\n');
grid = makeGrid('m', 3, 'n', 3, 'dx', 1, 'dy', 1, ...
                'topology', 'uniform');
assert(grid.dim, 2);
assert(size(grid.nodes.X), [4, 4]);
fprintf('Grid built OK, dimension = %d.\n', grid.dim);

