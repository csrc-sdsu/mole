% ====================== Test 1 =====================
% 1D Poisson BVP: Dirichlet, Dirichlet Homogeneous BC
% - u'' = 1, 0 < x < 1, u(0) = 0, u(1) = 0
% exact solution: u(x) = x(1-x)/2
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 1;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 1, 0 < x < 1, u(0) = 0, u(1) = 0, with exact solution u(x) = x(1-x)/2';
ue = 0.5*xc.*(1-xc); % exact solution
dc = [1;1];
nc = [0;0];
v = [0;0];
A = - lap(k,m,dx);
b = ones(size(A,2),1);
[A0,b0] = addScalarBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution

% plot
figure(bvp)
plot(xc,ue,'b*',xc,ua,'ro');
title(t); %,'interpreter','latex');
xlabel('x');
ylabel('u');
legend({'exact','approx'});
