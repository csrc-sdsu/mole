%% Curvilinear Grid on a Half-Annulus
%
% Domain:
%   1 <= r <= 2, 0 <= theta <= pi
%
% Mapping:
%   x = r cos(theta), y = r sin(theta)
%
% Supply nodal coordinates in ndgrid layout. The first index follows r
% and the second follows theta. Validation derives face midpoints and
% cell centers by averaging neighboring nodes.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

%% Parameters
m = 12;
n = 24;
r = linspace(1, 2, m + 1);
theta = linspace(0, pi, n + 1);

%% Nodal Coordinates
[R, Theta] = ndgrid(r, theta);
params = struct('m', m, 'n', n, 'topology', 'curvilinear');
params.nodes.X = R .* cos(Theta);
params.nodes.Y = R .* sin(Theta);

%% Validate and Derive Face and Center Coordinates
grid = validateGrid(params);

%% Evaluate a Scalar Function at Cell Centers
u = grid.centers.X.^2 - grid.centers.Y.^2;

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Nodes:   %d x %d\n', size(grid.nodes.X));
fprintf('Centers: %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d\n', size(grid.faces.v.X));
fprintf('Range of x^2 - y^2 at centers: [%.4f, %.4f]\n', ...
        min(u(:)), max(u(:)));
