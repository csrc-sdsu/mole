clc;
clear all;
close all;

addpath('mole-master/mole-master/mole_MATLAB/');

% Define the grid size and time step
Nx = 5; % size along x
Ny = 5; % size along y
Nt = 50; % number of time steps
dx = 1/Nx; % cell size (meters)
dy = 1/Ny;
dt = 0.1; % time step (s)

% Time vector from 0 to Nt*dt with step size dt
t_vec = 0:dt:Nt*dt;

% Spatial coordinates assuming data at the cell centers
x = [0 dx/2:dx:1-dx/2 1];
y = x; 

% Create a meshgrid of x and y coordinates
[X,Y] = meshgrid(x,y);

% Material parameters set to 1 (for simplicity)
epsilon = 1; % relative permittivity
mu = 1; % relative permeability

% Define the mimetic gradient operator
k = 2; % second-order accuracy
G = grad2D(k, Nx, dx, Ny, dy);
Gx = G(1:end/2, :);
Gy = G(end/2+1:end, :);

% Define the interpolation operator from faces to centers
I = interpolFacesToCentersG2D(k, Nx, Ny);
Ix = I(1:end/2, 1:end/2);
Iy = I(end/2+1:end, end/2+1:end);

% Parameters for the exact solution
w = 2 * pi / 0.3; % angular frequency
Q = @(s) double(s > 0);

% Initial conditions at t = 0
Hx(:,:) = 0;
Hy(:,:) = -sin(w * (X)) .* Q(-X);
Ez(:,:) = sin(w * (X)) .* Q(-X);

% Error initialization
error_Hy = zeros(1, Nt);
error_Ez = zeros(1, Nt);

% Main FDTD loop
for t_idx = 1:length(t_vec)
    % Current time
    t = t_vec(t_idx);

    % Update H field
    Ez_vec = reshape(Ez,[],1);
    Hx_vec = reshape(Hx,[],1);
    Hy_vec = reshape(Hy,[],1);
    
    Hx_vec = Hx_vec - dt/mu * (Ix * (Gx * Ez_vec));
    Hy_vec = Hy_vec + dt/mu * (Iy * (Gy * Ez_vec));

    % Update E field
    Ez_vec = Ez_vec + dt/epsilon * ((Ix * (Gx * Hy_vec)) - (Iy * (Gy * Hx_vec)));

    % Reshape back to field matrices
    Hx = reshape(Hx_vec, [Nx+2, Ny+2]);
    Hy = reshape(Hy_vec, [Nx+2, Ny+2]);
    Ez = reshape(Ez_vec, [Nx+2, Ny+2]);

    
    Hy(:,1) = -sin(w * t) * Q(t); % H_y at x = 0
    Ez(:,1) = sin(w * t) * Q(t);  % E_z at x = 0

    % Right side (x = 1)
    Hy(:,end) = -sin(w * (t - 1)) * Q(t - 1); % H_y at x = 1
    Ez(:,end) = sin(w * (t - 1)) * Q(t - 1);  % E_z at x = 1

    % Bottom side (y = 0) - Assuming similar conditions as x = 0
    Hy(1,:) = -sin(w * t) * Q(t); % H_y at y = 0
    Ez(1,:) = sin(w * t) * Q(t);  % E_z at y = 0

    % Top side (y = 1) - Assuming similar conditions as x = 1
    Hy(end,:) = -sin(w * (t - 1)) * Q(t - 1); % H_y at y = 1
    Ez(end,:) = sin(w * (t - 1)) * Q(t - 1);  % E_z at y = 1
    % 
    % Exact solution for comparison
    Hx_exact = X*0;
    Hy_exact = -sin(w * (X-t)) .* Q(t-X);
    Ez_exact = sin(w * (X-t)) .* Q(t-X);

    % Calculate error
    error_Hy(t_idx) = norm(Hy(:) - Hy_exact(:));
    error_Ez(t_idx) = norm(Ez(:) - Ez_exact(:));

    % Visualize the field
    % Visualize the field
    subplot(2, 3, 1);
    surf(X, Y, Hx.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Hx at time step ', num2str(t_idx)]);
    axis tight;

    subplot(2, 3, 2);
    surf(X, Y, Hy.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Hy at time step ', num2str(t_idx)]);
    axis tight;
    
    subplot(2, 3, 3);
    surf(X, Y, Ez.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Ez at time step ', num2str(t_idx)]);
    axis tight;
    
    subplot(2, 3, 4);
    surf(X, Y, Hx_exact.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Exact Hx at time step', num2str(t_idx)]);
    axis tight;

    subplot(2, 3, 5);
    surf(X, Y, Hy_exact.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Exact Hy at time step ', num2str(t_idx)]);
    axis tight;

    subplot(2, 3, 6);
    surf(X, Y, Ez_exact.');
    shading interp;
    colormap(parula);
    colorbar;
    title(['Exact Ez at time step ', num2str(t_idx)]);
    axis tight;

    drawnow;
end

% Plot error over time
figure;
subplot(2, 1, 1);
plot(t_vec, error_Hy, 'b-', 'LineWidth', 2);
hold on;
plot(t_vec, error_Ez, 'r--', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error');
legend('Error in Hy', 'Error in Ez');
title('Error evolution over time');
hold off;
