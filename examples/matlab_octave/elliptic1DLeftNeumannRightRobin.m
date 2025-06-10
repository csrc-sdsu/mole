% ====================== Test 8 =====================
% 1D Poisson BVP: Neumann, Robin BC
% - u'' = pi^2 sin(pi x), 0 < x < 1, u'(0) = c, b u(1)+ u'(1) = d
% exact solution: u(x) = sin(pi x) + Ex + F
% E = c - pi, F = (d + pi - (b + 1)(c - pi))/b
% Taken from
% https://www.scirp.org/journal/paperinformation?paperid=50586
%
% b = 400, c = 10, d = 15
% So, E = - (10 + pi), F = (402 pi + 4025)/400
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 8;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u^" = sin(pi x), 0 < x < 1, u''(0) = 10, 400 u(1) + u''(1) = 15, with exact solution u(x) = sin(pi x) - (10 + pi)x + (402 pi + 4025)/400';
ue = sin(pi*xc) - (10 + pi)*xc + (402*pi+4025)/400; % exact solution
dc = [0;400];
nc = [1;1];
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
