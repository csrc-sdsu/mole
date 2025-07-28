% ====================== Test 2 =====================
% 1D Poisson BVP: Dirichlet, Dirichlet Non-Homogeneous BC
% - u'' = 1, 0 < x < 1, u(0) = 1/2, u(1) = 1/2
% exact solution: u(x) = (-x^2 + x + 1)/2
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 2;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 1, 0 < x < 1, u(0) = 1/2, u(1) = 1/2, with exact solution u(x) = (-x^2 + x +1)/2';
ue = 0.5*(-xc.*xc + xc + 1); % exact solution
dc = [1;1];
nc = [0;0];
v = [1/2;1/2];
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
