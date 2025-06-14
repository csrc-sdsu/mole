% convection_diffusion3D.m | Solves convection-diffusion equation using MOLE

clc
close all
format short

addpath('../../src/matlab_octave')

% Mimetic operator's parameters
k = 2;
m = 101;
n = 51;
o = 101;

% Domain's dimensions
a = 0;
b = 101;
c = 0;
d = 51;
e = 0;
f = 101;

% Spatial step sizes
dx = (b-a)/m;
dy = (d-c)/n;
dz = (f-e)/o;

% Mimetic operators
D = div3D(k, m, dx, n, dy, o, dz);
G = grad3D(k, m, dx, n, dy, o, dz);
I = interpol3D(m, n, o, 1, 1, 1);

% Pore velocity vector
V = zeros(size(G, 1), 1);
% Density vector
C = zeros(m+2, n+2, o+2);

% Impose initial conditions -----------------------------------------------
bottom = 10;  % Well
top = 15;  % Well
seal = 40;  % Shale

% Velocity field ----------------------------------------------------------
y = ones(m, n+1, o);
y(:, seal, :) = 0;
y(:, seal+5, :) = 0;
y = y(:);
V(((m+1)*n*o+1):((m+1)*n*o+numel(y))) = y;  % Shale

% Density -----------------------------------------------------------------
C(ceil((m+2)/2), bottom:top, ceil((o+2)/2)) = 1;  % ceil((o+2)/2)
C = C(:);
idx = find(C);

% Diffusivity and porosity ------------------------------------------------
diff = 1;%[m^2/s] CO2 molecular diffusivity at: 45°C, S = 35, and P = 75atm
porosity = 1;  % Sandstone -> 30%
diff = diff*porosity;
K = diff*ones(size(G, 1), 1);
kk = diff*ones(m, n+1, o);
kk(:, seal, :) = diff/10;
kk(:, seal+5, :) = diff/40;
kk = kk(:);
K(((m+1)*n*o+1):((m+1)*n*o+numel(kk))) = kk;  % Shale
% -------------------------------------------------------------------------

% dt based on von Neumann criterion
dt1 = dx^2/(3*diff)/3;
% dt based on CFL condition
dt2 = (dx/max(V))/3;
% Select minimum dt
dt = min(dt1, dt2);

iters = 120;  % 90 = 30s  if dt = 0.3333 because CFL

% Premultiplication of Laplacian operator
L = dt*D*spdiags(K, 0, numel(K), numel(K))*G;
L = L + speye(size(L));

% Premultiplication of Divergence operator
D = dt*D*spdiags(V, 0, numel(V), numel(V))*I;

for i = 1 : iters*3
    % Solve diffusive term using FTCS scheme
    C = L*C;
    % Impose wellbore conditions
    C(idx) = 1;
    % Solve advective term using upwind scheme
    C = C - D*C;
    % Impose wellbore conditions
    C(idx) = 1;
    
    pause(0.01)
    
    % Plot density profile
    temp = reshape(C, m+2, n+2, o+2);
    pcolor(squeeze(temp(seal,:,:))); %
    shading interp
    set(gca, 'XDir', 'reverse')
    set(gca, 'ZDir', 'reverse')
    set(gcf, 'color', 'w')
    xlabel('y')
    ylabel('x')
    zlabel('z')
    axis equal
    title(['CO_2 concentration profile, t = ' num2str(i*dt, '%2.2f')])
    colorbar
    view(90, 90)
end

min(C)
max(C)
