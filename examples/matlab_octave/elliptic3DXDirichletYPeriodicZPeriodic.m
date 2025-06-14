% ====================== Test 2 =====================
% 3D Poisson BVP: Dirichlet (on left and right faces), Periodic, Periodic BC
% -(u_xx + u_yy + u_zz) = - f(x,y,z), -1 < x < 1, 0 < y,z < 2 pi
% - f(x,y,z) = 16(1-x^2)cos(4x) - 16x sin(4x) + 2(cos(4x)+sin(2y)+sin(4z)) + (1-x^2)(4 sin(2y) + 16 sin(4z))
% BC: u(-1,y,z) = 0, u(1,x,y) = 0, u(x,0,z) = u(x,2 pi,z), u_y(x,0,z) = u_y(x,2 pi,z), u(x,y,0) = u(x,y,2 pi), u_z(x,y,0) = u_z(x,y,2 pi)
% exact solution: (cos(4x)+sin(2y)+sin(4z))*(1-x^2)
% ===================================================
% example that uses addScalarBC3D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 2;
m = 49; % should be odd to be able to plot the middle slice
n = m+2; % should be odd to be able to plot the middle slice
o = m+4; % should be odd to be able to plot the middle slice
dx = 2/m;
dy = 2*pi/n;
dz = 2*pi/o;
% centers and vertices
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
yc = (dy/2:dy:2*pi-dy/2)';
zc = (dz/2:dz:2*pi-dz/2)';
% yc = [0 dy/2:dy:2*pi-dy/2 2*pi]';
% zc = [0 dz/2:dz:2*pi-dz/2 2*pi]';
[Y,X,Z] = meshgrid(yc,xc,zc);
t = 'u_xx + u_yy + u_zz = f(x,y,z), -1 < x < 1, 0 < y,z < 2 pi, u(-1,y,z) = 0, u(1,y,z) = 0, periodic BC on y,z, with exact solution u(x,y,z) = (cos(4x)+sin(2y)+sin(4z))*(1-x^2)';
ue = (cos(4*X)+sin(2*Y)+sin(4*Z)).*(1-X.^2);
dc = [1;1;0;0;0;0];
nc = [0;0;0;0;0;0];
bcl = zeros(n*o,1);
bcr = zeros(n*o,1);
bcb = 0; bct = 0; bcf = 0; bcz = 0;
v = {bcl;bcr;bcb;bct;bcf;bcz};
A = - lap3D(k,m,dx,n,dy,o,dz,dc,nc);
b = 16*(1-X.^2).*cos(4*X) - 16*X.*sin(4*X) + 2*(cos(4*X)+sin(2*Y)+sin(4*Z)) + (1-X.^2).*(4*sin(2*Y) + 16*sin(4*Z));
b = reshape(b,[],1);
[A0,b0] = addScalarBC3D(A,b,k,m,dx,n,dy,o,dz,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n,o);


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
