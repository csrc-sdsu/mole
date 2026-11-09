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

% Report unexpected results through the MOLE error catalog.
exampleErrors = MOLE_errors();

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
if ~(isequal(grid.dim, 1))
    details = sprintf('Expected dimension %s; received %s.', mat2str(1), mat2str(grid.dim));
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_DIM', 'grid1D_periodic', true, details);
end
if ~(isequal(grid.topology, 'periodic'))
    details = 'Expected topology ''periodic''.';
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_TOPOLOGY', 'grid1D_periodic', true, details);
end
if ~(isequal(grid.bc.isPeriodic, true))
    details = 'Periodic boundary flags do not match the expected flags for this example.';
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'grid1D_periodic', true, details);
end
if ~(isequal(numel(grid.nodes.X), params.m + 1))
    details = 'Nodal coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_NODAL_SZ_MISMATCH', 'grid1D_periodic', true, details);
end
if ~(isequal(numel(grid.centers.X), params.m + 2))
    details = 'Center coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_CENTERS_SZ_MISMATCH', 'grid1D_periodic', true, details);
end
% sin(2*pi*x) agrees at x = 0 and x = 1 to floating-point roundoff.
if ~(abs(u(1) - u(end)) <= 10*eps)
    details = sprintf('Periodic endpoint difference %.3e exceeds tolerance %.3e or is nonfinite.', abs(u(1)-u(end)), 10*eps);
    exampleErrors.log_error('MOLE_ERR_GRID_CONSTRUCTION_FAILED', 'grid1D_periodic', true, details);
end

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Periodic in x: %d\n', grid.bc.isPeriodic);
fprintf('Nodes: %d, center entries: %d\n', ...
        numel(grid.nodes.X), numel(grid.centers.X));
fprintf('u at the domain ends: %.3e, %.3e\n', u(1), u(end));

