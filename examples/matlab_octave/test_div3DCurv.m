% Tests the 3D curvilinear divergence
clc
close all
clear all

addpath('../../src/matlab_octave')

% Parameters
k = 2;  % Order of accuracy
m = 20; % Number of nodes along x-axis
n = 30; % Number of nodes along y-axis
o = 40; % Number of nodes along z-axis

xlength = linspace(1,m,m);
ylength = linspace(1,n,n);
zlength = linspace(1,o,o);

% [X, Y, Z] = meshgrid(xlength,ylength,zlength);

[X, Y] = genCurvGrid(n, m);
X = repmat(X, [1 1 o]);
Y = repmat(Y, [1 1 o]);
[~, ~, Z] = meshgrid(1:m, 1:n, 1:o);

Ux = (X(1:end-1, : ,1:end-1)+X(2:end, : ,2:end))*0.50;
Uy = (Y(1:end-1, : ,1:end-1)+Y(2:end, : ,2:end))*0.50;
Uz = (Z(1:end-1, : ,1:end-1)+Z(2:end, : ,2:end))*0.50;
%
Vx = (X( : ,1:end-1,1:end-1)+X( : ,2:end,2:end))*0.50;
Vy = (Y( : ,1:end-1,1:end-1)+Y( : ,2:end,2:end))*0.50;
Vz = (Z( : ,1:end-1,1:end-1)+Z( : ,2:end,2:end))*0.50;
%
Wx = (X(1:end-1,1:end-1,:)+X(2:end,2:end,:))*0.50;
Wy = (Y(1:end-1,1:end-1,:)+Y(2:end,2:end,:))*0.50;
Wz = (Z(1:end-1,1:end-1,:)+Z(2:end,2:end,:))*0.50;

% MOLE Operators want matrices to be in X,Y,Z
% for row, col, slice. Meshgrid creates a matrix
% col, row, slice. So, the permutation is needed.
X = permute( X, [2 1 3] );
Y = permute( Y, [2 1 3] );
Z = permute( Z, [2 1 3] );

Ux = permute( Ux, [2 1 3] );
Uy = permute( Uy, [2 1 3] );
Uz = permute( Uz, [2 1 3] );

Vx = permute( Vx, [2 1 3] );
Vy = permute( Vy, [2 1 3] );
Vz = permute( Vz, [2 1 3] );

Wx = permute( Wx, [2 1 3] );
Wy = permute( Wy, [2 1 3] );
Wz = permute( Wz, [2 1 3] );

%% Interpolators
% Some useful numbers
NtoC = interpolNodesToCenters3D(k+2, m-1, n-1, o-1);
CtoF3D = interpolCentersToFacesD3D(k+2,m-1,n-1,o-1);% v,u,w

size_u = (m)*(n-1)*(o-1);
size_v = (m-1)*(n)*(o-1);
size_w = (m-1)*(n-1)*(o);
size_c = (m+1)*(n+1)*(o+1);
size_n = (m)*(n)*(o);

CtoU = CtoF3D(1:size_u, 1:size_c);
CtoV = CtoF3D(size_u+1:size_u+size_v, size_c+1:2*size_c);
CtoW = CtoF3D(size_u+size_v+1:end, 2*size_c+1:end);

NtoU = CtoU * NtoC;
NtoV = CtoV * NtoC;
NtoW = CtoW * NtoC;
% 
% Interpolate U values
Ugiven = sin(X); %X.^2;
U = NtoU * Ugiven(:);
U = reshape(U, m, n-1 , o-1);

% Interpolate V values
Vgiven = zeros(size(Y)); %Y.^2;
V = NtoV * Vgiven(:);
V = reshape(V, m-1, n, o-1);

% Interpolate W values
Wgiven = zeros(size(Z)); %Z.^2;
W = NtoW * Wgiven(:);
W = reshape(W, m-1, n-1, o);


U = reshape(U, [], 1);
V = reshape(V, [], 1);
W = reshape(W, [], 1);

% Get 3D curvilinear mimetic divergence
% The operator want everything in X,Y,Z, BUT!!!!
% uses the original meshgrid X,Y,Z in (y,x,z) coordinates!!
% This needs to be changed!!! This is insane !!!
Xog = permute(X, [2 1 3]);
Yog = permute(Y, [2 1 3]);
Zog = permute(Z, [2 1 3]);

D = div3DCurv(k, Xog, Yog, Zog);

% Apply the operator to the field
Ccomp = D*[U; V; W];

% Remove outer layers for visualization
Ccomp = reshape(Ccomp, m+1, n+1, o+1);
Ccomp = Ccomp(2:end-1, 2:end-1, 2:end-1);

% Compute centroids?
X = (X(1:end-1, :, :)+X(2:end, :, :))/2;
X = (X(:, 1:end-1, :)+X(:, 2:end, :))/2;
X = (X(:, :, 1:end-1)+X(:, :, 2:end))/2;
Y = (Y(1:end-1, :, :)+Y(2:end, :, :))/2;
Y = (Y(:, 1:end-1, :)+Y(:, 2:end, :))/2;
Y = (Y(:, :, 1:end-1)+Y(:, :, 2:end))/2;
Z = (Z(1:end-1, :, :)+Z(2:end, :, :))/2;
Z = (Z(:, 1:end-1, :)+Z(:, 2:end, :))/2;
Z = (Z(:, :, 1:end-1)+Z(:, :, 2:end))/2;

figure
scatter3(X(:), Y(:), Z(:), 50, Ccomp(:), 'Filled');
title('Divergence of the field')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar
view([140 40])

figure
surf(X(:, :, o/2), Y(:, :, o/2), Ccomp(:, :, o/2))
title('Slice')
xlabel('x')
ylabel('y')
axis equal
colorbar
view([0 90])
shading interp

% Analytical divergence
div = cos(X);

figure
scatter3(X(:), Y(:), Z(:), 50, div(:), 'Filled');
title('Analytical')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
colorbar
view([140 40])

figure
surf(X(:, :, o/2), Y(:, :, o/2), div(:, :, o/2))
title('Analytical')
xlabel('x')
ylabel('y')
axis equal
colorbar
view([0 90])
shading interp
