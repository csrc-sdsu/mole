%% Two-Dimensional Grid Validation Errors
%
% Validate an invalid grid, catch the MOLE exception, then correct the
% spacing and build a valid grid. Each validation uses a fresh logger.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Parameters
params = struct('topology', 'uniform', 'm', 3, 'n', 3, ...
                'dx', 0, 'dy', 1);

%% Invalid Spacing
fprintf('Attempt 1: dx = 0\n');
errorObj = MOLE_errors();
try
    grid = validateGrid(params, false, errorObj);
catch err
    if ~strcmp(err.identifier, 'MOLE:MOLE_ERR_INVALID_GRID_SPACING')
        rethrow(err);
    end
    fprintf('Caught %s\n%s\n', err.identifier, err.message);
end
fprintf('Recorded errors: %d\n\n', errorObj.getNumErrors());

%% Corrected Spacing
fprintf('Attempt 2: dx = 1\n');
params.dx = 1;
errorObj = MOLE_errors();
grid = validateGrid(params, false, errorObj);
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Recorded errors: %d\n', errorObj.getNumErrors());
