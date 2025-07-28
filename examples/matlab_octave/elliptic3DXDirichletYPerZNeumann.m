% ====================== Test 2 =====================
% 3D Poisson BVP: Dirichlet (on left and right faces), Periodic along Y-axis, Neumann along Z-axis BC
% -(u_xx + u_yy + u_zz) = 2 sin(2 pi y) z (1 + 2 pi^2 x(1-x)), 0 < x,y,z < 1
% BC: u(-1,y,z) = 0, u(1,x,y) = 0, periodic along Y-axis, u_z(x,y,0) = -x(1-x)sin(2 pi y), u_z(x,y,0) = x(1-x)sin(2 pi y)
% exact solution: x(1-x)sin(2 pi y)z
% ===================================================
% example that uses addScalarGral3D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 2;
m = 29; % should be odd to be able to plot the middle slice
n = m+2; % should be odd to be able to plot the middle slice
o = m+4; % should be odd to be able to plot the middle slice
dx = 1/m;
dy = 1/n;
dz = 1/o;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
yc = (dy/2:dy:1-dy/2)';
zc = [0 dz/2:dz:1-dz/2 1]';
[Y,X,Z] = meshgrid(yc,xc,zc);
t = '-(u_xx + u_yy + u_zz) = 2 sin(2 pi y) z (1 + 2 pi^2 x(1-x)), 0 < x,y,z < 1, u(-1,y,z) = 0, u(1,x,y) = 0, periodic along Y-axis, u_z(x,y,0) = -x(1-x)sin(2 pi y), u_z(x,y,0) = x(1-x)sin(2 pi y), with exact solution u(x,y,z) = x(1-x)sin(2 pi y)z';
ue = X.*(1-X).*sin(2*pi*Y).*Z;
dc = [1;1;0;0;0;0];
nc = [0;0;0;0;1;1];
bcl = zeros(n*o,1);
bcr = zeros(n*o,1);
bcb = 0; % zeros((m+2)*o,1);
bct = 0; % zeros((m+2)*o,1);
bcf = zeros(n*(m+2),1);
bcz = zeros(n*(m+2),1);
% bcf = zeros((n+2)*(m+2),1);
% bcz = zeros((n+2)*(m+2),1);
v = {bcl;bcr;bcb;bct;bcf;bcz};
A = - lap3D(k,m,dx,n,dy,o,dz,dc,nc);
b = 2*sin(2*pi*Y).*Z.*(1+2*pi^2*X.*(1-X));
b = reshape(b,[],1);
[A0,b0] = addScalarBC3D(A,b,k,m,dx,n,dy,o,dz,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n,o+2);


% plot slices as surfaces
figure(bvp)
surf(squeeze(Y((m+3)/2,:,:)),squeeze(Z((m+3)/2,:,:)),squeeze(ua((m+3)/2,:,:)));
title('Approximate Solution: 3D Poisson with Periodic BC (Middle YZ slice)');
xlabel('Y');
ylabel('Z');
shading interp;
figure(bvp+10)
surf(squeeze(Y((m+3)/2,:,:)),squeeze(Z((m+3)/2,:,:)),squeeze(ue((m+3)/2,:,:)));
title('Exact Solution: 3D Poisson with Periodic BC (Middle YZ slice)');
xlabel('Y');
ylabel('Z');
shading interp;
figure(bvp+20)
surf(squeeze(X(:,(n+3)/2,:)),squeeze(Z(:,(n+3)/2,:)),squeeze(ua(:,(n+3)/2,:)));
title('Approximate Solution: 3D Poisson with Periodic BC (Middle XZ slice)');
xlabel('X');
ylabel('Z');
shading interp;
figure(bvp+30)
surf(squeeze(X(:,(n+3)/2,:)),squeeze(Z(:,(n+3)/2,:)),squeeze(ue(:,(n+3)/2,:)));
title('Exact Solution: 3D Poisson with Periodic BC (Middle XZ slice)');
xlabel('X');
ylabel('Z');
shading interp;
figure(bvp+40)
surf(squeeze(X(:,:,(o+3)/2)),squeeze(Y(:,:,(o+3)/2)),squeeze(ua(:,:,(o+3)/2)));
title('Approximate Solution: 3D Poisson with Periodic BC (Middle XY slice)');
xlabel('X');
ylabel('Y');
shading interp;
figure(bvp+50)
surf(squeeze(X(:,:,(o+3)/2)),squeeze(Y(:,:,(o+3)/2)),squeeze(ue(:,:,(o+3)/2)));
title('Exact Solution: 3D Poisson with Periodic BC (Middle XY slice)');
xlabel('X');
ylabel('Y');
shading interp;

fprintf('Maximum error: %.4f\n', max(max(max(abs(ue-ua)))))
fprintf('Relative error: %.4f%%\n', 100*max(max(max(abs(ue-ua))))/(max(max(max(ue))) - min(min(min(ue)))))
