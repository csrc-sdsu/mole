% ====================== Test 2 =====================
% 2D Poisson BVP: Periodic, Periodic domain
% u_xx + u_yy = exp(- 10(x^2 + y^2)), -1 < x,y < 1, 
% BC: periodic
% exact solution: unknown
% ===================================================
% example that does not use addBC2D
%
close all; clc;

addpath('../../src/matlab');

k = 2;
bvp = 2;
m = 49; % it should be odd
n = m+2; % it should be odd
dx = 2/m;
dy = 2/n;
% centers and vertices
xc = (-1+dx/2:dx:1-dx/2)';
yc = (-1+dy/2:dy:1-dy/2)';
[Y,X] = meshgrid(yc,xc);
% t = 'u_xx + u_yy = exp(-10(x^2+y^2)), -1 < x,y < 1, periodic boundary conditions. Unknown exact solution';
A = - lap2DPer(k,m,dx,n,dy);
b = - exp(-10*(X.^2 + Y.^2));
b = reshape(b,[],1);
ua = A\b; % approximate solution
ua = reshape(ua,m,n);
ua = ua - ua((m+1)/2,(n+1)/2);

figure(bvp)
surf(X,Y,ua);
title('Approximate Solution: 2D Poisson with Periodic BC');
shading interp;
figure(bvp+10)
surf(X,Y,b);
title('Source term: 2D Poisson with Periodic BC');
shading interp;
