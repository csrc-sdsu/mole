% ====================== Test 6 =====================
% 1D Poisson BVP: Robin, Robin BC
% - u'' = pi^2 sin(pi x), 0 < x < 1, 
% a u(0) + u'(0) = c, b u(1)+ u'(1) = d
% exact solution: u(x) = sin(pi x) + Ex + F
% E = (bc - ad - (a+b)pi)/(b-a(b+1))
% F = (d - (b+1)c + (b+2)pi)/(b-a(b+1))
% Taken from
% https://www.scirp.org/journal/paperinformation?paperid=50586
%
% a = -200, b = 400, c = 10, d = 15
% So, E = (35 - pi)/403, F = (402 pi - 3995)/80600
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 6;
m = 20; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = sin(pi x), 0 < x < 1, -200 u(0) + u''(0) = 10, 400 u(1) + u''(1) = 15, with exact solution u(x) = sin(pi x) + (35-pi)x/403 + (402 pi - 3995)/80600';
ue = sin(pi*xc) + (35 - pi)*xc/403 + (402*pi - 3995)/80600; % exact solution
dc = [-200;400];
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
