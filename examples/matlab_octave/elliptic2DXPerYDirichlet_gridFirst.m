% ====================== Test 5 (Grid-First) =====================
% 2D Poisson BVP: Periodic BC along X-axis and Dirichlet along Y-axis
% -(u_xx + u_yy) = 2 sin(2 pi x) (1+2 pi^2 y(1-y)), 0 < x,y < 1,
% periodic along x, u(x,0) = 0 = u(x,1)
% exact solution: u(x,y) = y(1-y)sin(2 pi x)
% ================================================================

close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 5;
m = 20;
n = m+1;
dx = 1/m;
dy = 1/n;

% centers and vertices
xc = (dx/2:dx:1-dx/2)';
yc = [0 dy/2:dy:1-dy/2 1]';
[Y,X] = meshgrid(yc,xc);

% BC coefficients: periodic in x, Dirichlet in y
% [left; right; bottom; top]
dc = [0;0;1;1];
nc = [0;0;0;0];
grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                'bc', struct('dc', dc, 'nc', nc));

% Boundary values: periodic sides can use scalar placeholders,
% bottom/top must be m-by-1 when x is periodic.
bcl = 0;
bcr = 0;
bcb = zeros(m,1);
bct = zeros(m,1);
v = {bcl;bcr;bcb;bct};

ue = Y.*(1-Y).*sin(2*pi*X); % exact solution
A = -lap2D(grid, k);
b = 2*sin(2*pi*X).*(1+2*pi^2*Y.*(1-Y));
b = reshape(b,[],1);
[A0, b0] = addScalarBC2D(A, b, k, grid, v);

ua = A0\b0; % approximate solution (there are infinite solutions)
ua = reshape(ua,m,n+2);

% plot
figure(bvp)
surf(X,Y,ua);
title('Approximate Solution: 2D Poisson (grid-first, periodic x, Dirichlet y)');
shading interp;

figure(bvp+10)
surf(X,Y,ue);
title('Exact Solution: 2D Poisson (grid-first, periodic x, Dirichlet y)');
shading interp;
