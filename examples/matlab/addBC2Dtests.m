% testing 2D bc
%
close all; clc;

addpath('../../src/matlab');

k = 2;

% ====================== Test 1 =====================
% 2D Laplace BVP: Dirichlet, Dirichlet
% u_xx + u_yy = 0, 0 < x,y < pi, 
% BC: u(x,0) = e^x, u(x,pi) = - e^x, u(0,y) = cos(y), u(pi,y) = e^pi cos(y)
% exact solution: u(x,y) = e^x cos(y)
% ===================================================
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
A = - lap2D(k,m,dx,n,dy);
b = zeros(m+2,n+2);
b = reshape(b,[],1);
[A0,b0] = addBC2D(A,b,k,m,dx,n,dy,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n+2);
addBC2Dplotapproxtests(X,Y,ue,ua,'Approximate Solution','Exact Solution',bvp)

fprintf('Maximum error: %.4f\n', max(max(abs(ue-ua))))
fprintf('Relative error: %.4f%%\n', 100*max(max(abs(ue-ua)))/(max(max(ue)) - min(min(ue))))


% ====================== Test 2 =====================
% 2D Poisson BVP: Periodic, Periodic domain
% u_xx + u_yy = exp(- 10(x^2 + y^2)), -1 < x,y < 1, 
% BC: periodic
% exact solution: unknown
% ===================================================
bvp = 2;
m = 299; % it should be odd
n = m+2; % it should be odd
dx = 2/m;
dy = 2/n;
% centers and vertices
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
yc = [-1 -1+dy/2:dy:1-dy/2 1]';
[Y,X] = meshgrid(yc,xc);
% t = 'u_xx + u_yy = exp(-10(x^2+y^2)), -1 < x,y < 1, periodic boundary conditions. Unknown exact solution';
dc = [0;0;0;0];
nc = [0;0;0;0];
bcl = zeros(n,1);
bcr = zeros(n,1);
bct = zeros(m+2,1);
bcb = zeros(m+2,1);
v = {bcl;bcr;bcb;bct};
A = - lap2D(k,m,dx,n,dy);
b = - exp(-10*(X.^2 + Y.^2));
src = b;
b = reshape(b,[],1);
[A0,b0] = addBC2D(A,b,k,m,dx,n,dy,dc,nc,v);
ua = A0\b0; % approximate solution
ua = reshape(ua,m+2,n+2);
ua = ua - ua((m+1)/2,(n+3)/2);
addBC2Dplotapproxtests(X,Y,src,ua,'Approximate Solution','Source term',bvp)

function addBC2Dplotapproxtests(X,Y,v,ua,text1,text2,bvp)
    figure(bvp)
    surf(X,Y,ua);
    title([text1 ': 2D Poisson with Periodic BC']);
    shading interp;
    figure(bvp+10)
    surf(X,Y,v);
    title([text2 ': 2D Poisson with Periodic BC']);
    shading interp;
end
