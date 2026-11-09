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

% Report unexpected results through the MOLE error catalog.
exampleErrors = MOLE_errors();

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
if ~(isequal(grid.dim, 2))
    details = sprintf('Expected dimension %s; received %s.', mat2str(2), mat2str(grid.dim));
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_DIM', 'makeGrid2D_basic', true, details);
end
if ~(isequal(grid.topology, 'periodic'))
    details = 'Expected topology ''periodic''.';
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_TOPOLOGY', 'makeGrid2D_basic', true, details);
end
if ~(isequal(grid.bc.isPeriodic, [true; false]))
    details = 'Periodic boundary flags do not match the expected flags for this example.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'makeGrid2D_basic', true, details);
end
if ~(isequal(grid.bc.dc, bc.dc))
    details = 'Normalized boundary coefficients differ from the supplied coefficients.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'makeGrid2D_basic', true, details);
end
if ~(isequal(grid.bc.nc, bc.nc))
    details = 'Normalized boundary coefficients differ from the supplied coefficients.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'makeGrid2D_basic', true, details);
end
[expectedX, expectedY] = ndgrid(0:3, 0:3);
if ~(isequal(grid.nodes.X, expectedX))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'makeGrid2D_basic', true, details);
end
if ~(isequal(grid.nodes.Y, expectedY))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'makeGrid2D_basic', true, details);
end

%% Results
fprintf('Grid built OK, nodes.X is %d x %d.\n', size(grid.nodes.X));
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic(1));
fprintf('Periodic in y: %d\n', grid.bc.isPeriodic(2));

