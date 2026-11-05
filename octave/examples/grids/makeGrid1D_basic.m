%% Construct a One-Dimensional Grid
%
% Build a uniform grid from name/value pairs. makeGrid performs validation
% during construction. An explicit validateGrid call can validate the
% returned struct again.

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
% dim = 1 selects one dimension; m = 4 cells and dx = 0.5 span [0, 2].
% Boundary metadata defaults to nonperiodic.

%% Grid Setup
grid = makeGrid('dim', 1, 'm', 4, 'dx', 0.5, 'topology', 'uniform');

%% Revalidation
grid = validateGrid(grid);

%% Validation
assert(grid.dim, 1);
assert(grid.topology, 'uniform');
assert(grid.nodes.X, [0; 0.5; 1; 1.5; 2]);
assert(grid.centers.X, [0; 0.25; 0.75; 1.25; 1.75; 2]);
assert(grid.bc.isPeriodic, false);

%% Results
fprintf('Grid built OK, %d nodal points.\n', numel(grid.nodes.X));
fprintf('Dimension: %d\n', grid.dim);
fprintf('Domain: %.1f <= x <= %.1f\n', ...
        grid.nodes.X(1), grid.nodes.X(end));

