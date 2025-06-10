% ====================== Test 1 =====================
% 2D Laplace BVP: Dirichlet, Dirichlet
% u_xx + u_yy = 0, 0 < x,y < pi, 
% BC: u(x,0) = e^x, u(x,pi) = - e^x, u(0,y) = cos(y), u(pi,y) = e^pi cos(y)
% exact solution: u(x,y) = e^x cos(y)
% ===================================================
% example that uses addScalarBC2D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 1;
m = 99; % it should be odd
n = m+2; % it should be odd
dx = pi/m;
dy = pi/n;
% centers and vertices
xc = [0 dx/2:dx:pi-dx/2 pi]';
yc = [0 dy/2:dy:pi-dy/2 pi]';
[Y,X] = meshgrid(yc,xc);
% t = 'u_xx + u_yy = 0, (x,y) in [0,pi]x[0,pi], u(x,0) = e^x, u(x,pi) = - e^x, u(0,y) = cos(y), u(pi,y) = e^pi cos(y), with exact solution u(x,y) = e^x cos(y)';
ue = exp(X).*cos(Y); % exact solution
dc = [1;1;1;1];
nc = [0;0;0;0];
bcl = squeeze(ue(1,:))'; % left bc (y increases)
bcr = squeeze(ue(end,:))'; % right bc (y increases)
bcb = squeeze(ue(:,1)); % bottom bc (x increases)
bct = squeeze(ue(:,end)); % top bc (x increases)
bcl = bcl(2:end-1,1);
bcr = bcr(2:end-1,1);
v = {bcl;bcr;bcb;bct};
A = - lap2D(k,m,dx,n,dy,dc,nc);
b = zeros(m+2,n+2);
b = reshape(b,[],1);
[A0,b0] = addScalarBC2D(A,b,k,m,dx,n,dy,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n+2);

figure(bvp)
surf(X,Y,ua);
title('Approximate Solution: 2D Poisson with Periodic BC');
shading interp;
figure(bvp+10)
surf(X,Y,ue);
title('Exact Solution: 2D Poisson with Periodic BC');
shading interp;

fprintf('Maximum error: %.4f\n', max(max(abs(ue-ua))))
fprintf('Relative error: %.4f%%\n', 100*max(max(abs(ue-ua)))/(max(max(ue)) - min(min(ue))))
