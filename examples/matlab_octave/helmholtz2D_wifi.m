% Solves the 2D Helmholtz equation
% lap(E) + k^2/n^2 E = 0
% k = angular wave number
% n = refractive index
% This equation models the wifi signal propagation in a room

clc
close all

addpath('../../src/matlab_octave')

% define the walls
wall = @(X,Y) (X>=10.0 & X<=39.0 & Y>=20.0 & Y<=21.0) | (X>=30.0 & X<=31.0 & Y>=1.0 & Y<=16.0) | ...
   (X<=0.5 | X>=39.5 | Y<=0.5 | Y>=39.5);

% wall reflection coefficient
aa = 0.7
% wall absorption coefficient
bb = 0.9*0.5
% angular wave number
wn = 6;

%hotspot position
hsx = 2.0
hsy = 10.0
hsr = 1.0

% Spatial discretization
k = 2;   % Order of accuracy
m = 500;  % Number of cells along the x-axis
n = 500;   % Number of cells along the y-axis
a = 0;   % West
b = 40;   % East
c = 0;   % South
d = 40;   % North
dx = (b-a)/m;  % Step length along the x-axis
dy = (d-c)/n;  % Step length along the y-axis

% 2D Staggered grid
xgrid = [a a+dx/2 : dx : b-dx/2 b];
ygrid = [c c+dy/2 : dy : d-dy/2 d];

[X, Y] = meshgrid(xgrid, ygrid);

% complex coefficient c=k^2/n^2
c = (wn^2./(1+(aa+i*bb)*wall(X,Y)).^2)';
c = reshape(c, (m+2)*(n+2), 1);

%to detect the hotspot's position
HS = ((X-hsx).^2 + (Y-hsy).^2 < hsr^2)';
HS = reshape(HS, (m+2)*(n+2), 1);
ind = find(HS>0);
freenodes = setdiff(1:(m+2)*(n+2),ind);

% Mimetic operator (Laplacian)
L = lap2D(k, m, dx, n, dy);
id_op = diag(sparse(c));
L = L + id_op;
L = L + robinBC2D(k, m, dx, n, dy, 0, 1); % Neumann BC

% RHS
RHS = zeros(m+2,n+2);
% aux = -2*(X.^2+Y.^2-X-Y) + (X.^2-X).*(Y.^2-Y);
% RHS(2:end-1,2:end-1) = aux(2:end-1,2:end-1)';

RHS = reshape(RHS, (m+2)*(n+2), 1);
RHS = RHS - L*HS;

SOL = zeros((m+2)*(n+2),1);
SOL(freenodes) = L(freenodes,freenodes)\RHS(freenodes);
SOL(ind) = ones(length(ind),1);

% graph the logarithm of the modulus of SOL
logSOL = log(abs(SOL));
surf(X, Y, reshape(logSOL, m+2, n+2)');
shading interp
colorbar
view(2)
