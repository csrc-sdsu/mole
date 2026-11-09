%% Uniform Two-Dimensional Grid
%
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


% Report unexpected results through the MOLE error catalog.
exampleErrors = MOLE_errors();

%% Problem Parameters
params = struct();
params.topology = 'uniform';
params.m = 3;      % Number of cells in x.
params.n = 3;      % Number of cells in y.
params.dx = 1;     % Cell width in x.
params.dy = 1;     % Cell width in y.

%% Grid Setup
grid = validateGrid(params);

%% Validation
[expectedX, expectedY] = ndgrid(0:3, 0:3);


if ~(isequal(grid.nodes.X, expectedX))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'grid2D_basic', true, details);
end
if ~(isequal(grid.nodes.Y, expectedY))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'grid2D_basic', true, details);
end
if ~(isequal(size(grid.centers.X), [5, 5]))
    details = 'Center coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_CENTERS_SZ_MISMATCH', 'grid2D_basic', true, details);
end
if ~(isequal(size(grid.faces.u.X), [4, 3]))
    details = 'Face coordinate array dimensions do not match the expected grid dimensions.';
    exampleErrors.log_error('MOLE_ERR_GRID_FACES_SZ_MISMATCH', 'grid2D_basic', true, details);
end
if ~(isequal(size(grid.faces.v.X), [3, 4]))
    details = 'Face coordinate array dimensions do not match the expected grid dimensions.';
    exampleErrors.log_error('MOLE_ERR_GRID_FACES_SZ_MISMATCH', 'grid2D_basic', true, details);
end
if ~(isequal(grid.bc.isPeriodic, [false; false]))
    details = 'Periodic boundary flags do not match the expected flags for this example.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'grid2D_basic', true, details);
end

%% Results
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Centers: %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d\n', size(grid.faces.v.X));
fprintf('Node (2, 3): x = %.1f, y = %.1f\n', ...
        grid.nodes.X(2, 3), grid.nodes.Y(2, 3));

