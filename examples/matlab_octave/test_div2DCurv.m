% Tests the 2D curvilinear divergence
clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 20;
n = 30;

% Grid
r1 = 1; % Inner radius
r2 = 2; % Outer radius
nR = linspace(r1, r2, m) ;
nT = linspace(0, 2*pi, n) ;
[R, T] = meshgrid(nR, nT) ;
% Convert grid to cartesian coordinates
X = R.*cos(T);
Y = R.*sin(T);

% Test on another grid
% [X, Y] = genCurvGrid(n, m);

mesh(X, Y, zeros(n, m), 'Marker', '.', 'MarkerSize', 10)
%    Az  El
view([0 90])
axis equal
hold on

[n, m] = size(X);
n = n-1;
m = m-1;

Ux = (X(1:end-1, :) + X(2:end, :))/2;
Uy = (Y(1:end-1, :) + Y(2:end, :))/2;
scatter3(Ux(:), Uy(:), zeros(n*(m+1), 1), '+', 'MarkerEdgeColor', 'k')

Vx = (X(:, 1:end-1) + X(:, 2:end))/2;
Vy = (Y(:, 1:end-1) + Y(:, 2:end))/2;
scatter3(Vx(:), Vy(:), zeros((n+1)*m, 1), '*', 'MarkerEdgeColor', 'k')

Cx = (Vx(1:end-1, :) + Vx(2:end, :))/2;
Cy = (Uy(:, 1:end-1) + Uy(:, 2:end))/2;
scatter3(Cx(:), Cy(:), zeros(n*m, 1), '.', 'MarkerEdgeColor', 'r')

%% Interpolators
% Some useful numbers
num_nodes = (m+1)*(n+1);
num_centers = (m+2)*(n+2);
num_u = (m+1)*n;
num_v = m*(n+1);

% MOLE Interpolator Matrices of 'k' order
NtoC = interpolNodesToCenters2D(k, n, m);
CtoF = interpolCentersToFacesD2D(k, n, m); % V is the top part!!

% Center to specific face, u or v
CtoV = CtoF(1:(n+1)*m, 1:num_centers);
CtoU = CtoF((n+1)*m+1:end, num_centers+1:end);

% Node to X interpolator is pre-multiplied
NtoU = CtoU * NtoC;
NtoV = CtoV * NtoC;

% Interpolate U values
Ugiven = sin(X);
U = NtoU * Ugiven(:);
U = reshape(U,n,m+1);

% Interpolate V values
Vgiven = cos(Y);
V = NtoV * Vgiven(:);
V = reshape(V,n+1,m);

Cgiven = cos(X)-sin(Y);
C = NtoC * Cgiven(:);
C = reshape(C,n+2,m+2);

% Interpolate Nodal grid to centered grid.
Cx = NtoC * X(:);
Cx = reshape(Cx,n+2,m+2);

Cy = NtoC * Y(:);
Cy = reshape(Cy, n+2,m+2);

scatter3(Cx(:), Cy(:), zeros((m+2)*(n+2), 1), 'o', 'MarkerEdgeColor', 'r')
legend('Nodal points', 'u', 'v', 'Centers', 'All centers')
hold off

tic
D = div2DCurv(k, X, Y);
toc

Ccomp = D*[reshape(U', [], 1); reshape(V', [], 1)];
Ccomp = reshape(Ccomp, m+2, n+2);

figure
subplot(2, 1, 1)
surf(Cx(2:end-1, 2:end-1), Cy(2:end-1, 2:end-1), C(2:end-1, 2:end-1), 'EdgeColor', 'none');
view([0 90])
colorbar
title('Exact')
xlabel('x')
ylabel('y')
axis equal
shading interp
subplot(2, 1, 2)
surf(Cx(2:end-1, 2:end-1), Cy(2:end-1, 2:end-1), Ccomp(2:end-1, 2:end-1)', 'EdgeColor', 'none')
view([0 90])
colorbar
title('Approx')
xlabel('x')
ylabel('y')
axis equal
shading interp
