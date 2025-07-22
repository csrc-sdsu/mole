% ====================== Test 5 =====================
% 2D Poisson BVP: Periodic BC along X-axis and Dirichlet along Y-axis
% -(u_xx + u_yy) = 2 sin(2 pi x) (1+2 pi^2 y(1-y)), 0 < x,y < 1, u(x,0) = 0 = u(x,1)
% exact solution: u(x) = y(1-y)sin(2 pi x)
% ===================================================
% example that uses addScalarBC2D
%
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
t = '-(u_xx + u_yy) = 2 sin(2 pi x) (1+2 pi^2 y(1-y)), 0 < x,y < 1, periodic along x, u(x,0) = 0 = u(x,1), with exact solution u(x) = y(1-y)sin(2 pi x)';
dc = [0;0;1;1];
nc = [0;0;0;0];
bcl = 0; % zeros(n,1);
bcr = 0; % zeros(n,1);
bct = zeros(m,1);
bcb = zeros(m,1);
v = {bcl;bcr;bcb;bct};
ue = Y.*(1-Y).*sin(2*pi*X); % exact solution
A = - lap2D(k,m,dx,n,dy,dc,nc);
b = 2*sin(2*pi*X).*(1+2*pi^2*Y.*(1-Y));
b = reshape(b,[],1);
[A0, b0] = addScalarBC2D(A, b, k, m, dx, n, dy, dc, nc, v);
ua = A0\b0; % approximate solution (there are infinity solutions) 
ua = reshape(ua,m,n+2);

% plot
figure(bvp)
surf(X,Y,ua);
title('Approximate Solution: 2D Poisson with Periodic BC along X and Dirichlet on Y');
shading interp;
figure(bvp+10)
surf(X,Y,ue);
title('Exact Solution: 2D Poisson with Periodic BC along X and Dirichlet on Y');
shading interp;
