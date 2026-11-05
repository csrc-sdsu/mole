%% Name/Value Argument Order
%
% Construct the same grid with three arrangements of its name/value
% pairs. Each arrangement supplies the same parameters and boundary
% coefficients, so the resulting grid structs should be equal.

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
% dc and nc are ordered x-left, x-right, y-bottom, y-top. Zero pairs
% mark x as periodic; dc = 1, nc = 0 selects Dirichlet types in y.

%% Boundary Coefficients
bc = struct('dc', [0; 0; 1; 1], 'nc', zeros(4, 1));

%% Dimension, Counts, Spacings, Topology, and Boundary Coefficients
a = makeGrid('dim', 2, 'm', 3, 'n', 3, ...
             'dx', 1, 'dy', 1, 'topology', 'uniform', 'bc', bc);

%% Reversed Pair Order
b = makeGrid('bc', bc, 'topology', 'uniform', ...
             'dy', 1, 'dx', 1, 'n', 3, 'm', 3, 'dim', 2);

%% Pairs Grouped by Axis
c = makeGrid('topology', 'uniform', 'm', 3, 'dx', 1, ...
             'n', 3, 'dy', 1, 'bc', bc, 'dim', 2);

%% Validation
assert(isequal(a, b));
assert(isequal(a, c));
assert(a.bc.isPeriodic, [true; false]);

%% Results
fprintf('Order B matches order A: %d\n', isequal(a, b));
fprintf('Order C matches order A: %d\n', isequal(a, c));
fprintf('Periodic in x: %d, periodic in y: %d\n', a.bc.isPeriodic);

