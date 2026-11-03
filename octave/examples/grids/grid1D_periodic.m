%% One-Dimensional Grid with Periodic Boundaries
%
% Build a grid on 0 <= x <= 1. Zero Dirichlet and Neumann coefficients
% at both ends mark the x direction as periodic. Validation derives
% the topology, periodic flag, and coordinate arrays from these inputs.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Parameters and Boundary Coefficients
params = struct();
params.m = 20;
params.dx = 1 / params.m;
params.bc = struct('dc', [0; 0], 'nc', [0; 0]);

%% Validate and Generate Coordinates
grid = validateGrid(params);

%% Sample a Periodic Function
u = sin(2 * pi * grid.centers.X);

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic);
fprintf('Nodes: %d, center entries: %d\n', ...
        numel(grid.nodes.X), numel(grid.centers.X));
fprintf('u at the domain ends: %.3e, %.3e\n', u(1), u(end));
