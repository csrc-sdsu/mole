clc
close all
clear

addpath('../../src/matlab_octave')

% Parameters
k = 2;                   % Order of accuracy
m = 20;                  % Number of nodes along x-axis
n = 20;                  % Number of nodes along y-axis
o = 20;                  % Number of nodes along z-axis
dx = 1 / (m - 1);        % Step size along x-axis
dy = 1 / (n - 1);        % Step size along y-axis
dz = 1 / (o - 1);        % Step size along z-axis
dc = [1; 1; 1; 1; 1; 1]; % Dirichlet Coefficients
nc = [0; 0; 0; 0; 0; 0]; % Neumann Coefficients

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);

% Reshape to vectors
xn = reshape(permute(X, [2, 1, 3]), [], 1);
yn = reshape(permute(Y, [2, 1, 3]), [], 1);
zn = reshape(permute(Z, [2, 1, 3]), [], 1);

% Interpolators
INC = interpolNodesToCenters3D(k, m - 1, n - 1, o - 1);
ICFx = interpolCentersToFacesD1D(k, m - 1);
ICFy = interpolCentersToFacesD1D(k, n - 1);
ICFz = interpolCentersToFacesD1D(k, o - 1);
Im = speye(m + 1);
In = speye(n + 1);
Io = speye(o + 1);
ICFx = kron(kron(Io, In), ICFx);
ICFy = kron(kron(Io, ICFy), Im);
ICFz = kron(kron(ICFz, In), Im);

% Staggered Grid
xc = INC * xn;
yc = INC * yn;
zc = INC * zn;
C = xc.^2 + yc.^2 + zc.^2;

Ux = ICFx * xc;
Uy = ICFy * yc;
Uz = ICFz * zc;

Vx = ICFx * xc;
Vy = ICFy * yc;
Vz = ICFz * zc;

Wx = ICFx * xc;
Wy = ICFy * yc;
Wz = ICFz * zc;

% Plot the centers
scatter3(xc(:), yc(:), zc(:), 50, C(:), 'Filled');
title('Given scalar field')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal

% Get 3D curvilinear mimetic gradient
G = grad3DCurv(k, xc, yc, zc, m - 1, dx, n - 1, dy, o - 1, dz, dc, nc);

% Apply the operator to the field
TMP = G*C;
Gx = TMP(1 : m * (n + 1) * (o + 1));
Gy = TMP(m * (n + 1) * (o + 1) + 1 : m * (n + 1) * (o + 1) + (m + 1) * n * (o + 1));
Gz = TMP(m * (n + 1) * (o + 1) + (m + 1) * n * (o + 1) + 1 : end);

% Reshape for visualization
Uxp = Ux(1 : m * (n + 1));
Uyp = Uy(1 : m * (n + 1));
Gxp = Gx(1 : m * (n + 1));
Uxp = reshape(Uxp, m, n + 1)';
Uyp = reshape(Uyp, m, n + 1)';
Gxp = reshape(Gxp, m, n + 1)';

Vxp = Vx(1 : (m + 1) * n);
Vyp = Vy(1 : (m + 1) * n);
Gyp = Gy(1 : (m + 1) * n);
Vxp = reshape(Vxp, m + 1, n)';
Vyp = reshape(Vyp, m + 1, n)';
Gyp = reshape(Gyp, m + 1, n)';

Wxp = reshape(Wx, m + 1, n + 1, o);
Wzp = reshape(Wz, m + 1, n + 1, o);
Gzp = reshape(Gz, m + 1, n + 1, o);
Wxp = squeeze(Wxp(:, 1, :));
Wzp = squeeze(Wzp(:, 1, :));
Gzp = squeeze(Gzp(:, 1, :));

figure
surf(Uxp, Uyp, Gxp, 'EdgeColor', 'none')
title('Gx Approximate')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
view([0 90])
shading interp

figure
surf(Vxp, Vyp, Gyp, 'EdgeColor', 'none')
title('Gy Approximate')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
view([0 90])
shading interp

figure
surf(Wxp, Wzp, Gzp, 'EdgeColor', 'none')
title('Gz Approximate')
xlabel('x')
ylabel('z')
zlabel('y')
axis equal
view([0 90])
shading interp

figure
surf(Uxp, Uyp, 2 * Uxp, 'EdgeColor', 'none')
title('Gx Analytical')
xlabel('x')
ylabel('y')
zlabel('Gx')
axis equal
view([0 90])
shading interp

figure
surf(Vxp, Vyp, 2 * Vyp, 'EdgeColor', 'none')
title('Gy Analytical')
xlabel('x')
ylabel('y')
zlabel('Gy')
axis equal
view([0 90])
shading interp

figure
surf(Wxp, Wzp, 2 * Wzp, 'EdgeColor', 'none')
title('Gz Analytical')
xlabel('x')
ylabel('z')
zlabel('Gz')
axis equal
view([0 90])
shading interp

l2_norm_u = norm(Gx - 2 * Ux);
l2_norm_v = norm(Gy - 2 * Vy);
l2_norm_w = norm(Gz - 2 * Wz);

disp("L2 norm of U: " + l2_norm_u)
disp("L2 norm of V: " + l2_norm_v)
disp("L2 norm of W: " + l2_norm_w)