%% Curvilinear Three-Dimensional Grid
%
% Map the computational unit cube 0 <= xi, eta, zeta <= 1 into
%   x = xi + amplitude*sin(pi*eta)*sin(pi*zeta),
%   y = eta, z = zeta.
% The mapping has Jacobian determinant 1. The two xi boundary surfaces
% are curved, and the grid retains ndgrid index order (xi, eta, zeta).
%
% Supply nodal coordinates through makeGrid's struct-input form.
% Validation derives faces by averaging four corners and cell centers
% by averaging eight corners. No boundary coefficients or periodic
% flags are supplied, and no differential operator is applied.
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
m = 4;              % Number of cells in the xi direction.
n = 6;              % Number of cells in the eta direction.
o = 8;              % Number of cells in the zeta direction.
amplitude = 0.1;    % Maximum displacement in the physical x direction.
xi = linspace(0, 1, m + 1);
eta = linspace(0, 1, n + 1);
zeta = linspace(0, 1, o + 1);

%% Grid Setup
[Xi, Eta, Zeta] = ndgrid(xi, eta, zeta);
params = struct('m', m, 'n', n, 'o', o, 'topology', 'curvilinear');
params.nodes.X = Xi + amplitude .* sin(pi .* Eta) .* sin(pi .* Zeta);
params.nodes.Y = Eta;
params.nodes.Z = Zeta;
grid = makeGrid(params);

%% Analytical Coordinate Comparison
% Uniform parameter steps give a closed form for corner-averaged centers.
% Averaging sin(pi*eta) at adjacent nodes gives sin(pi*eta_c)*cos(pi/(2*n));
% the zeta average has the corresponding factor cos(pi/(2*o)).
[XiC, EtaC, ZetaC] = ndgrid((xi(1:end-1) + xi(2:end))/2, ...
                          (eta(1:end-1) + eta(2:end))/2, ...
                          (zeta(1:end-1) + zeta(2:end))/2);
expectedX = XiC + amplitude .* sin(pi .* EtaC) .* sin(pi .* ZetaC) ...
                  .* cos(pi/(2*n)) .* cos(pi/(2*o));
centerError = max([max(abs(grid.centers.X(:) - expectedX(:))), ...
                   max(abs(grid.centers.Y(:) - EtaC(:))), ...
                   max(abs(grid.centers.Z(:) - ZetaC(:)))]);
% Allow roundoff from trigonometric evaluation and eight-corner averaging.
tolerance = 16 * eps(1 + abs(amplitude));

%% Validation
if ~(grid.dim == 3)
    details = sprintf('Expected dimension %s; received %s.', mat2str(3), mat2str(grid.dim));
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_DIM', 'grid3D_curvilinear', true, details);
end
if ~(strcmp(grid.topology, 'curvilinear'))
    details = 'Expected topology ''curvilinear''.';
    exampleErrors.log_error('MOLE_ERR_INVALID_GRID_TOPOLOGY', 'grid3D_curvilinear', true, details);
end
if ~(isequal(grid.nodes.X, params.nodes.X))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'grid3D_curvilinear', true, details);
end
if ~(isequal(grid.nodes.Y, params.nodes.Y))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'grid3D_curvilinear', true, details);
end
if ~(isequal(grid.nodes.Z, params.nodes.Z))
    details = 'Nodal coordinates do not match the expected values for this example.';
    exampleErrors.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'grid3D_curvilinear', true, details);
end
if ~(isequal(size(grid.nodes.X), [m+1, n+1, o+1]))
    details = 'Nodal coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_NODAL_SZ_MISMATCH', 'grid3D_curvilinear', true, details);
end
if ~(isequal(size(grid.centers.X), [m, n, o]))
    details = 'Center coordinate array dimensions or point count do not match the expected grid size.';
    exampleErrors.log_error('MOLE_ERR_GRID_CENTERS_SZ_MISMATCH', 'grid3D_curvilinear', true, details);
end
if ~(isequal(size(grid.faces.u.X), [m+1, n, o]))
    details = 'Face coordinate array dimensions do not match the expected grid dimensions.';
    exampleErrors.log_error('MOLE_ERR_GRID_FACES_SZ_MISMATCH', 'grid3D_curvilinear', true, details);
end
if ~(isequal(size(grid.faces.v.Y), [m, n+1, o]))
    details = 'Face coordinate array dimensions do not match the expected grid dimensions.';
    exampleErrors.log_error('MOLE_ERR_GRID_FACES_SZ_MISMATCH', 'grid3D_curvilinear', true, details);
end
if ~(isequal(size(grid.faces.w.Z), [m, n, o+1]))
    details = 'Face coordinate array dimensions do not match the expected grid dimensions.';
    exampleErrors.log_error('MOLE_ERR_GRID_FACES_SZ_MISMATCH', 'grid3D_curvilinear', true, details);
end
if ~(centerError <= tolerance)
    details = sprintf('Maximum center coordinate error %.3e exceeds tolerance %.3e or is nonfinite.', centerError, tolerance);
    exampleErrors.log_error('MOLE_ERR_INVALID_CENTER_COORDINATES', 'grid3D_curvilinear', true, details);
end

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Nodes: %d x %d x %d\n', size(grid.nodes.X));
fprintf('Cell centers: %d x %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d x %d\n', size(grid.faces.v.Y));
fprintf('w faces: %d x %d x %d\n', size(grid.faces.w.Z));
fprintf('Physical x extent: [%.3f, %.3f]\n', min(grid.nodes.X(:)), max(grid.nodes.X(:)));
fprintf('Maximum center coordinate error: %.3e\n', centerError);
fprintf('Coordinate comparison tolerance: %.3e\n', tolerance);

