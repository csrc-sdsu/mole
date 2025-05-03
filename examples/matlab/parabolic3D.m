clear; close all; clc;

addpath('../../src/matlab')

% copper
tc = 401;                                       % thermal conductivity (W/m.K)
cp = 390;                                       % specific heat (J/kg K)
rho = 8940;                                     % density (kg/m^3) 

%% Domain parameters
method = "implicit";
k = 2;

m = 39; 
n = 19; 
o = 19; 

dx = 2/m;
dy = 1/n;
dz = 1/o;

xc = [0 dx/2:dx:2-dx/2 2]';
yc = [0 dy/2:dy:1-dy/2 1]';
zc = [0 dz/2:dz:1-dz/2 1]';

[Y, X, Z] = meshgrid(yc, xc, zc);

alph = tc/(cp*rho); 
dt = 1/(2*alph*((1/dx^2)+(1/dy^2)+(1/dz^2)));
t = 30;

%% Initial and boundary conditions (1st type, a.k.a Dirichlet)

% boundary type: Dirichlet
dc = [1;1;1;1;1;1];
nc = [0;0;0;0;0;0];

bcl = 20 * ones(n*o, 1);              % left
bcr = -20 * ones(n*o, 1);             % right
bcb = zeros((m+2)*o, 1);              % bottom
bct = zeros((m+2)*o, 1);              % top
bcf = zeros((n+2)*(m+2), 1);          % front
bcz = zeros((n+2)*(m+2), 1);          % back

v = {bcl;bcr;bcb;bct;bcf;bcz};

L = lap3D(k, m, dx, n, dy, o, dz);

U = zeros(m+2,n+2,o+2);

U = reshape(U, [], 1);

switch method
    case "explicit"
        L = alph*dt*L +speye(size(L));  
    case "implicit"
        L = speye(size(L)) - alph*dt*L;
end

[L, U] = addScalarBC3D(L, U, k, m, dx, n, dy, o, dz, dc, nc, v); 

for it = 0 : t / dt
    switch method
        case "explicit" 
            U = L * U; 
        case "implicit"
            U = L \ U;  
    end

    [L, U] = addScalarBC3D(L, U, k, m, dx, n, dy, o, dz, dc, nc, v); 

end

U = reshape(U, m+2, n+2, o+2);


ix = round((m+3)/2);  % Middle x-index
iy = round((n+3)/2);  % Middle y-index
iz = round((o+3)/2);  % Middle z-index

figure(1)
surf(squeeze(Y(ix,:,:)), squeeze(Z(ix,:,:)), squeeze(U(ix,:,:)));
xlabel('y'); ylabel('z'); zlabel('U');
title('YZ Slice');
shading interp
colorbar

figure(2)
surf(squeeze(X(:,iy,:)),squeeze(Z(:,iy,:)),squeeze(U(:,iy,:)));
title('XZ slice');
xlabel('X');
ylabel('Z');
shading interp;
colorbar

figure(3)
surf(squeeze(X(:,:,iz)),squeeze(Y(:,:,iz)),squeeze(U(:,:,iz)));
title('XY slice');
xlabel('X');
ylabel('Y');
shading interp;
colorbar


