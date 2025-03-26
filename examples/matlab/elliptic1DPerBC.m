% ====================== Test 5 =====================
% 1D Poisson BVP: Periodic BC
% - u'' = 4 pi^2 sin(2 pi x), 0 < x < 1, u(0) = u(1), u'(0) = u'(1)
% exact solution: u(x) = sin(2 pi x) + constant
% ===================================================
% example that does not use addBC1D
%
close all; clc;

addpath('../../src/matlab');

k = 2;
bvp = 5;
m = 20; 
dx = 1/m;
% centers and vertices
xc = (dx/2:dx:1-dx/2)';
t = '- u" = 4 pi^2 sin(2 pi x), 0 < x < 1, u(0) = u(1), u''(0) = u''(1), with exact solution u(x) = sin(2 pi x) + constant';
ue = sin(2*pi*xc); % exact solution
A = - lapPer(k,m,dx);
b = 4*pi^2 * sin(2*pi*xc);
ua = A\b; % approximate solution (there are infinity solutions) 
ua = ua - ua(1) + ue(1); % shifting ua to match ue(1) with ua(1)

% plot
figure(bvp)
plot(xc,ue,'b*',xc,ua,'ro');
title(t); %,'interpreter','latex');
xlabel('x');
ylabel('u');
legend({'exact','approx'});
