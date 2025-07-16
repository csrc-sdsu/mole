% -------------------------------------------------------------------------
% mendel1D: One-Dimensional Poro-Thermoelastic Analytical Pressure Solution
%
% Computes the analytical solution for excess pore pressure in a saturated
% poroelastic medium under transient loading using Fourier series.
%
% Pressure evolution is governed by a diffusion equation with thermal coupling:
%
%   ∂p/∂t = C_v ∂²p/∂x² + C_2 df(t)/dt    in (0, a)
%
% This file computes p(x, t) analytically and prepares for comparison with
% future numerical MOLE-based simulations.
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2025 San Diego State University Research Foundation (SDSURF).
% ----------------------------------------------------------------------------

clc; clear; close all;

%% Parameters
a = 5;                    % Half-width [m] (domain: x ∈ [-a, a])
m = 100;                  % Number of cells
dx = 2*a / m;             
xgrid = linspace(-a, a, m+1)';   % Includes both ends

% Mechanical/poroelastic properties (from mendel2D)
E = 1e9;                  % Young's modulus [Pa]
nu = 0.25;                % Poisson's ratio
alpha = 1.0;              % Biot coefficient
Ss = 1e-5;                % Specific storage [1/Pa]
F = 1e6;                  % Applied force [N/m]
Cv = 1e-6;                % Consolidation coefficient [m^2/s]

% Derived quantity: P0 from Mandel's equation
P0 = (F / a) * ((1 - 2*nu)*(1 + nu)) / (Ss * E + 2 * alpha^2 * (1 + nu)*(1 - 2*nu));

% Time snapshots (in seconds)
times_sec = [0.1, 1, 2, 5, 10];

% Series truncation
N_max = 100;

%% Analytical Pressure Solution
p_analytical = zeros(length(xgrid), length(times_sec));

% Domain: x ∈ [0, a] (half-domain)
xgrid = linspace(0, a, m+1)';

% Fourier roots α_i
alpha_i = (1:N_max)' * pi / 2;

% Main loop
for ti = 1:length(times_sec)
    t = times_sec(ti);
    p = zeros(size(xgrid));
    
    for i = 1:N_max
        alpha_val = alpha_i(i);
        omega_i = (alpha_val^2 * Cv) / a^2;
        coeff = sin(alpha_val) / (alpha_val - sin(alpha_val)*cos(alpha_val));
        spatial_term = cos(alpha_val * xgrid / a) - cos(alpha_val);
        decay = exp(-omega_i * t);
        p = p + coeff * spatial_term * decay;
    end

    p_analytical(:,ti) = 2 * P0 * p;
end

%% Plot: Pressure profiles at different times
figure('Name','Analytical Pressure Solution (1D)');
set(gcf,'Color','white');
hold on;
colors = lines(length(times_sec));

for ti = 1:length(times_sec)
    plot(xgrid, p_analytical(:,ti)/1e6, '-', 'LineWidth', 2, ...
        'Color', colors(ti,:), ...
        'DisplayName', ['t = ' num2str(times_sec(ti)) ' s']);
end

xlabel('x (m)');
ylabel('Excess Pore Pressure p(x,t) [MPa]');
title('Analytical 1D Solution for Mandel Problem');
legend('Location','SouthEast');
grid on;
