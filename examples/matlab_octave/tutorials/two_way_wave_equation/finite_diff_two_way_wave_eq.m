function [ U2_fd, error_fd, walltime_fd, flops_fd ] = finite_diff_two_way_wave_eq()
%% FINITE_DIFF_TWO_WAY_WAVE_EQ
%  Solve the 1D two-way wave equation using standard finite differences.
%
%  PDE:      d^2u/dt^2 = c^2 * d^2u/dx^2    on domain [-2, 2]
%  Scheme:   Centered-in-Time, Centered-in-Space (CTCS)
%            Explicit second-order accurate in time and space
%
%  Time-stepping update:
%      U^{n+1} = 2*U^{n} - U^{n-1} + (c^2 * dt^2 * D_fd) * U^{n}
%  where D_fd is the standard second-derivative finite-difference matrix:
%
%      D_fd = (1/dx^2) * tridiag([1, -2, 1])
%
%  OUTPUTS:
%    U2_fd       - Final solution vector at last time step
%    error_fd    - Norm of error vs. analytic or reference solution
%    walltime_fd - Wall-clock time (seconds) for the simulation
%    flops_fd    - Estimated floating-point operation count
%
%  SEE ALSO:
%    mimetic_diff_two_way_wave_eq, comparison_two_way_wave_md_vs_fd
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

%% Problem definition
c    = 0.1;      % Velocity, 1 makes FD sceme exact
west = -2.0;     % Domain's leftmost limits
east = 2.0;      % Domain's rightmost limit

%% Number of cells to try, grid points is cells+1
num_cells = [ 10, 20, 40, 80, 160 ];

% generic holders for metrics within the loops
error_fd = zeros(size(num_cells));
walltime_fd = zeros(size(num_cells));
flops_fd = zeros(size(num_cells));

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

    r2_fd = c^2 * (dt^2 / dx^2);      % c in the equation

    t = ceil( 1/(c * dt) );          % first step euler, so t is one less

    % FD grid
    grid_fd =  west : dx : east;

    %% Initial Displacement is cos curve
    U0_fd = u(grid_fd', 0);

    % The analytic solution, so we can check the error
    analytic_fd = u(grid_fd', (t+1) * dt);

    %% Centered Scheme Matrix L
    % L is (I + cD), a tridiagonal sparse matrix:
    %
    % L =
    %   [2-2c  c    0    0    0
    %    c   2-2c   c    0    0
    %    0     α  2-2c   c    0
    %    0     0    c  2-2c   c
    %    0     0    0    c  2-2c]
    %
    % where c =  r2_fd = c^2 * (dt^2 / dx^2)

    % For step 1
    % Make a vector of ones, this will be the -1,+1 diagonal of matrix LTCS
    B = ( r2_fd ) * ones(nx,1);

    % The next vector of ones will be the main diagonal of LTCS
    A = (2 - (2 * r2_fd)) * ones(nx,1);

    % Build sparse matrix consisting of diagonals A and D
    LTCS = spdiags([B A B], [-1,0,1], nx, nx);

    % Boundary Conditions, not needed with time<2, but here for reference
    LTCS(1,1) = 1; LTCS(1,2) = 0;
    LTCS(end,end) = 1; LTCS(end,end-1) = 0;

    % Step one is different, precomputed using Euler method
    U1_fd = 0.5 * LTCS * U0_fd;

    U2_fd = U1_fd;      % Increment time step

    %% Loop over time values
    nnz_fd = nnz(LTCS);
    tic
    for i = 1 : t

        U2_fd = (LTCS * U1_fd) - U0_fd;

        % Shift everyone back for leapfrog scheme
        U0_fd = U1_fd;
        U1_fd = U2_fd;

    end
    walltime_fd(cell_index) = toc;

    % Number of flops
    flops_fd(cell_index) = (2 * nnz_fd + length(U0_fd)) * t;
    error_fd(cell_index) = max(U2_fd-analytic_fd);

end

