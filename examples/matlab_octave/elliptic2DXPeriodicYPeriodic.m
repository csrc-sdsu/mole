% ====================== Test 2 =====================
% 2D Poisson BVP: Periodic, Periodic domain
% u_xx + u_yy = exp(- 10(x^2 + y^2)), -1 < x,y < 1, 
% BC: periodic
% exact solution: unknown
% ===================================================
% example that uses addScalarBC2D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;

bvp = 2;
m = 299; % it should be odd
n = m+2; % it should be odd
dx = 2/m;
dy = 2/n;
% centers and vertices
xc = (-1+dx/2:dx:1-dx/2)';
yc = (-1+dy/2:dy:1-dy/2)';
% xc = [-1 -1+dx/2:dx:1-dx/2 1]';
% yc = [-1 -1+dy/2:dy:1-dy/2 1]';
[Y,X] = meshgrid(yc,xc);
% t = 'u_xx + u_yy = exp(-10(x^2+y^2)), -1 < x,y < 1, periodic boundary conditions. Unknown exact solution';
dc = [0;0;0;0];
nc = [0;0;0;0];
bcl = 0; bcr = 0; bct = 0; bcb = 0;
v = {bcl;bcr;bcb;bct};
A = - lap2D(k,m,dx,n,dy,dc,nc);
b = - exp(-10*(X.^2 + Y.^2));
src = b;
b = reshape(b,[],1);
[A0,b0] = addScalarBC2D(A,b,k,m,dx,n,dy,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m,n);
% ua = reshape(ua,m+2,n+2);
ua = ua - ua((m+1)/2,(n+3)/2);

figure(bvp)
surf(X,Y,ua);
title('Approximate Solution: 2D Poisson with Periodic BC');
shading interp;
figure(bvp+10)
surf(X,Y,src);
title('Source term: 2D Poisson with Periodic BC');
shading interp;
