% ====================== Test 3 =====================
% 1D Hermite's Sturm Liouville: Dirichlet, Dirichlet BC
% u'' - 2 x u' + 2 m u = 0, -1 < x < 1, u(-1) = Hermite(4,-1), u(1) = Hermite(4,1)
% exact solution: u(x) = H_4(x) (Hermite function of order 4)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 3;
m = 20; 
dx = 2/m;
xc = [-1 -1+dx/2:dx:1-dx/2 1]';
t = 'Hermite''s DE u" - 2 x u'' + 2 m u = 0, -1 < x < 1, u(-1) = Hermite(m,-1), u(1) = Hermite(m,1), with exact solution u(x) = H_m(x)';
% ue = hermiteH(4,xc); % exact solution
ue = [-20.0000; -18.2879; -14.3279; -9.9375; -5.4239;  -1.0559;   2.9361; ...
        6.3601;   9.0625;  10.9281; 11.8801; 11.8801;  10.9281;   9.0625; ...
        6.3601;   2.9361;  -1.0559; -5.4239; -9.9375; -14.3279; -18.2879; -20.0000];
dc = [1;1];
nc = [0;0];
% v = [hermiteH(4,-1);hermiteH(4,1)];
v = [-20; -20];
G = grad(k,m,dx);
I = interpolFacesToCentersG1D(k,m);
A = lap(k,m,dx) - 2*sparse(diag(xc)*I*G) + 8*speye(m+2,m+2); % m = 4
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
