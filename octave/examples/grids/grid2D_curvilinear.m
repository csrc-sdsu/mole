%% Curvilinear Grid on a Half-Annulus
%
% Domain:
%   1 <= r <= 2, 0 <= theta <= pi
%
% Mapping:
%   x = r cos(theta), y = r sin(theta)
%
% Supply nodal coordinates in ndgrid layout. The first index follows r
% and the second follows theta. Validation derives face midpoints and
% cell centers by averaging neighboring nodes.

% No boundary coefficients or periodic flags are supplied in this example.
% The field x^2 - y^2 is sampled at the derived centers;
% no differential operator is applied.
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
m = 12;    % Number of radial cells between r = 1 and r = 2.
n = 24;    % Number of angular cells between theta = 0 and pi.
r = linspace(1, 2, m + 1);
theta = linspace(0, pi, n + 1);

%% Grid Setup
[R, Theta] = ndgrid(r, theta);
params = struct('m', m, 'n', n, 'topology', 'curvilinear');
params.nodes.X = R .* cos(Theta);
params.nodes.Y = R .* sin(Theta);

%% Validate and Derive Face and Center Coordinates
grid = validateGrid(params);

%% Evaluate a Scalar Function at Cell Centers
u = grid.centers.X.^2 - grid.centers.Y.^2;

%% Validation (Needs to be changed to use mole errors)
assert(grid.topology, 'curvilinear');
assert(size(grid.nodes.X), [m + 1, n + 1]);
assert(size(grid.centers.X), [m, n]);
assert(size(grid.faces.u.X), [m + 1, n]);
assert(size(grid.faces.v.X), [m, n + 1]);
radiusError = max(abs(hypot(grid.nodes.X(:), grid.nodes.Y(:)) - R(:)));
% Corner averaging places centers on chords of the polar mapping.
[Rc, ThetaC] = ndgrid((r(1:end-1) + r(2:end))/2, ...
                     (theta(1:end-1) + theta(2:end))/2);
chordFactor = cos(pi/(2*n));
expectedX = Rc .* cos(ThetaC) * chordFactor;
expectedY = Rc .* sin(ThetaC) * chordFactor;
centerError = max(abs([grid.centers.X(:) - expectedX(:); ...
                      grid.centers.Y(:) - expectedY(:)]));
% Allow roundoff from trigonometric evaluation and coordinate averaging.
tolerance = 10*eps(2);
assert(radiusError <= tolerance);
assert(centerError <= tolerance);

%% Results
fprintf('Dimension: %d\n', grid.dim);
fprintf('Topology: %s\n', grid.topology);
fprintf('Nodes:   %d x %d\n', size(grid.nodes.X));
fprintf('Centers: %d x %d\n', size(grid.centers.X));
fprintf('u faces: %d x %d\n', size(grid.faces.u.X));
fprintf('v faces: %d x %d\n', size(grid.faces.v.X));
fprintf('Range of x^2 - y^2 at centers: [%.4f, %.4f]\n', ...
        min(u(:)), max(u(:)));
fprintf('Maximum nodal radius error: %.3e\n', radiusError);
fprintf('Maximum center coordinate error: %.3e\n', centerError);

