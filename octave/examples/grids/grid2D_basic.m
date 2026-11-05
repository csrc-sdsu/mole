% Build a grid on 0 <= x <= 3 and 0 <= y <= 3. Coordinate arrays use
% ndgrid layout: the first index follows x and the second follows y.
% The u faces are normal to x; the v faces are normal to y.

% Nodes satisfy x_i = i*dx, y_j = j*dy. Center arrays also include
% domain endpoints. Boundary metadata defaults to nonperiodic.
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

%% Parameters
params = struct();
params.topology = 'uniform';
params.m = 3;
params.n = 3;
params.dx = 1;
params.dy = 1;

%% Validate and Generate Coordinates
grid = validateGrid(params);

%% Results
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Centers: %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d\n', size(grid.faces.v.X));
fprintf('Node (2, 3): x = %.1f, y = %.1f\n', ...
        grid.nodes.X(2, 3), grid.nodes.Y(2, 3));
