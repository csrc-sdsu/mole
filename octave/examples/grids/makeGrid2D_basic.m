%% Construct a Two-Dimensional Grid with Periodic Boundaries
%
% Build a uniform grid with periodic boundaries in x and Dirichlet
% boundaries in y. Boundary coefficients are ordered as the two x ends
% followed by the two y ends. A pair with dc = nc = 0 is periodic.

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
% dim = 2, m = n = 3 cells, and dx = dy = 1 give the domain [0, 3]^2.
% dc and nc are the coefficients of dc*u + nc*du/dn on each boundary.
% Both x coefficients are zero; each y boundary uses dc = 1, nc = 0.
% These coefficients describe boundary types; no boundary values are set.

%% Boundary Coefficients
bc = struct();
bc.dc = [0; 0; 1; 1];
bc.nc = [0; 0; 0; 0];

%% Grid Setup
grid = makeGrid('dim', 2, 'm', 3, 'n', 3, ...
                'dx', 1, 'dy', 1, 'topology', 'uniform', 'bc', bc);

%% Validation
assert(grid.dim, 2);
assert(grid.topology, 'periodic');
assert(grid.bc.isPeriodic, [true; false]);
assert(grid.bc.dc, bc.dc);
assert(grid.bc.nc, bc.nc);
[expectedX, expectedY] = ndgrid(0:3, 0:3);
assert(grid.nodes.X, expectedX);
assert(grid.nodes.Y, expectedY);

%% Results
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic(1));
fprintf('Periodic in y: %d\n', grid.bc.isPeriodic(2));

