clc
close all

addpath('../../mole_MATLAB/')

% Parameters
k = 2; % order of accuracy
x = 100; % number of grid points in the x direction
y = 100; % number of grid points in the y direction
t = 200; % number of time steps
dx = 1/100; % space step (m)
dy = dx; % space step (m)
dt = dx / (2 * 1); % time step (s), chosen using Courant condition

% Initialize fields
Hx = zeros(x, y);
Hy = zeros(x, y);
Ez = zeros(x, y);


G = grad2D(k, x, dx, y, dy);
I = interpolNodesToCenters2D(k, x, y);

% Main loop
for t = 1:t
    % Update H fields
    for i = 1:x
        for j = 1:(y - 1)
            Hx(i, j) = Hx(i, j) - dt(IxGxEz);
        end
    end
    
    for i = 1:(x - 1)
        for j = 1:y
            Hy(i, j) = Hy(i, j) + dt(IyGyEz));
        end
    end

    % Update Ez field
    for i = 2:(x-1)
        for j = 2:(y-1)
            Ez(i, j) = Ez(i, j) + dt(IxGxHy - IyGyHx);
        end
    end
    
    % Boundary Conditions for Ez
    Ez(:, 1) = 0;   % Left boundary
    Ez(:, y) = 0;  % Right boundary
    Ez(1, :) = 0;   % Top boundary
    Ez(x, :) = 0;  % Bottom boundary

    % Boundary Conditions for H fields
    Hx(:, 1) = 0;   % Top boundary
    Hx(:, y) = 0;  % Bottom boundary
    Hy(1, :) = 0;   % Left boundary
    Hy(x, :) = 0;  % Right boundary
    
    % Visualization (every few time steps)
    if mod(t, 10) == 0
        imagesc(Ez); colorbar;
        title(['Ez at time step ', num2str(t)]);
        drawnow;
    end
end
