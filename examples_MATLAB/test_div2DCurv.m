% Tests the 2D curvilinear divergence
clc
close all

addpath('../mole_MATLAB')

% Parameters
k = 2;
m = 20;
n = 20;

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

% Interpolate U values
Ugiven = sin(X);
interpolant = scatteredInterpolant([X(:) Y(:)], Ugiven(:));
U = interpolant(Ux, Uy);
% Interpolate V values
Vgiven = cos(Y);
interpolant = scatteredInterpolant([X(:) Y(:)], Vgiven(:));
V = interpolant(Vx, Vy);
% Interpolate C values
Cgiven = cos(X)-sin(Y);
interpolant = scatteredInterpolant([X(:) Y(:)], Cgiven(:));

% West-East sides
Cx = [Ux(:, 1) Cx];
Cy = [Uy(:, 1) Cy];
Cx = [Cx Ux(:, end)];
Cy = [Cy Uy(:, end)];

% South-North sides
Cx = [[0 Vx(1, :) 0]; Cx];
Cy = [[0 Vy(1, :) 0]; Cy];
Cx = [Cx; [0 Vx(end, :) 0]];
Cy = [Cy; [0 Vy(end, :) 0]];

% Corners
Cx(1, 1) = X(1, 1);
Cy(1, 1) = Y(1, 1);
Cx(1, end) = X(1, end);
Cy(1, end) = Y(1, end);
Cx(end, 1) = X(end, 1);
Cy(end, 1) = Y(end, 1);
Cx(end, end) = X(end, end);
Cy(end, end) = Y(end, end);

C = interpolant(Cx, Cy);

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