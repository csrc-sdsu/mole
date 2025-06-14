% Tests the 2D curvilinear laplacian on a noisy grid
clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 10;
n = 10;

% Function handles
F = @(X, Y) (X-m/2).^2+(Y-n/2).^2;
f = @(X, Y) 4*ones(size(X));

[X, Y] = meshgrid(1:m, 1:n);
% Add some uniform random noise
rng(1);
X = X + 0.25*rand(size(X));
Y = Y + 0.25*rand(size(Y));

mesh(X, Y, zeros(n, m), 'Marker', '.', 'MarkerSize', 10)
view([0 90])
axis tight
set(gcf, 'Color', 'w')
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

scatter3(Cx(:), Cy(:), zeros((m+2)*(n+2), 1), 'o', 'MarkerEdgeColor', 'r')
legend('Nodal points', 'u', 'v', 'Centers', 'All centers')
hold off

% Get curvilinear mimetic operators
tic
D = div2DCurv(k, X, Y);
toc
tic
G = grad2DCurv(k, X, Y);
toc
tic
L = D*G;
toc

% Impose boundary conditions
Robin = robinBC2D(k, m, 1, n, 1, 1, 0);
L = L + Robin;
figure
spy(L)
title('Laplacian')

Robin = diag(Robin);
bdry = find(Robin);
B = f(Cx, Cy);
B = reshape(B.', [], 1);
B2 = F(Cx, Cy);
B2 = reshape(B2.', [], 1);
B(bdry) = B2(bdry);

% Solve the system
Comp = L\B;
Comp = reshape(Comp, m+2, n+2)';

% Plot results
figure
subplot(2, 1, 1)
surf(Cx, Cy, F(Cx, Cy), 'EdgeColor', 'none')
title('Exact')
xlabel('x')
ylabel('y')
set(gcf, 'Color', 'w')
colorbar
subplot(2, 1, 2)
surf(Cx, Cy, Comp, 'EdgeColor', 'none')
title('Approx')
xlabel('x')
ylabel('y')
set(gcf, 'Color', 'w')
colorbar

% Show error
figure
surf(Cx, Cy, F(Cx, Cy)-Comp, 'EdgeColor', 'none')
title('Error')
view([0 90])
xlabel('x')
ylabel('y')
set(gcf, 'Color', 'w')
colorbar

fprintf('Maximum error: %.2f\n', max(max(abs(F(Cx, Cy)-Comp))))
fprintf('Relative error: %.2f%%\n', 100*max(max(abs(F(Cx, Cy)-Comp)))/(max(max(F(Cx, Cy))) - min(min(F(Cx, Cy)))))
