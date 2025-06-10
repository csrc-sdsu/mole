%% 2D Lock exchange test case using mimetic methods
% It uses Boussinesq's approximation to solve for nonisothermal flow.
% Due to the coarseness of the grid being used, numerical diffusion acts to
% limit the formation of the billows along the interface. Sharp billows can
% easily be obtained by increasing the resolution.

clc
close all

%% MOLE'S path so mimetic methods can be used
addpath('../../src/matlab_octave')

tic  % Start the timer
%--------------------------------------------------------------------------

%% Grid [a b]x[c d] in meters
a = 0;
b = 100;
c = 0;
d = 20;
m = 100;       % Number of cells along x-axis
n = 20;        % Number of cells along y-axis
dx = (b-a)/m;  % Step size along x- and y-axis, respectively
dy = (d-c)/n;

% Rectangular grid with physical coordinates
[X, Y] = meshgrid([a a+dx/2 : dx : b-dx/2 b], [c c+dy/2 : dy : d-dy/2 d]);

% Density
rho = zeros(n+2, m+2);
% Temperature
T = zeros(n+2, m+2);
% Pressure
p = zeros(n+2, m+2);
% u-velocity
u = zeros(n, m+1);
% v-velocity
v = zeros(n+1, m);

%% Parameters (for seawater @ S = 35)
alpha = 1.664e-4;        % 1/°C Coefficient of thermal expansion
T_0 = 10;                % °C Reference temperature
rho_0 = 1027;            % kg/m3 Reference density
interface_width = 0.1;   % m Width of the interface
g = 9.806;               % m/s2 Gravity acceleration
reduced_gravity = 0.01;  % m/s2 Reduced gravity
delta_rho = reduced_gravity*rho_0/g;  % Density difference between the two fluids

% Time parameters
time = 200;              % s Simulation time
dt = 1;                  % s Time step, based on CFL condition: max(|u|)dt/dx + max(|v|)dt/dy <= 1
iterations = time/dt;    % Number of iterations

%% Initialize densities and temperatures
for j = 1 : m+2
    x = a + (j-1)*dx;
    rho(:, j) = rho_0+delta_rho/2*(1-erf((x-(a+b)/2)/interface_width));
    T(:, j) = (1-rho(1, j)/rho_0)/alpha+T_0;
end

%% Middle points and viscosities
T_middle = (T(1)+T(end))/2;
rho_middle = rho_0*(1-alpha*(T_middle-T_0));  % Could also be calculated as simply (rho(1)+rho(end))/2
mu = 0.00141;                 % kg/(m⋅s) Dynamic viscosity
nu = mu/rho_middle;           % m2/s Kinematic viscosity

%% Mimetic operators
k = 2;                        % Spatial order of accuracy
D = div2D(k, m, dx, n, dy);   % Divergence
G = grad2D(k, m, dx, n, dy);  % Gradient
L = D*G;                      % Laplacian

% Premultiplication of G
G = -dt/rho_middle*G;

% Apply Neumann BCs to Laplacian
L = L+robinBC2D(k, m, dx, n, dy, 0, 1);

% Interpolators
I0 = interpol2D(m, n, 0, 0);  % For downwind
I1 = interpol2D(m, n, 1, 1);  % For upwind

%% Convenient definitions
SOL = zeros(size(D, 2), 1);
rho_dt = rho_middle/dt;
u_length = (m+1)*n;

%% Iterate over time
for t = 1 : iterations
    
    %% Velocity BCs (no-slip)
    u(1, :) = 0;
    u(end, :) = 0;
    v(1, :) = 0;
    v(end, :) = 0;
    u(:, 1) = 0;
    u(:, end) = 0;
    v(:, 1) = 0;
    v(:, end) = 0;
    
    %% Predictor step
    % Mimetic operators could be used here, but for a second-order
    % approximation it will be pointless.
    % u*
    u_s = u;  % We just need the boundaries but this is simpler
    for j = 2 : m
        for i = 2 : n-1
            
            % Centered differencing for diffusion of momentum
            d2u_dy2 = (u(i-1, j)-2*u(i, j)+u(i+1, j))/dy^2;
            d2u_dx2 = (u(i, j-1)-2*u(i, j)+u(i, j+1))/dx^2;
            
            % Sided differencing (based on sign of velocity) for advection
            % of momentum
            if u(i, j) > 0
                udu_dx = u(i, j)*(u(i, j)-u(i, j-1))/dx;
            else
                udu_dx = u(i, j)*(u(i, j+1)-u(i, j))/dx;
            end
            
            vij = 0.25*(v(i, j)+v(i+1, j-1)+v(i+1, j)+v(i, j-1));
            if vij > 0
                vdu_dy = vij*(u(i, j)-u(i-1, j))/dy;
            else
                vdu_dy = vij*(u(i+1, j)-u(i, j))/dy;
            end
            
            % Guess for u using forward Euler's scheme
            u_s(i, j) = u(i, j)+dt*(nu*(d2u_dy2+d2u_dx2)-(udu_dx+vdu_dy));
        end
    end
    
    % v*
    v_s = v;  % We just need the boundaries but this is simpler
    for j = 2 : m-1
        for i = 2 : n
            
            % Centered differencing for diffusion of momentum
            d2v_dy2 = (v(i-1, j)-2*v(i, j)+v(i+1, j))/dy^2;
            d2v_dx2 = (v(i, j-1)-2*v(i, j)+v(i, j+1))/dx^2;
            
            % Sided differencing (based on sign of velocity) for advection
            % of momentum
            if v(i, j) > 0
                vdv_dy = v(i, j)*(v(i, j)-v(i-1, j))/dy;
            else
                vdv_dy = v(i, j)*(v(i+1, j)-v(i, j))/dy;
            end
            
            uij = 0.25*(u(i, j)+u(i-1, j+1)+u(i, j+1)+u(i-1, j));
            if uij > 0
                udv_dx = uij*(v(i, j)-v(i, j-1))/dx;
            else
                udv_dx = uij*(v(i, j+1)-v(i, j))/dx;
            end
            
            % Guess for v using forward Euler's scheme
            v_s(i, j) = v(i, j)+dt*(nu*(d2v_dy2+d2v_dx2)-(vdv_dy+udv_dx)+g*alpha*(T(i, j)-T_middle));
        end
    end
    
    %% Solve for pressure
    u_s = reshape(u_s', [], 1);
    v_s = reshape(v_s', [], 1);
    
    R = rho_dt*[u_s; v_s];
    
    % Poisson's equation (most time-consuming part). Next time better do: dL = decomposition(L) 
    % outside the loop, and use dL instead of L to solve the linear system more efficiently.
    p = L\(D*R);
    
    %% Corrector step
    u = u_s+G(1:u_length, :)*p;
    v = v_s+G(u_length+1:end, :)*p;
    
    %% Advection of heat
    T = reshape(T', [], 1);
    
    % Downwind/Upwind
    UV = [u; v];
    TMP0 = I0*T;
    TMP1 = I1*T;
    for i = 1 : numel(UV)
        if UV(i) < 0
            SOL(i) = TMP0(i);
        else
            SOL(i) = TMP1(i);
        end
    end
    
    % Forward Euler's used here, but can easily be replaced by any RK-method
    T = T-dt*D*(UV.*SOL);
    
    %% Reshaping for next iteration
    T = reshape(T, m+2, n+2)';
    u = reshape(u, m+1, n)';
    v = reshape(v, m, n+1)';
    
    disp(t*dt)
end

%% Plotting
% Pressure
p = reshape(p, m+2, n+2)';
subplot(2, 2, 1)
surf(X(3:end-2, 3:end-2), Y(3:end-2, 3:end-2), p(3:end-2, 3:end-2))
title('p (N/m^2)')
shading interp
axis equal
h = colorbar;
view([0 90])
xlabel('x (m)')
ylabel('y (m)')

% Temperature
subplot(2, 2, 2)
surf(X(3:end-2, 3:end-2), Y(3:end-2, 3:end-2), T(3:end-2, 3:end-2))
title('T in celsius')
shading interp
axis equal
h = colorbar;
view([0 90])
xlabel('x (m)')
ylabel('y (m)')

% u-velocity
subplot(2, 2, 3)
surf(u)
title('u in m/s')
shading interp
axis equal
h = colorbar;
view([0 90])
xlabel('x (m)')
ylabel('y (m)')

% v-velocity
subplot(2, 2, 4)
surf(v)
title('v in m/s')
shading interp
axis equal
h = colorbar;
view([0 90])
xlabel('x (m)')
ylabel('y (m)')

% For compatibility with Octave and MATLAB
S  = axes( 'visible', 'off', 'title', ['t = ' num2str(time) 's'] );
set(gcf, 'color', 'w')
colormap jet

% Get final density profile from temperatures using equation of state
rho = rho_middle*(1-alpha*(T-T_middle));  % Can also use rho_0 and T_0

% Plot the density
figure
surf(X(3:end-2, 3:end-2), Y(3:end-2, 3:end-2), rho(3:end-2, 3:end-2))
title(['\rho (kg/m^3) @ t = ' num2str(time) 's'])
shading interp
axis equal
h = colorbar;
view([0 90])
xlabel('x (m)')
ylabel('y (m)')
set(gcf, 'color', 'w')
colormap jet

%--------------------------------------------------------------------------
toc  % Stop the timer
