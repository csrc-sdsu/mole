%% Comparison of 1D wave equation using mimetic diferences (MD)
% and finite differences (FD)
%
% BY: Jared Brzenski
%
% Forward Time, centered space solving the equation
% d^2u/dt^2 = c^2 d^2u/dx^2
% On the domain:
% -2<x<2,
% ( We use a larger domain for graphing wave movement )
% with dt=dx for cfl = 1;
%
% This removes any boundary, so we can compare just the methods, without
% having to do naything for the boundary. A straightforward comparison of
% just the methods.
%
% The FTCS has a second order accurate time scheme, so it will never get >2
% convergence. But, this show how easy it is to switch orders and
% experiment, for very little cost.
% 2025/08/18
clc
close all
clear

addpath('../../src/matlab_octave');

%% Problem definition
k    = 2;        % Mimetic Order of Accuracy, can change to 4,6,8
c    = 0.1;      % Velocity, 1 makes it perfect
west = -2.0;     % Domain's leftmost limits
east = 2.0;      % Domains rightmost limit

%% Number of cells to try, points is cells+1
m_points = [ 10, 20, 40, 80, 160 ];

% generic holders for loop info
error_fd = zeros(size(m_points));
error_md = zeros(size(error_fd));

time_fd = error_fd;
time_md = error_md;

flops_fd = zeros(size(m_points));
flops_md = zeros(size(m_points));

% Initial Condition Function
f = @(x) ( (x > -0.5) & (x < 0.5) ) .* (cos(pi*x).^2);

% Wave solution using d'Almbert
u = @(x,t) 0.5 * ( f(x - c*t) + f(x + c*t) );


%% Loop
for ii=1:numel(m_points)

    %% Setup the domain
    m = m_points(ii);               % Number of cells, mimetics uses 'cells'
    nx = m+1;                       % number of grid points, for our usage

    dx = (east - west) / m;         % spacial discretization size delta x
    dt = 0.001;                     % Time step constant for error analysis

    r2_fd = c^2*(dt^2 / dx^2);      % c in the equation
    r2_md = c^2*(dt^2);             % c in the equation, dx is in mimetic L

    t = ceil( 1/(c*dt) ) ;          % first step euler, so t is one less

    % FD grid
    grid_fd =  west : dx : east ;
    % MD grid
    grid_md = [ west west+dx/2 : dx : east-dx/2 east ] ;

    %% Initial Dislplacement is cos curve
    % Finite Difference
    U0_fd = u(grid_fd', 0);

    analytic_fd = u(grid_fd', (t+1)*dt);

    % Mimetic Difference, same as above, just staggered grid
    U0_md = u(grid_md', 0);

    analytic_md = u(grid_md', (t+1)*dt);

    %% FTCS Scheme Matrix L
    % For step 1
    % Make a vector of ones, this will be the -1,+1 diagonal of matrix FTCS
    B = ones(nx,1);
    B = ( r2_fd ) * B;

    % The next vector of ones will be the main diagonal of FTCS
    A = (2 - (2*r2_fd)) * ones(nx,1);

    % Build sparse matrix consisting of diagonals A and D
    FTCS = spdiags([B A B], [-1,0,1], nx, nx);

    % Boundary Conditions
    FTCS(1,1) = 1; FTCS(1,2) = 0;
    FTCS(end,end) = 1; FTCS(end,end-1) = 0;
    %
    % Step one is different, precomputed using Euler method
    U1_fd = 0.5 * FTCS * U0_fd;

    U2_fd = U1_fd;      % Increment time step

    %% Mimetic Scheme Matrix L
    L = lap(k,m,dx);    % mimetic Laplacian operator
    L = r2_md*L;        % premultiply by dt^2 * c^2

    U1_md = U0_md + 0.5*L*U0_md;  % First step, Euler
    U2_md = U1_md;      % Increment time step

    %% FTCS Loop
    % The number of flops is in this step, nnz(U2_fd) *
    nnz_fd = nnz(FTCS);
    tic
    for i = 1 : t
        % Actual Calculations
        U2_fd = FTCS*U1_fd - U0_fd;

        % Shift everyone back.
        U0_fd = U1_fd;
        U1_fd = U2_fd;

    end
    time_fd(ii) = toc;

    % Number of flops
    flops_fd(ii) = (2 * nnz_fd + length(U0_fd) ) * t;
    error_fd(ii) = max(U2_fd-analytic_fd);

    %% Mimetic try
    nnz_md = nnz(L);
    tic
    for i = 1 : t

        % Actual Calculations
        U2_md = 2.0.*U1_md + L*U1_md - U0_md;

        % Shift everyone back.
        U0_md = U1_md;
        U1_md = U2_md;

    end
    time_md(ii) = toc;

    flops_md(ii) = (2 * nnz_md + (4*length(U0_md)) ) * t;
    error_md(ii) = max(U2_md-analytic_md);

end

%% Error analysis

% Regression fit line to error plot, should be close to 2
p_fd = polyfit(log(1./m_points), log(error_fd), 1);
p_md = polyfit(log(1./m_points), log(error_md), 1);
fprintf("Finite Difference Error Convergence Slope:  %3.4f\n", p_fd(1) );
fprintf("Mimetic Difference Error Convergence Slope: %3.4f\n", p_md(1) );

% error plots, should get close to slope of 2
figure(21)
loglog(1./m_points, error_fd); hold on;
loglog(1./m_points, error_md)
xlim([0 1/m_points(1)]);
xlabel('dx'); ylabel('error');
grid on;
title(['Error: FD slope~', num2str(p_fd(1)), ', MD slope~', num2str(p_md(1))]);
legend('FD Error','MD error')

% Time taken, there is some spooling MATLAB does, so may not be
% super accurate. Givne here for reference
figure(31)
plot(m_points, time_fd); hold on;
plot(m_points, time_md);
xlim([m_points(1) m_points(end)]);
ylim([min( min(time_fd), min(time_md) )  max( max(time_fd), max(time_md) )]);
xlabel('num points'); ylabel('time [s]');
grid on;
title(['Time taken, MD is order ', num2str(k)]);
legend('FD time', 'MD time');

% How much more time does the mimetic method take over the
% standard finite difference method
figure(32)
plot(m_points, time_md./time_fd);
xlim([ m_points(1) m_points(end) ]); ylim([ 0.5 2 ]);
xlabel('num points'); ylabel('times slower');
grid on;
title(['Slowdown for MD of order ', num2str(k)]);
legend('Time Ratio MD/FD');

% Floating point operations needed for each method.
figure(35)
loglog(m_points, flops_fd); hold on;
loglog(m_points, flops_md);
xlim([ m_points(1) m_points(end) ]); ylim([ 1e5 1e8 ]);
xlabel('num cells'); ylabel('FLOPs');
grid on;
title(['FLOPs for each method, mimetic order:', num2str(k)]);
legend('FD FLOPs', 'MD FLOPs');
