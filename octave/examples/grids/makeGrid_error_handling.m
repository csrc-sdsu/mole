%% Grid Construction Errors
%
% Catch individual construction errors and continue to the next example.
% MOLE exceptions identify the failed check through err.identifier and
% provide the formatted error details through err.message.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Incomplete Name/Value Pair
fprintf('Attempt 1: a name without its value\n');
try
    grid = makeGrid('m', 4, 'dx');
catch err
    if ~strcmp(err.identifier, 'MOLE:MAKE_GRID_INVALID_INPUT_ARGS')
        rethrow(err);
    end
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end

%% Field Conflicting with the Dimension
fprintf('Attempt 2: third-axis data in a two-dimensional grid\n');
try
    grid = makeGrid('dim', 2, 'm', 3, 'n', 3, 'o', 3, ...
                    'dx', 1, 'dy', 1, 'topology', 'uniform');
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_GRID_DIM')
        rethrow(err);
    end
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end

%% Invalid Cell Count
fprintf('Attempt 3: zero cells\n');
try
    grid = makeGrid('dim', 1, 'm', 0, 'dx', 1, 'topology', 'uniform');
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_CELL_COUNT')
        rethrow(err);
    end
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end

%% Valid Grid with Inferred Dimension
fprintf('Attempt 4: valid two-dimensional parameters\n');
grid = makeGrid('m', 3, 'n', 3, 'dx', 1, 'dy', 1, ...
                'topology', 'uniform');
fprintf('Grid built OK, dimension = %d.\n', grid.dim);
