% ====================== Test 2 =====================
% 1D wave equation 
% using addScalarBC time central difference and implicit scheme: BC Homogeneous Dirichlet
% u_tt = c^2 u_xx, 0 < x < M, 0 < t < T, 
% initial condition: u(0,t) = sin(pi x), u_t(0,t) = 0
% boundary condition: u(0,t) = 0, u(M,t) = 0
% exact solution: sin(pi x) cos(2 pi t)
%
% Taken from example 1 of 
% https://www.uni-muenster.de/Physik.TP/archive/fileadmin/lehre/NumMethoden/WS1011/script1011Wave.pdf
% ===================================================
% example that uses addScalarBC1D
%
% scheme:
% ((U^(n+1) - 2 U^(n) + U^(n-1))/dt = (c^2/2) L (U^(n+1) + U^(n-1))
%
clear all; close all; clc

addpath('../../src/matlab_octave')

% some other parameters
c = 2;
fx = 10; % final x
ft = 2; % final time

% Spatial discretization
k = 2;     % Order of accuracy (spatial) 
bvp = 9;   % figure index
m = 300;   % Number of cells
dx = fx/m;  % Step length
dt = dx/c; % Time length (c dt/dx =< 1 or dt =< dx/c)

% centers and vertices
xc = [0 dx/2:dx:fx-dx/2 fx]';
ts = (0:dt:ft)';
[T,X] = meshgrid(ts,xc);
t = 'u_tt = 4 u_xx, 0 < x < M, 0 < t < T, homogeneous Dirichlet BC, u(0,t) = sin(pi x), u_t(0,t) = 0, with exact solution u(x) = sin(pi x) cos(2 pi t)';
ue = sin(pi*X).*cos(2*pi*T); % exact solution
% boundary condition does not depend on time, otherwise should go inside time loop
dc = [1;1];
nc = [0;0];
v = [0;0];
% implicit scheme
a = (dt*c)^2/2;
% (I - a L)U^(n+1) = 2 U^n - (I - a L)U^(n-1)
A = speye(m+2,m+2) - a*lap(k,m,dx);
% approximate solution storage
ua = zeros(size(ue));
ua(:,1) = sin(pi*xc); % initial position
ua(:,2) = ue(:,2); % from exact solution instead of using initial velocity
% time loop
for idx = 3:ft/dt + 1
    b = 2*ua(:,idx-1) - A*ua(:,idx-2);
    [A0,b0] = addScalarBC1D(A,b,k,m,dx,dc,nc,v);
    ua(:,idx) = A0\b0; % approximate solution
end

figure(bvp)
surf(X,T,ua);
title('Approximate Solution: 1D Wave Equation with Homogeneous Dirichlet BC');
shading interp;
figure(bvp+10)
surf(X,T,ue);
title('Exact Solution: 1D Wave Equation with Homogeneous Dirichlet BC');
shading interp;

fprintf('Maximum error: %.4f\n', max(max(abs(ue-ua))))
fprintf('Relative error: %.4f%%\n', 100*max(max(abs(ue-ua)))/(max(max(ue)) - min(min(ue))))
