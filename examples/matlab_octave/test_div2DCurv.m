% Tests the 2D curvilinear divergence
% on an annulus of 1 < r < 2
clc
close all
clear

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 30;
n = 20;
dx = 1 / m;
dy = 1 / n;
dc = [0; 0; 1; 1];
nc = [0; 0; 0; 0];

% Nodal Grid Generation
r1 = 1;
r2 = 2;
nR = linspace(r1, r2, n + 1);
nT = linspace(2 * pi, 0, m + 1);
nT = nT(1:end-1); % No duplicate points
[T, R] = meshgrid(nT, nR);
X = R .* cos(T);
Y = R .* sin(T);

xn = reshape(X', [], 1);
yn = reshape(Y', [], 1);

% Interpolators
NtoC = interpolNodesToCenters2D(k, m, n, dc, nc);
CtoU = interpolCentersToFacesD1DPeriodic(k, m);
CtoU = kron(speye(n + 2), CtoU); % From the centers to the extended faces
CtoV = interpolCentersToFacesD1D(k, n);
CtoV = kron(CtoV, speye(m)); % From the centers to the extended faces

% Plot Mesh
mesh([X X(:, 1)], [Y Y(:, 1)], zeros(n + 1, m + 1), 'Marker', '.', 'MarkerSize', 10)
view(0, 90)
axis equal
hold on

Ux = CtoU * NtoC * xn;
Uy = CtoU * NtoC * yn;
scatter3(Ux, Uy, zeros(size(Ux)), '+', 'MarkerEdgeColor', 'k')

Vx = CtoV * NtoC * xn;
Vy = CtoV * NtoC * yn;
scatter3(Vx, Vy, zeros(size(Vx)), '*', 'MarkerEdgeColor', 'k')

Cx = NtoC * xn;
Cy = NtoC * yn;
scatter3(Cx, Cy, zeros(size(Cx)), 'o', 'MarkerEdgeColor', 'r')
legend("Nodal Points", "u", "v", "Centers")
hold off

tic
D = div2DCurv(k, Cx, Cy, m, dx, n, dy, dc, nc);
toc

% Vector Field
U = sin(Ux);
V = cos(Vy);

% Exact Solution
C = cos(Cx) - sin(Cy);
C = reshape(C, m, n + 2)';

% Approximate Solution
Ccomp = D * [U; V];
Ccomp = reshape(Ccomp, m, n + 2)';

% Remove boundary points (divergence returns 0 on boundaries)
Cx = reshape(Cx, m, n + 2)';
Cy = reshape(Cy, m, n + 2)';
Cx = Cx(2:end-1, :);
Cy = Cy(2:end-1, :);
C = C(2:end-1, :);
Ccomp = Ccomp(2:end-1, :);

% Join left and right sides for plotting
Cx = [Cx Cx(:, 1)];
Cy = [Cy Cy(:, 1)];
C = [C C(:, 1)];
Ccomp = [Ccomp Ccomp(:, 1)];

figure
subplot(2, 1, 1)
surf(Cx, Cy, C, 'EdgeColor', 'none');
view([0 90])
colorbar
title('Exact')
xlabel('x')
ylabel('y')
axis equal
shading interp
subplot(2, 1, 2)
surf(Cx, Cy, Ccomp, 'EdgeColor', 'none')
view([0 90])
colorbar
title('Approx')
xlabel('x')
ylabel('y')
axis equal
shading interp

l2_norm = norm(C(:) - Ccomp(:));
disp("L2 norm: " + l2_norm)