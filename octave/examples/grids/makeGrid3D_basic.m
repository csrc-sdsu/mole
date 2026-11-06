%% Uniform Three-Dimensional Grid
%
% Construct a uniform grid from name/value pairs on
%   0 <= x <= 1, 0 <= y <= 0.75, 0 <= z <= 8.
% Nodes satisfy x_i = i*dx, y_j = j*dy, and z_k = k*dz.
% Coordinate arrays use ndgrid layout, with x, y, and z following the
% first, second, and third indices. Uniform center arrays include the
% domain boundaries as well as the interior cell centers.
%
% Boundary metadata defaults to nonperiodic when coefficients and flags
% are omitted. This example constructs geometry without solving a PDE.
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
m = 2;       % Number of cells in x.
n = 3;       % Number of cells in y.
o = 4;       % Number of cells in z.
dx = 0.5;    % Cell width in x; domain length m*dx = 1.
dy = 0.25;   % Cell width in y; domain length n*dy = 0.75.
dz = 2;      % Cell width in z; domain length o*dz = 8.

%% Grid Setup
% makeGrid infers dim = 3 and validates during construction.
grid = makeGrid('m', m, 'n', n, 'o', o, ...
                'dx', dx, 'dy', dy, 'dz', dz, 'topology', 'uniform');

%% Validation
assert(grid.dim == 3);
assert(strcmp(grid.topology, 'uniform'));
assert(isequal(grid.bc.isPeriodic, false(3, 1)));
assert(isequal(size(grid.nodes.X), [m+1, n+1, o+1]));
assert(isequal(size(grid.centers.X), [m+2, n+2, o+2]));
assert(isequal(size(grid.faces.u.X), [m+1, n, o]));
assert(isequal(size(grid.faces.v.Y), [m, n+1, o]));
assert(isequal(size(grid.faces.w.Z), [m, n, o+1]));

% Axis slices check coordinates without building extra full reference grids.
assert(isequal(grid.nodes.X(:, 1, 1), (0:m)' * dx));
assert(isequal(grid.nodes.Y(1, :, 1), (0:n) * dy));
assert(isequal(reshape(grid.nodes.Z(1, 1, :), [], 1), (0:o)' * dz));
assert(isequal(grid.centers.X(:, 1, 1), [0; 0.25; 0.75; 1]));
assert(isequal(grid.centers.Y(1, :, 1), [0, 0.125, 0.375, 0.625, 0.75]));
assert(isequal(reshape(grid.centers.Z(1, 1, :), [], 1), [0; 1; 3; 5; 7; 8]));

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Cells: %d x %d x %d\n', m, n, o);
fprintf('Domain: [0, %.2f] x [0, %.2f] x [0, %.2f]\n', m*dx, n*dy, o*dz);
fprintf('Nodes: %d x %d x %d\n', size(grid.nodes.X));
fprintf('Center/boundary entries: %d x %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d x %d\n', size(grid.faces.v.Y));
fprintf('w faces: %d x %d x %d\n', size(grid.faces.w.Z));
fprintf('Periodic flags (x, y, z): %d %d %d\n', grid.bc.isPeriodic);

