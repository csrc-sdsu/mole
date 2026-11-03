%% Uniform One-Dimensional Grid
%
% Build a grid on 0 <= x <= 2 from a parameter struct. Four cells with
% spacing 0.5 produce five nodes and six center entries, including the
% two domain endpoints.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Parameters
params = struct();
params.topology = 'uniform';
params.m = 4;
params.dx = 0.5;

%% Validate and Generate Coordinates
grid = validateGrid(params);

%% Results
fprintf('Grid built OK, %d nodal points.\n', numel(grid.nodes.X));
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Nodes:   ');
fprintf(' %.2f', grid.nodes.X);
fprintf('\nCenters: ');
fprintf(' %.2f', grid.centers.X);
fprintf('\n');
