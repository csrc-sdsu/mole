%% Construct a Two-Dimensional Grid with Periodic Boundaries
%
% Build a uniform grid with periodic boundaries in x and Dirichlet
% boundaries in y. Boundary coefficients are ordered as the two x ends
% followed by the two y ends. A pair with dc = nc = 0 is periodic.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Boundary Coefficients
bc = struct();
bc.dc = [0; 0; 1; 1];
bc.nc = [0; 0; 0; 0];

%% Construction
grid = makeGrid('dim', 2, 'm', 3, 'n', 3, ...
                'dx', 1, 'dy', 1, 'topology', 'uniform', 'bc', bc);

%% Results
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic(1));
fprintf('Periodic in y: %d\n', grid.bc.isPeriodic(2));
