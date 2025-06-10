% ====================== Test 4 =====================
% 1D Poisson BVP: Neumann, Neumann Homogeneous BC
% - u'' = x - 1/2, 0 < x < 1, u'(0) = 0, u'(1) = 0
% exact solution: u(x) = constant + x^2/4 - x^3/6
% Compatibility condition: 
% integ(f) = integ(-u'') = - u'(1) + u'(0) 
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 4;
m = 10; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = x - 1/2, 0 < x < 1, u''(0) = 0, u''(1) = 0, with exact solution u(x) = constant + x^2/4 - x^3/6';
ue = (1/4)*(xc.^2) - (1/6)*(xc.^3); % exact solution
dc = [0;0];
nc = [1;1];
v = [0;0];
A = - lap(k,m,dx);
b = xc - 0.5*ones(size(A,2),1);
[A0,b0] = addScalarBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution (there are infinity solutions)
ua = ua - ua(1) + ue(1); % shifting ua to match ue(1) with ua(1)

% plot
figure(bvp)
plot(xc,ue,'b*',xc,ua,'ro');
title(t); %,'interpreter','latex');
xlabel('x');
ylabel('u');
legend({'exact','approx'});
