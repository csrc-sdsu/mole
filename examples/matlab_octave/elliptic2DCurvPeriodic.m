clear; clc; close all;
addpath("../../src/matlab_octave/")
% 
% ∆u = 0
% 
% 1 < r < 2
% 0 < θ < 2 pi
% 
% x = r cos(θ)
% y = r sin(θ)
% 
% Dirichlet Boundary Conditions
% 
% Exact solution
% u(x, y) = x^2 - y^2
% 

% Parameters
k = 4;
m = 100;
n = 25;
dx = 2 * pi / m;
dy = 1 / n;
dc = [0;0;1;1];
nc = [0;0;0;0];

% Exact solution
ue = @(X, Y) X.^2 - Y.^2;

% Create Mesh
rs = [1 (1 + dy / 2) : dy : (2 - dy / 2) 2];
ts = 0 : dx : (2*pi - dx);
[T,R] = meshgrid(ts, rs);
xc = R .* cos(T);
yc = R .* sin(T);
xc = reshape(xc', [], 1);
yc = reshape(yc', [], 1);

% Build Operators
G = grad2DCurv(k, xc, yc, m, dx, n, dy, dc, nc);
D = div2DCurv(k, xc, yc, m, dx, n, dy, dc, nc);
L = D * G;

% Boundary Conditions
X = reshape(xc, m, n + 2)'; % Reshape for plotting and easier BC
Y = reshape(yc, m, n + 2)';

u = ue(X, Y);

l = 0; % Left and right boundaries don't exist
r = 0;
b = u(1, :)';
t = u(end, :)';
v = {l; r; b; t};
B = zeros(size(xc));
[L0, B0] = addScalarBC2D(L, B, k, m, dx, n, dy, dc, nc, v);

ua = L0 \ B0;
ua = reshape(ua, m, n + 2)';

% Plot results
% Join left and right edges for nicer plotting
X = [X X(:,1)];
Y = [Y Y(:,1)];
u = [u u(:,1)];
ua = [ua ua(:,1)];

figure
surf(X, Y, ua, "EdgeColor", "none")
title("Approximate Solution")
xlabel("X")
ylabel("Y")
axis equal
view([0 90])
cb = colorbar;
cb.Label.String = "u(X,Y)";
colormap("jet")

figure
surf(X, Y, u, "EdgeColor", "none")
title("Exact Solution")
xlabel("X")
ylabel("Y")
axis equal
view([0 90])
cb = colorbar;
cb.Label.String = "u(X,Y)";
colormap("jet")

max_err = max(max(abs(ua - u)));
disp("Maximum Absolute Error: " + max_err)
rel_err = 100 * max_err / (max(max(u)) - min(min(u)));
disp("Maximum Relative Error: " + rel_err)