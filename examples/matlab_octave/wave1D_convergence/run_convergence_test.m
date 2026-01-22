% =========================================================================
% Example: 2nd Order Convergence for 1D Wave Equation (Hyperbolic)
% Language: MATLAB / Octave
% =========================================================================
%
% Reference:
%    Problem based on "Example 10.1" from:
%    Mathews, J. H., & Fink, K. D. (2004). Numerical methods using MATLAB
%    (4th ed.). Pearson Prentice Hall.
%
% Context:
%    This example was presented during the postgraduate course "Introduction
%    to Mimetic Difference Methods and Applications", taught by Prof. Jose
%    Castillo in October 2023 at the Faculty of Exact Sciences, Engineering
%    and Surveying (FCEIA) of the National University of Rosario (UNR),
%    Argentina.
%
% Mathematical Formulation:
%    d2u/dt2 = 4 * d2u/dx2   on Omega = [0, 1] x [0, 0.5]
%    (Comparing with standard form u_tt = c^2 u_xx, this implies c = 2)
%
% Domain Description:
%    - Spatial: x in [0, 1]
%    - Temporal: t in [0, 0.5]
%    - Grid: Staggered grid (Mimetic Discretization)
%
% Boundary Conditions (Dirichlet):
%    u(0, t) = 0
%    u(1, t) = 0
%
% Initial Conditions:
%    u(x, 0) = sin(pi*x) + sin(2*pi*x)
%    du/dt(x, 0) = 0
%
% Analytical Solution (Exact):
%    u(x, t) = sin(pi*x)cos(2*pi*t) + sin(2*pi*x)cos(4*pi*t)
%
% Implementation Details:
%    - Spatial Scheme: Mimetic Finite Differences (Order k=2) vs Standard FD
%    - Time Integration: Verlet Algorithm (Symplectic, 2nd order, Leapfrog equivalent)
%    - Library: MOLE (MATLAB/Octave implementation)
%
% Output:
%    - Console: Table of L2 errors and convergence rates.
%    - Figure 1: Error vs Grid Spacing (dx) [Comparison]
%    - Figure 2: Error vs Number of Cells (m) [Comparison]
%    - Figure 3: Wave Profile Comparison (Coarse grid m=20 to visualize error)
%
% Author: Martin S. Armoa
% Programming Assistant: Google Gemini 3 PRO via VS Code
% =========================================================================
clear; clc; close all;

% --- 1. Path Configuration ---
current_file = mfilename('fullpath');
[current_folder, ~, ~] = fileparts(current_file);
addpath(current_folder);
mole_lib_path = fullfile(current_folder, '..', '..', '..', 'matlab_octave');
if exist(mole_lib_path, 'dir'), addpath(mole_lib_path); end

fprintf('Running Comparative Convergence Test (Mimetic vs FD)\n');
fprintf('--------------------------------------------------\n');

mesh_sizes = [20, 40, 80, 160, 320];
n_sims = length(mesh_sizes);

% Results Storage
results = struct('dx', zeros(n_sims,1), 'm', zeros(n_sims,1), ...
                 'err_mim', zeros(n_sims,1), 'rate_mim', zeros(n_sims,1), ...
                 'err_fd', zeros(n_sims,1), 'rate_fd', zeros(n_sims,1));


u_plot_mim = []; u_plot_fd = []; x_plot = []; m_plot = 0;

for i = 1:n_sims
    m = mesh_sizes(i);
    results.m(i) = m;

    % Run Solvers
    [results.err_mim(i), dx, u_mim, x] = wave1d_solver(m);
    [results.err_fd(i), ~ , u_fd, ~]   = wave1d_solver_fd(m);

    results.dx(i) = dx;

    if i == 1
        u_plot_mim = u_mim;
        u_plot_fd = u_fd;
        x_plot = x;
        m_plot = m;
    end

    % Compute Rates
    if i > 1
        log_dx = log(results.dx(i-1) / results.dx(i));
        results.rate_mim(i) = log(results.err_mim(i-1) / results.err_mim(i)) / log_dx;
        results.rate_fd(i)  = log(results.err_fd(i-1) / results.err_fd(i)) / log_dx;
    end
end

% --- 2. Display Table ---
fprintf('\n### Convergence Comparison: Mimetic vs Standard FD\n\n');
fprintf('| Cells (m) | Mimetic Error | Rate | FD Error | Rate |\n');
fprintf('| :--- | :--- | :--- | :--- | :--- |\n');
for i = 1:n_sims
    r_mim = '-'; r_fd = '-';
    if i > 1, r_mim = sprintf('%.2f', results.rate_mim(i)); r_fd = sprintf('%.2f', results.rate_fd(i)); end
    fprintf('| %d | %.3e | %s | %.3e | %s |\n', mesh_sizes(i), results.err_mim(i), r_mim, results.err_fd(i), r_fd);
end

% --- 3. Plotting ---
if ~exist('OCTAVE_VERSION', 'builtin') || ~isempty(getenv('DISPLAY'))

    % Fig 1 & 2: Convergence Rates
    figure(1); loglog(results.dx, results.err_mim, '-o', results.dx, results.err_fd, '-x');
    hold on; loglog(results.dx, results.err_mim(end)*(results.dx/results.dx(end)).^2, '--k');
    grid on; xlabel('dx'); ylabel('L2 Error'); legend('Mimetic','FD','O(h^2)'); title('Convergence vs dx');
    print('convergence_vs_dx.png', '-dpng');

    figure(2); loglog(results.m, results.err_mim, '-o', results.m, results.err_fd, '-x');
    hold on; loglog(results.m, results.err_mim(1)*(results.m/results.m(1)).^(-2), '--k');
    grid on; xlabel('Cells (m)'); ylabel('L2 Error'); legend('Mimetic','FD','O(m^{-2})'); title('Convergence vs Cells');
    print('convergence_vs_cells.png', '-dpng');

    % fig 3: Wave Profile
    figure(3);
    set(gcf, 'color', 'w');

    % Exact solution
    c = 2; T_final = 0.5;
    u_exact_plot = sin(pi*x_plot)*cos(pi*c*T_final) + sin(2*pi*x_plot)*cos(2*pi*c*T_final);

    % Plot
    plot(x_plot, u_plot_mim, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', ['Mimetic (m=' num2str(m_plot) ')']);
    hold on;
    plot(x_plot, u_plot_fd, '--x', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Finite Diff.');

    x_fine = linspace(0, 1, 500);
    u_exact_fine = sin(pi*x_fine)*cos(pi*c*T_final) + sin(2*pi*x_fine)*cos(2*pi*c*T_final);
    plot(x_fine, u_exact_fine, 'k', 'LineWidth', 1, 'DisplayName', 'Exact Solution');

    title(['Coarse Grid Comparison (High Error Visualization) - m = ' num2str(m_plot)]);
    xlabel('x'); ylabel('u(x,T)');
    grid on;
    legend('Location', 'best');

    print('wave_profile_coarse.png', '-dpng');
    fprintf('\nGráficos generados. Revisa "wave_profile_coarse.png" para ver el error visible.\n');
end
