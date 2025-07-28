% ====================== Test 2 =====================
% 1D Bessel's Sturm Liouville: Dirichlet, Dirichlet BC
% x^2 u'' + x u' + (x^2-nu^2) u = 0, 0 < x < 1, u(0) = 0, u(1) = Besselj(nu,1)
% exact solution: u(x) = J_3(x) (Bessel function of order 3)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 2;
m = 2*k+1; 
dx = 1/m;
xc = [0 dx/2:dx:1-dx/2 1]';
t = 'Bessel''s DE x^2 u" + x u'' + (x^2 - nu^2) u = 0, 0 < x < 1, u(0) = 0, u(1) = Bessel(nu,1), with exact solution u(x) = J_nu(x)';
% ue = besselj(3,xc); % exact solution
ue = [0; 0.000020820315755; 0.000559343047749; 0.002563729994587; ...
      0.006929654826751; 0.014434028475866; 0.019563353982668];
dc = [1;1];
nc = [0;0];
v = [0;besselj(3,1)];
G = grad(k,m,dx);
I = interpolFacesToCentersG1D(k,m);
A = sparse(diag(xc.^2)*lap(k,m,dx) + diag(xc)*I*G + diag(xc.^2 - 9)*speye(m+2,m+2)); % nu = 3
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
