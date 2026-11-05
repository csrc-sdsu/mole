%% Uniform One-Dimensional Grid
%
% Build a grid on 0 <= x <= 2 from a parameter struct. Four cells with
% spacing 0.5 produce five nodes and six center entries, including the
% two domain endpoints.

% Boundary metadata defaults to nonperiodic when coefficients are omitted.
% Nodal coordinates satisfy x_i = i*dx for i = 0,...,m.
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
params.topology = 'uniform';
params.m = 4;       % Number of cells in x.
params.dx = 0.5;    % Cell width; domain length is m*dx = 2.

%% Grid Setup
grid = validateGrid(params);

%% Validation
% Exact coordinates for the interval [0, 2].
assert(grid.dim, 1);
assert(grid.topology, 'uniform');
assert(grid.nodes.X, [0; 0.5; 1; 1.5; 2]);
assert(grid.centers.X, [0; 0.25; 0.75; 1.25; 1.75; 2]);
assert(grid.bc.isPeriodic, false);

%% Results
fprintf('Grid built OK, %d nodal points.\n', numel(grid.nodes.X));
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Nodes:   ');
fprintf(' %.2f', grid.nodes.X);
fprintf('\nCenters: ');
fprintf(' %.2f', grid.centers.X);
fprintf('\n');

