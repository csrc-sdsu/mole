% ====================== Test 7 =====================
% 1D Poisson BVP: Dirichlet, Robin BC
% - u'' = pi^2 sin(pi x), 0 < x < 1, u(0) = c, b u(1)+ u'(1) = d
% exact solution: u(x) = sin(pi x) + Ex + F
% E = (d - bc + pi)/(b+1), F = c
% Taken from
% https://www.scirp.org/journal/paperinformation?paperid=50586
%
% b = 400, c = 10, d = 15
% So, E = (pi - 3985)/401, F = 10
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 7;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = sin(pi x), 0 < x < 1, u(0) = 10, 400 u(1) + u''(1) = 15, with exact solution u(x) = sin(pi x) + (pi - 3985)x/401 + 10';
ue = sin(pi*xc) + (pi - 3985)*xc/401 + 10; % exact solution
dc = [1;400];
nc = [0;1];
v = [10;15];
A = - lap(k,m,dx);
b = pi^2 * sin(pi*xc);
[A0,b0] = addScalarBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution

% plot
figure(bvp)
plot(xc,ue,'b*',xc,ua,'ro');
title(t); %,'interpreter','latex');
xlabel('x');
ylabel('u');
legend({'exact','approx'});
