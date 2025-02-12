% testing 3D bc
%
close all; clc;

addpath('../../src/matlab');

k = 2;

% ====================== Test 1 =====================
% 3D Poisson BVP: Dirichlet, Dirichlet, Dirichlet
% -(u_xx + u_yy + u_zz) = -6(x+y+z), -1 < x,y,z < 1
% BC: u(-1,y,z) = -1+y^3+z^3, u(1,y,z) = 1+y^3+z^3, u(x,-1,z) = -1+x^3+z^3, u(x,1,z) = 1+x^3+z^3, u(x,y,-1) = -1+x^3+y^3, u(x,y,1) = 1+x^3+y^3, 
% exact solution: u(x,y,z) = x^3 + y^3 + z^3
% ===================================================
bvp = 1;
m = 29; % should be odd to be able to plot the middle slice
n = m+2; % should be odd to be able to plot the middle slice
o = m+4; % should be odd to be able to plot the middle slice
dx = 2/m;
dy = 2/n;
dz = 2/o;
% centers and vertices
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
yc = [-1 -1+dy/2:dy:1-dy/2 1]';
zc = [-1 -1+dz/2:dz:1-dz/2 1]';
% grids
[Y,X,Z] = meshgrid(yc,xc,zc);
% t = '-(u_xx + u_yy + u_zz) = -6(x+y+z), (x,y,z) in [-1,1]^3, with exact solution u(x,y,z) = x^3 + y^3 + z^3';
ue = X.^3 + Y.^3 + Z.^3; % exact solution
% define boundary conditions
dc = [1;1;1;1;1;1];
nc = [0;0;0;0;0;0];
bcl = squeeze(ue(1,:,:)); % left bc (y increase along rows, z increase along cols)
bcr = squeeze(ue(end,:,:)); % right bc (y increase along rows, z increase along cols)
bcb = squeeze(ue(:,1,:)); % bottom bc (x increase along rows, z increase along cols)
bct = squeeze(ue(:,end,:)); % top bc (x increase along rows, z increase along cols)
bcf = squeeze(ue(:,:,1)); % front bc (x increase along rows, y increase along cols)
bcz = squeeze(ue(:,:,end)); % back bc (x increase along rows, y increase along cols)
bcl = reshape(bcl(2:end-1,2:end-1),[],1);
bcr = reshape(bcr(2:end-1,2:end-1),[],1);
bcb = reshape(bcb(:,2:end-1),[],1);
bct = reshape(bct(:,2:end-1),[],1);
bcf = reshape(bcf,[],1);
bcz = reshape(bcz,[],1);
v = {bcl;bcr;bcb;bct;bcf;bcz};
% construct linear system
A = - lap3D(k,m,dx,n,dy,o,dz);
b = - 6*(X+Y+Z);
b = reshape(b,[],1);
[A0,b0] = addBC3D(A,b,k,m,dx,n,dy,o,dz,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n+2,o+2);

addBC3DSurfacePlots(X,Y,Z,m,n,o,ua,ue,bvp);


% ====================== Test 2 =====================
% 3D Poisson BVP: Dirichlet (on left and right faces), Periodic, Periodic BC
% -(u_xx + u_yy + u_zz) = - f(x,y,z), -1 < x < 1, 0 < y,z < 2 pi
% - f(x,y,z) = 16(1-x^2)cos(4x) - 16x sin(4x) + 2(cos(4x)+sin(2y)+sin(4z)) + (1-x^2)(4 sin(2y) + 16 sin(4z))
% % f(x,y,z) = 16(1-x^2)cos(4x) - 16x sin(4x) + 2 cos(4x) + (1-x^2)(4 sin(2y) + 16 sin(4z))
% BC: u(-1,y,z) = 0, u(1,x,y) = 0, u(x,0,z) = u(x,2 pi,z), u_y(x,0,z) = u_y(x,2 pi,z), u(x,y,0) = u(x,y,2 pi), u_z(x,y,0) = u_z(x,y,2 pi)
% exact solution: (cos(4x)+sin(2y)+sin(4z))*(1-x^2)
% ===================================================
bvp = 2;
m = 49; % should be odd to be able to plot the middle slice
n = m+2; % should be odd to be able to plot the middle slice
o = m+4; % should be odd to be able to plot the middle slice
dx = 2/m;
dy = 2*pi/n;
dz = 2*pi/o;
% centers and vertices
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
yc = [0 dy/2:dy:2*pi-dy/2 2*pi]';
zc = [0 dz/2:dz:2*pi-dz/2 2*pi]';
[Y,X,Z] = meshgrid(yc,xc,zc);
t = 'u_xx + u_yy + u_zz = f(x,y,z), -1 < x < 1, 0 < y,z < 2 pi, u(-1,y,z) = 0, u(1,y,z) = 0, periodic BC on y,z, with exact solution u(x,y,z) = (cos(4x)+sin(2y)+sin(4z))*(1-x^2)';
ue = (cos(4*X)+sin(2*Y)+sin(4*Z)).*(1-X.^2);
dc = [1;1;0;0;0;0];
nc = [0;0;0;0;0;0];
bcl = zeros(n*o,1);
bcr = zeros(n*o,1);
bcb = zeros((m+2)*o,1);
bct = zeros((m+2)*o,1);
bcf = zeros((n+2)*(m+2),1);
bcz = zeros((n+2)*(m+2),1);
v = {bcl;bcr;bcb;bct;bcf;bcz};
A = - lap3D(k,m,dx,n,dy,o,dz);
b = 16*(1-X.^2).*cos(4*X) - 16*X.*sin(4*X) + 2*(cos(4*X)+sin(2*Y)+sin(4*Z)) + (1-X.^2).*(4*sin(2*Y) + 16*sin(4*Z));
b = reshape(b,[],1);
[A0,b0] = addBC3D(A,b,k,m,dx,n,dy,o,dz,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n+2,o+2);
addBC3DSurfacePlots(X,Y,Z,m,n,o,ua,ue,bvp);


function addBC3DSurfacePlots(X,Y,Z,m,n,o,ua,ue,bvp)
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
end
