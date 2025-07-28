% ====================== Test 4 =====================
% 1D Legendre's Sturm Liouville: Dirichlet, Dirichlet BC
% (1-x^2) u'' - 2x u' + n(n+1) u = 0, -1 < x < 1, u(-1) = -1, u(1) = 1
% exact solution: u(x) = P_n(x) (Legendre polynomial of order n)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 4;
m = 20; 
dx = 2/m;
xc = [-1 -1+dx/2: dx:1-dx/2 1]';
t = 'Legendre''s DE (1-x^2) u" - 2 x u'' + n(n+1) u = 0, -1 < x < 1, u(-1) = -1, u(1) = 1, with exact solution u(x) = P_n(x)';
% ue = legendreP(3,xc); % exact solution
ue = [-1.0; -0.7184375; -0.2603125; 0.0703125; 0.2884375; 0.4090625; ...
      0.4471875; 0.4178125; 0.3359375; 0.2165625; 0.0746875; -0.0746875; ...  
      -0.2165625; -0.3359375; -0.4178125; -0.4471875; -0.4090625; ...  
      -0.2884375; -0.0703125; 0.2603125; 0.7184375; 1.0];
dc = [1;1];
nc = [0;0];
v = [-1;1];
G = grad(k,m,dx);
I = interpolFacesToCentersG1D(k,m);
A = sparse(diag(1-xc.^2)*lap(k,m,dx) - 2*diag(xc)*I*G) + 12*speye(m+2,m+2); % n = 3
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
