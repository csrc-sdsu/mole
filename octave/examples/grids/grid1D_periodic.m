%% One-Dimensional Grid with Periodic Boundaries
%
% Build a grid on 0 <= x <= 1. Zero Dirichlet and Neumann coefficients
% at both ends mark the x direction as periodic. Validation derives
% the topology, periodic flag, and coordinate arrays from these inputs.

% The sampled function u(x) = sin(2*pi*x) has period 1.
%
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
params = struct();
params.m = 20;              % Number of cells in x.
params.dx = 1 / params.m;    % Cell width on the unit interval.
params.bc = struct('dc', [0; 0], 'nc', [0; 0]);

%% Grid Setup
grid = validateGrid(params);

%% Sample a Periodic Function
u = sin(2 * pi * grid.centers.X);

%% Validation
assert(grid.dim, 1);
assert(grid.topology, 'periodic');
assert(grid.bc.isPeriodic, true);
assert(numel(grid.nodes.X), params.m + 1);
assert(numel(grid.centers.X), params.m + 2);
% sin(2*pi*x) agrees at x = 0 and x = 1 to floating-point roundoff.
assert(abs(u(1) - u(end)) <= 10*eps);

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic);
fprintf('Nodes: %d, center entries: %d\n', ...
        numel(grid.nodes.X), numel(grid.centers.X));
fprintf('u at the domain ends: %.3e, %.3e\n', u(1), u(end));

