%% Construct a One-Dimensional Grid
%
% Build a uniform grid from name/value pairs. makeGrid performs validation
% during construction. An explicit validateGrid call can validate the
% returned struct again.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Construction
grid = makeGrid('dim', 1, 'm', 4, 'dx', 0.5, 'topology', 'uniform');

%% Revalidation
grid = validateGrid(grid);

%% Results
fprintf('Grid built OK, %d nodal points.\n', numel(grid.nodes.X));
fprintf('Dimension: %d\n', grid.dim);
fprintf('Domain: %.1f <= x <= %.1f\n', ...
        grid.nodes.X(1), grid.nodes.X(end));
