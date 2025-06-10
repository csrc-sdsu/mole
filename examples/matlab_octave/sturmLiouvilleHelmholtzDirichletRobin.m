% ====================== Test 7 =====================
% 1D Helmholtz Sturm Liouville: Dirichlet, Robin BC
% u'' + mu^2 u = 0, 0 < x < 1, u'(0) = 0, u(1) + u'(1) = cos(mu) - mu*sin(mu)
% exact solution: u(x) = cos(mu*x)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 7; 
m = 150;
dx = 1/m;
xc = [0 dx/2: dx:1-dx/2 1]';
t = 'Helmholtz DE u" + mu^2 u = 0, 0 < x < 1, u''(0) = 0, u(1) + u''(1) = cos(mu) - mu sin(mu), with exact solution u(x) = cos(mu x)';
ue = cos(0.86*xc); % exact solution
dc = [0;1];
nc = [1;1];
v = [0;cos(0.86) - 0.86*sin(0.86)];
A = lap(k,m,dx) + (0.86^2)*speye(m+2,m+2); % mu = 0.86
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
