function [ U2_md, error_md, walltime_md, flops_md ] = mimetic_diff_two_way_wave_eq()
%% MIMETIC_DIFF_TWO_WAY_WAVE_EQ
%  Solve the 1D two-way wave equation using mimetic finite differences.
%
%  PDE:      d^2u/dt^2 = c^2 * d^2u/dx^2    on domain [-2, 2]
%  Scheme:   Centered-in-Time, Centered-in-Space (CTCS)
%            Explicit second-order accurate in time and space
%
%  Time-stepping update:
%      U^{n+1} = 2*U^{n} - U^{n-1} + (c^2 * dt^2 * L) * U^{n}
%  where L is the mimetic discrete Laplacian operator. Note there is no spacial
%  discretization, the L takes care of that.
%
%  OUTPUTS:
%    U2_md       - Final solution vector at last time step
%    error_md    - Norm of error vs. analytic or reference solution
%    walltime_md - Wall-clock time (seconds) for the simulation
%    flops_md    - Estimated floating-point operation count
%
%  SEE ALSO:
%    finite_diff_two_way_wave_eq, comparison_two_way_wave_md_vs_fd
%
%  NOTES:
% We use a larger domain for graphing wave movement without bondary issues.
% This removes any boundary, so we can compare just the methods, without
% having to do anything for the boundary. A straightforward comparison of
% just the methods.
%
% The discretization has a second order accurate time scheme, so it will never
% get >2 convergence. This file is commented for first time users, to explain
% and show differences with the mimetic difference method.
%
% The order of accuracy of the mimetic difference scheme can be changed with the
% k parameter.
%
% [ Compare with finite_diff_two_way_wave_eq.m ]

%% Problem definition
k    = 2;        % Mimetic Order of Accuracy, can change to 4,6,8
c    = 0.1;      % Velocity, 1 makes FD sceme exact
west = -2.0;     % Domain's leftmost limits
east = 2.0;      % Domain's rightmost limit

%% Number of cells to try, points is cells+1
num_cells = [ 10, 20, 40, 80, 160 ];

% generic holders for loop info
error_md = zeros(size(num_cells));
walltime_md = zeros(size(num_cells));
flops_md = zeros(size(num_cells));

% Initial Condition Function
f = @(x) ( (x > -0.5) & (x < 0.5) ) .* (cos(pi * x).^2);

% Wave solution using d'Almbert
u = @(x,t) 0.5 * ( f(x - c * t) + f(x + c * t) );

for cell_index = 1 : numel(num_cells)

    %% Setup the domain
    m = num_cells(cell_index);      % Number of cells, mimetics uses 'cells'
    nx = m+1;                       % number of grid points

    dx = (east - west) / m;         % spacial discretization
    dt = 0.001;                     % Time step constant for error analysis

    r2_md = c^2 * (dt^2);           % c in the equation, dx is built into the
                                    % mimetic operator Laplacian (L)

    t = ceil( 1/(c * dt) );         % first step euler, so t is one less

    % MD grid, note the extra staggered (dx/2) step near the boundaries
    grid_md = [ west west+dx/2 : dx : east-dx/2 east ];

    %% Initial Displacement is cos curve
    U0_md = u(grid_md', 0);

    % The analytic solution, so we can check the error
    analytic_md = u(grid_md', (t+1) * dt);

    %% Mimetic Scheme Matrix L
    L = lap(k,m,dx);    % mimetic Laplacian operator
    L = r2_md * L;      % premultiply by dt^2 * c^2, knowing dx is already in L

    U1_md = U0_md + (0.5 * L * U0_md);  % First step, Euler
    U2_md = U1_md;      % Increment time step

    %% Loop over time values
    nnz_md = nnz(L);
    tic
    for i = 1 : t

        U2_md = (2.0 * U1_md) + (L * U1_md) - U0_md;

        % Shift everyone back for leapfrog scheme
        U0_md = U1_md;
        U1_md = U2_md;

    end
    walltime_md(cell_index) = toc;

    % Number of flops
    flops_md(cell_index) = (2 * nnz_md + (3 * length(U0_md)) ) * t;
    error_md(cell_index) = max(U2_md-analytic_md);

end
