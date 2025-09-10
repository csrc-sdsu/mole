%% COMPARISON_TWO_WAY_WAVE_MD_VS_FD
%  Compare 1D two-way wave equation solutions using Mimetic Differences (MD)
%  and standard Finite Differences (FD).
%
%  PDE:
%      d^2u/dt^2 = c^2 * d^2u/dx^2,   -2 <= x <= 2
%
%  METHODS:
%    1. mimetic_diff_two_way_wave_eq.m
%       - Uses mimetic finite differences for the spatial Laplacian.
%       - Preserves discrete conservation properties.
%
%    2. finite_diff_two_way_wave_eq.m
%       - Uses standard finite differences (tridiagonal Laplacian).
%
%  PURPOSE:
%    - Compare numerical accuracy, computational cost, and runtime of MD vs FD.
%    - Demonstrate differences in error, stability, and sparsity handling.
%
%  DOMAIN & DISCRETIZATION:
%    - Spatial domain: [-2, 2]
%    - N spatial points / dx spacing (user-defined)
%    - Time integration: centered-in-time, centered-in-space (CTCS)
%
%  OUTPUTS (printed or plotted by this script):
%    - U2_md       : Final solution using mimetic differences
%    - U2_fd       : Final solution using finite differences
%    - error_md    : Error norm for MD
%    - error_fd    : Error norm for FD
%    - walltime_md : Computation time for MD
%    - walltime_fd : Computation time for FD
%    - flops_md    : Estimated FLOPs for MD
%    - flops_fd    : Estimated FLOPs for FD
%
%  NOTES:
%    - Both solvers use a two-step leapfrog (centered-time) scheme.
%    - CFL condition must be satisfied: c*dt/dx <= 1
%    - Visualization and comparison are performed at the final time step.
%
%  SEE ALSO:
%    mimetic_diff_two_way_wave_eq, finite_diff_two_way_wave_eq
%
%  EXPLANATION:
%    We set the time step to be constant (dt=0.001) and vary the grid spacing to
%    analyze the error of the spacial numerical scheme. The smiulation runs such
%    that the wave traverses 1 unit. The domain is set to be 4 units wide.
%    This removes any boundary, so we can compare just the methods, without
%    having to do anything for the boundary. A straightforward comparison of
%    just the methods.
%
%    The main difference between the methods is how the grid is discretized.
%    Finite differences use a standard grid, where the domain from A to B is
%    broken into N equal sized cells, with n+1 grid points demarking the
%    boundaries.
%
% A                                                                 B
%  <-----dx-----> <-----dx----->       <-----dx-----> <-----dx----->    -- space
% |----cell 1----|----cell 2----| ... |----cell N-1--|----cell N----|   -- cells
% 0              1              2 ...N-1             N             N+1  -- index
%
% Where the mimetic difference uses a staggered grid, with a half step at each
% boundary.
% A                                                                 B
%  <--dx/2--> <-----dx----->       <-----dx-----> <--dx/2-->    -- space
% |--cell 1--|----cell 2----| ... |----cell N-1--|--cell N--|   -- cells
% 0          1              2 ... N             N+1        N+2  -- index
%
% In numbers, from 0 to 1, with 5 cells, an FD grid and MD grid would be
% FD
%    0.0        0.2        0.4        0.6        0.8        1.0
%     o----------o----------o----------o----------o----------o
%     x0         x1         x2         x3         x4         x5
%
% MD
%    0.0   0.1       0.3        0.5        0.7        0.9   1.0
%     o-----o---------o----------o----------o----------o-----o
%     x0   x1         x2         x3         x4         x5    x6
%
%
%   The FTCS has a second order accurate time scheme, so it will never get >2
%   convergence. The user can change the orfer of the mimetic scheme very easily
%   in the mimetic_diff_two_way_wave_eq.m file (k=2), which shows how easy it is
%   to switch orders of the experiment, for very little cost.
%

clc
close all
clear

addpath('../../../../src/matlab_octave');

%% Problem definition - These values aremimicked in the FD and MD functions
k    = 2;        % Mimetic Order of Accuracy, can change to 4,6,8
c    = 0.1;      % Velocity, 1 makes FD sceme exact
west = -2.0;     % Domain's leftmost limits
east = 2.0;      % Domain's rightmost limit

% Number of cells to try, points is cells+1
num_cells = [ 10, 20, 40, 80, 160 ];

%% Run each of the methods over the different grids
[ U2_fd, error_fd, walltime_fd, flops_fd ] = finite_diff_two_way_wave_eq();
[ U2_md, error_md, walltime_md, flops_md ] = mimetic_diff_two_way_wave_eq();

%% Error analysis

% We kept the time step constant, so any error, or better, any improvement
% measured is due to the spacial scheme. here we fit a regression plot to the
% log error of the lines. Orders of accuracy (k) are O^k, so we need to extract
% the exponent, hence the log of the errors and spacial steps.
% Regression fit line to error plot, should be close to 2.
p_fd = polyfit(log(1 ./ num_cells), log(error_fd), 1);
p_md = polyfit(log(1 ./ num_cells), log(error_md), 1);
fprintf("Finite Difference Error Convergence Slope:  %3.4f\n", p_fd(1) );
fprintf("Mimetic Difference Error Convergence Slope: %3.4f\n", p_md(1) );

% Plot the comparison of the errors of each scheme - on a log-log plot,
% so we can capture the slope of the lines == the order of accuracy of the
% spacial scheme.
figure(1)
loglog(1 ./ num_cells, error_fd, 'LineWidth', 2); hold on;
loglog(1 ./ num_cells, error_md, 'LineWidth', 2)
xlim([1 / num_cells(end) 1 / num_cells(1)]);
xlabel('dx'); ylabel('error');
grid on;
title(['Error: FD slope~', num2str(p_fd(1)), ', MD slope~', num2str(p_md(1))]);
legend('FD Error','MD error')
set(gca, "linewidth", 2, "fontsize", 16)

% Walltime, there is some spooling MATLAB does, so may not be
% super accurate. Given here for reference.
figure(2)
plot(num_cells, walltime_fd, 'LineWidth', 2); hold on;
plot(num_cells, walltime_md, 'LineWidth', 2);
xlim([num_cells(1) num_cells(end)]);
ylim([min( min(walltime_fd), min(walltime_md) )  max( max(walltime_fd), max(walltime_md) )]);
xlabel('num points'); ylabel('walltime [s]');
grid on;
title(['Walltime, MD is order ', num2str(k)]);
legend('FD time', 'MD time');
set(gca, "linewidth", 2, "fontsize", 16)

% Floating point operations needed for each method. The mimetic difference
% methods use at least one more point, and have boundary calculations built in.
figure(3)
loglog(num_cells, flops_fd, 'LineWidth', 2); hold on;
loglog(num_cells, flops_md, 'LineWidth', 2);
xlim([ num_cells(1) num_cells(end) ]); ylim([ 1e5 1e8 ]);
xlabel('num cells'); ylabel('FLOPs');
grid on;
title(['FLOPs for each method, mimetic order:', num2str(k)]);
legend('FD FLOPs', 'MD FLOPs');
set(gca, "linewidth", 2, "fontsize", 16)

