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
mole_lib_path = fullfile(current_folder, '..', '..', '..', 'src', 'matlab_octave');
if exist(mole_lib_path, 'dir'), addpath(mole_lib_path); end

fprintf('Running Comparative Convergence Test (Mimetic vs FD)\n');
fprintf('--------------------------------------------------\n');

mesh_sizes = [20, 40, 80, 160, 320];
n_sims = length(mesh_sizes);
c = 2;
m_finest = max(mesh_sizes);
dx_finest_mimetic = 1.0 / m_finest;
% CFL condition based on finest mesh: dt <= dx / c.
% We use a safety factor of 0.25
dt_fixed = 0.25 * dx_finest_mimetic / c;

fprintf('Configuration: Fixed dt = %.5e (Ensures stability for all meshes)\n', dt_fixed);

results = struct('dx_mim', zeros(n_sims,1), 'dx_fd', zeros(n_sims,1), ...
                 'm', zeros(n_sims,1), ...
                 'err_mim', zeros(n_sims,1), 'rate_mim', zeros(n_sims,1), ...
                 'err_fd', zeros(n_sims,1), 'rate_fd', zeros(n_sims,1));

for i = 1:n_sims
    m = mesh_sizes(i);
    results.m(i) = m;

    % --- MIMETIC SOLVER (Staggered Grid) ---
    [results.err_mim(i), results.dx_mim(i)] = wave1d_solver(m, dt_fixed);

    % --- FD SOLVER (Nodal Grid, m+2 points) ---
    [results.err_fd(i), results.dx_fd(i)]   = wave1d_solver_fd(m, dt_fixed);

    % Compute Convergence Rates
    if i > 1
        % Rate = log(E_prev/E_curr) / log(dx_prev/dx_curr)
        log_dx_mim = log(results.dx_mim(i-1) / results.dx_mim(i));
        results.rate_mim(i) = log(results.err_mim(i-1) / results.err_mim(i)) / log_dx_mim;

        log_dx_fd = log(results.dx_fd(i-1) / results.dx_fd(i));
        results.rate_fd(i)  = log(results.err_fd(i-1) / results.err_fd(i)) / log_dx_fd;
    end
end

% --- Display Table ---
fprintf('\n### Convergence Comparison: Mimetic vs Standard FD\n');
fprintf('Note: Time step dt is fixed. Comparison targets spatial order ~2.0.\n\n');
fprintf('| Cells(m) | Mimetic Err | Rate | FD Error   | Rate |\n');
fprintf('| :---     | :---        | :--- | :---       | :--- |\n');

for i = 1:n_sims
    r_mim = '-'; r_fd = '-';
    if i > 1
        r_mim = sprintf('%.2f', results.rate_mim(i));
        r_fd  = sprintf('%.2f', results.rate_fd(i));
    end
    fprintf('| %-8d | %.3e   | %s | %.3e  | %s |\n', ...
        mesh_sizes(i), results.err_mim(i), r_mim, results.err_fd(i), r_fd);
end

% --- Optional Plotting
%{
if ~exist('OCTAVE_VERSION', 'builtin') || ~isempty(getenv('DISPLAY'))
    % Figure 1: Error vs Grid Spacing (dx)
    figure(1);
    loglog(results.dx_mim, results.err_mim, '-o', 'DisplayName', 'Mimetic');
    hold on;
    loglog(results.dx_fd, results.err_fd, '-x', 'DisplayName', 'FD');
    % Reference line O(h^2) using Mimetic dx
    ref_y = results.err_mim(end) * (results.dx_mim / results.dx_mim(end)).^2;
    loglog(results.dx_mim, ref_y, '--k', 'DisplayName', 'O(h^2)');
    grid on; xlabel('dx'); ylabel('L2 Error'); legend('Location', 'best');
    title('Convergence Comparison: Error vs dx');

    % Figure 2: Error vs Number of Cells (m)
    figure(2);
    loglog(results.m, results.err_mim, '-o', 'DisplayName', 'Mimetic');
    hold on;
    loglog(results.m, results.err_fd, '-x', 'DisplayName', 'FD');
    % Reference line O(m^-2)
    ref_y_m = results.err_mim(1) * (results.m / results.m(1)).^(-2);
    loglog(results.m, ref_y_m, '--k', 'DisplayName', 'O(m^{-2})');
    grid on; xlabel('Cells (m)'); ylabel('L2 Error'); legend('Location', 'best');
    title('Convergence Comparison: Error vs Cells');

    fprintf('\nPlots are commented out by default. Uncomment in script to view.\n');
end
%}
