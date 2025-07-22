% ====================== Test 6 =====================
% 1D Helmholtz Sturm Liouville: Dirichlet, Dirichlet BC
% u'' + u = 0, 0 < x < 3, u(0) = 0, u(3) = sin(3)
% exact solution: u(x) = sin(x)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 6; 
m = 40;
dx = 3/m;
xc = [0 dx/2: dx:3-dx/2 3]';
t = 'Helmholtz DE u" + u = 0, 0 < x < 3, u(0) = 0, u(3) = sin(3), with exact solution u(x) = sin(x)';
ue = sin(xc); % exact solution
dc = [1;1];
nc = [0;0];
v = [0;sin(3)];
A = lap(k,m,dx) + speye(m+2,m+2);
b = zeros(size(A,2),1);
[A0,b0] = addScalarBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution

% plot
figure(bvp)
plot(xc,ue,'b*',xc,ua,'ro');
title(t); %,'interpreter','latex');
xlabel('x');
ylabel('u');
legend({'exact','approx'});
