%% Name/Value Argument Order
%
% Construct the same grid with three arrangements of its name/value
% pairs. Each arrangement supplies the same parameters and boundary
% coefficients, so the resulting grid structs should be equal.

clear; clc;

%% Library Paths
exampleDir = fileparts(mfilename('fullpath'));
octaveDir = fileparts(fileparts(exampleDir));
addpath(fullfile(octaveDir, 'src', 'grids'));
addpath(fullfile(octaveDir, 'src', 'sys'));

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

%% Compare the Results
fprintf('Order B matches order A: %d\n', isequal(a, b));
fprintf('Order C matches order A: %d\n', isequal(a, c));
fprintf('Periodic in x: %d, periodic in y: %d\n', a.bc.isPeriodic);
