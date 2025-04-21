% rectwg_1d.m - 1D Rectangular Waveguide Mode Solver (TE and TM Modes)
close all; clear; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DASHBOARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lam0 = 1.55;             % Wavelength [microns]
n_core = 3.4;
n_clad = 1.44;
w_core = 2.0;            % Core width [microns]
w_buffer = 3.0;          % Cladding buffer
NRES = 50;               % Points per wavelength
dx = lam0 / NRES;
x_max = w_core/2 + w_buffer;
x = -x_max:dx:x_max;
Nx = length(x);
Nmodes = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BUILD REFRACTIVE INDEX PROFILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = n_clad * ones(size(x));
n(abs(x) <= w_core/2) = n_core;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TE MODE SOLVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k0 = 2 * pi / lam0;
dx2 = dx^2;
main_diag = -2 * ones(Nx,1);
off_diag  = ones(Nx,1);
L = spdiags([off_diag, main_diag, off_diag], [-1 0 1], Nx, Nx) / dx2;
A_TE = L + diag((k0 * n).^2);
[Ey_TE, D_TE] = eigs(A_TE, Nmodes, 'LR');
beta_TE = sqrt(diag(D_TE));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TM MODE SOLVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inv_n2 = 1 ./ n.^2;
D_invn2 = spdiags(inv_n2(:), 0, Nx, Nx);
L_TM = spdiags([off_diag, main_diag, off_diag], [-1 0 1], Nx, Nx) / dx2;
A_TM = -L_TM * D_invn2;
B_TM = D_invn2 * k0^2;

[Ez_TM, D_TM] = eigs(A_TM, B_TM, Nmodes, 'LR');
beta_TM = sqrt(diag(D_TM));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING TE MODES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Name', 'TE Modes', 'Color','w');
for m = 1:Nmodes
    subplot(Nmodes,1,m);
    plot(x, real(Ey_TE(:,m))/max(abs(Ey_TE(:,m))), 'b', 'LineWidth', 2);
    yline(0,'k:');
    title(['TE Mode ', num2str(m), ', \beta = ', num2str(beta_TE(m), '%.4f')]);
    xlabel('x [\mum]');
    ylabel('E_y(x)');
    grid on;
end
sgtitle('1D Rectangular Waveguide - TE Modes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING TM MODES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Name', 'TM Modes', 'Color','w');
for m = 1:Nmodes
    subplot(Nmodes,1,m);
    plot(x, real(Ez_TM(:,m))/max(abs(Ez_TM(:,m))), 'r', 'LineWidth', 2);
    yline(0,'k:');
    title(['TM Mode ', num2str(m), ', \beta = ', num2str(beta_TM(m), '%.4f')]);
    xlabel('x [\mum]');
    ylabel('E_z(x)');
    grid on;
end
sgtitle('1D Rectangular Waveguide - TM Modes');
