% ====================== Test 1 =====================
% 1D Chebyshev's Sturm Liouville: Dirichlet, Dirichlet BC
% (1-x^2) u'' - x u' + n^2 u = 0, -1 < x < 1, u(-1) = 1, u(1) = 1
% exact solution: u(x) = T_2(x) (Chebyshev polynomial degree 2)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 1;
m = 2*k+1; 
dx = 2/m;
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
t = 'Chebyshev''s DE (1-x^2) u" - x u'' + n^2 u = 0, -1 < x < 1, u(-1) = 1, u(1) = 1, with exact solution u(x) = T_n(x)';
% ue = chebyshevT(2,xc); % exact solution
ue = [1.0000; 0.2800; -0.6800; -1.0000; -0.6800; 0.2800; 1.0000];
dc = [1;1];
nc = [0;0];
v = [1;1];
G = grad(k,m,dx);
I = interpolFacesToCentersG1D(k,m);
A = sparse(diag(1-xc.^2)*lap(k,m,dx) - diag(xc)*I*G) + 4*speye(m+2,m+2); % n = 2
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
