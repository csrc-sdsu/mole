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
assert(grid.dim == 3);
assert(strcmp(grid.topology, 'curvilinear'));
assert(isequal(grid.nodes.X, params.nodes.X));
assert(isequal(grid.nodes.Y, params.nodes.Y));
assert(isequal(grid.nodes.Z, params.nodes.Z));
assert(isequal(size(grid.nodes.X), [m+1, n+1, o+1]));
assert(isequal(size(grid.centers.X), [m, n, o]));
assert(isequal(size(grid.faces.u.X), [m+1, n, o]));
assert(isequal(size(grid.faces.v.Y), [m, n+1, o]));
assert(isequal(size(grid.faces.w.Z), [m, n, o+1]));
assert(centerError <= tolerance);

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

