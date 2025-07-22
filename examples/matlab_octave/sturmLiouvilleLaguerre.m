% ====================== Test 5 =====================
% 1D Laguerre's Sturm Liouville: Dirichlet, Dirichlet BC
% x u'' + (1 - x) u' + n u = 0, 0 < x < 2, u(0) = Laguerre(4,0), u(2) = Laguerre(4,2)
% exact solution: u(x) = H_4(x) (Hermite function of order 4)
% ===================================================
% example that uses addScalarBC1D
%
close all; clc;

addpath('../../src/matlab_octave');

k = 2;
bvp = 5; 
m = 30;
dx = 2/m;
xc = [0 dx/2: dx:2-dx/2 2]';
t = 'Laguerre''s DE x u" + (1-x) u'' + n u = 0, 0 < x < 2, u(0) = Laguerre(n,0), u(2) = Laguerre(n,2), with exact solution u(x) = L_n(x)';
% ue = laguerreL(4,xc); % exact solution
ue = [...
       1.000000000000000;  0.869975360082304;  0.629337500000000;  0.413612397119342; ...
       0.221654372427984;  0.052337500000000; -0.095444393004115; -0.222777726337449; ...
      -0.330729166666667; -0.420345627572016; -0.492654269547325; -0.548662500000000; ...
      -0.589357973251029; -0.615708590534979; -0.628662500000000; -0.629148096707819; ...
      -0.618074022633745; -0.596329166666667; -0.564782664609053; -0.524283899176955; ...
      -0.475662500000000; -0.419728343621399; -0.357271553497942; -0.289062500000000; ...
      -0.215851800411523; -0.138370318930041; -0.057329166666667;  0.026580298353909; ...
       0.112686471193416;  0.200337500000000;  0.288901286008230;  0.333333333333333];
dc = [1;1];
nc = [0;0];
% v = [laguerreL(4,0);laguerreL(4,2)];
v = [1; 0.333333333333333];
G = grad(k,m,dx);
I = interpolFacesToCentersG1D(k,m);
A = sparse(diag(xc)*lap(k,m,dx) + diag(1-xc)*I*G) + 4*speye(m+2,m+2); % n = 4
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
    
