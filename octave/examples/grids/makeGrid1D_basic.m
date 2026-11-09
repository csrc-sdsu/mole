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

% Report unexpected results through the MOLE error catalog.
exampleErrors = MOLE_errors();

%% Problem Parameters
% dim = 1 selects one dimension; m = 4 cells and dx = 0.5 span [0, 2].
% Boundary metadata defaults to nonperiodic.

%% Grid Setup
grid = makeGrid('dim', 1, 'm', 4, 'dx', 0.5, 'topology', 'uniform');

%% Revalidation
grid = validateGrid(grid);

%% Validation
if ~(isequal(grid.dim, 1))
    details = sprintf('Expected dimension %s; received %s.', mat2str(1), mat2str(grid.dim));
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_DIM', 'makeGrid1D_basic', true, details);
end
if ~(isequal(grid.topology, 'uniform'))
    details = 'Expected topology ''uniform''.';
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_TOPOLOGY', 'makeGrid1D_basic', true, details);
end
if ~(isequal(grid.nodes.X, [0; 0.5; 1; 1.5; 2]))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'makeGrid1D_basic', true, details);
end
if ~(isequal(grid.centers.X, [0; 0.25; 0.75; 1.25; 1.75; 2]))
    details = 'Center coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_CENTER_COORDINATES', 'makeGrid1D_basic', true, details);
end
if ~(isequal(grid.bc.isPeriodic, false))
    details = 'Periodic boundary flags do not match the expected flags for this example.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'makeGrid1D_basic', true, details);
end

%% Results
fprintf('Grid built OK, %d nodal points.\n', numel(grid.nodes.X));
fprintf('Dimension: %d\n', grid.dim);
fprintf('Domain: %.1f <= x <= %.1f\n', ...
        grid.nodes.X(1), grid.nodes.X(end));

