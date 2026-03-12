%% FINITE_DIFF_TWO_WAY_WAVE_EQ_WITH_BC
%  Solve the 1D two-way wave equation using standard finite differences and
%  boundary conditions.
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
% We use a larger domain for graphing wave movement without boundary issues.
% This removes any boundary, so we can compare just the methods, without
% having to do anything for the boundary. A straightforward comparison of
% just the methods.
%
% The discretization has a second order accurate time scheme, so it will never
% get >2 convergence. This file is commented for first time users, to explain
% and show differences with the mimetic difference method.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

%% Problem definition
west = -2.0;     % Domain's leftmost limits
east = 2.0;      % Domain's rightmost limit

c = 0.1;
dt = 0.1;

%% Number of cells to try, grid points is cells+1
num_cells = [  30 ];

% generic holders for metrics within the loops
error_fd = zeros(size(num_cells));
walltime_fd = zeros(size(num_cells));
flops_fd = zeros(size(num_cells));

% Initial Condition Function
f = @(x) ( (x > -0.5) & (x < 0.5) ) .* (cos(pi * x).^2);
f = @(x) exp( -x.^2 / 0.1 );

% Wave solution using d'Alembert
u = @(x,t) 0.5 * ( f(x - c * t) + f(x + c * t) );

for cell_index = 1 : numel(num_cells)

    %% Setup the domain
    m = num_cells(cell_index);      % Number of cells, mimetics uses 'cells'
    nx = m+1;                       % number of grid points

    dx = (east - west) / m;         % spacial discretization

    r2_md = c^2 * (dt^2);    % c in the equation

    %t = ceil( 2/(c * dt) );         % first step euler, so t is one less
    t = 1 * ( east - west ) / c / dt;
    % FD grid
    grid_md = [ west west+dx/2 : dx : east-dx/2 east ];

    %% Initial Displacement is cos curve
    U0_md = u(grid_md', 0);

    % The analytic solution, so we can check the error
    analytic_md = -U0_md;

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
        plot(grid_md,U1_md); hold on;
        plot(grid_md, analytic_md, 'r'); hold off;
        str=['Step: ', num2str(i) ];
        title(str);
        ylim([-1 1]);
        drawnow
    end
    walltime_fd(cell_index) = toc;

    % Number of flops
    flops_fd(cell_index) = (2 * nnz_fd + length(U0_fd)) * t;
    %error_fd(cell_index) = max(abs(U2_fd-analytic_fd));
    
    diff = U2_md - analytic_md;
    error_fd(cell_index) = norm(diff) / norm(analytic_fd);
end

