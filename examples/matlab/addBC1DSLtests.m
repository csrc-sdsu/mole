% testing 1D Sturm-Liouville bc
%
close all; clc;

addpath('../../src/matlab');

k = 2;

% is_Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

% ====================== Test 1 =====================
% 1D Chebyshev's Sturm Liouville: Dirichlet, Dirichlet BC
% (1-x^2) u'' - x u' + n^2 u = 0, -1 < x < 1, u(-1) = 1, u(1) = 1
% exact solution: u(x) = T_2(x) (Chebyshev polynomial degree 2)
% ===================================================
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
I = interpolFacesToStaggered1D(k,m);
A = sparse(diag(1-xc.^2)*lap(k,m,dx) - diag(xc)*I*G) + 4*speye(m+2,m+2); % n = 2
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 2 =====================
% 1D Bessel's Sturm Liouville: Dirichlet, Dirichlet BC
% x^2 u'' + x u' + (x^2-nu^2) u = 0, 0 < x < 1, u(0) = 0, u(1) = Besselj(nu,1)
% exact solution: u(x) = J_3(x) (Bessel function of order 3)
% ===================================================
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
I = interpolFacesToStaggered1D(k,m);
A = sparse(diag(xc.^2)*lap(k,m,dx) + diag(xc)*I*G + diag(xc.^2 - 9)*speye(m+2,m+2)); % nu = 3
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 3 =====================
% 1D Hermite's Sturm Liouville: Dirichlet, Dirichlet BC
% u'' - 2 x u' + 2 m u = 0, -1 < x < 1, u(-1) = Hermite(4,-1), u(1) = Hermite(4,1)
% exact solution: u(x) = H_4(x) (Hermite function of order 4)
% ===================================================
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
I = interpolFacesToStaggered1D(k,m);
A = lap(k,m,dx) - 2*sparse(diag(xc)*I*G) + 8*speye(m+2,m+2); % m = 4
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 4 =====================
% 1D Legendre's Sturm Liouville: Dirichlet, Dirichlet BC
% (1-x^2) u'' - 2x u' + n(n+1) u = 0, -1 < x < 1, u(-1) = -1, u(1) = 1
% exact solution: u(x) = P_n(x) (Legendre polynomial of order n)
% ===================================================
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
I = interpolFacesToStaggered1D(k,m);
A = sparse(diag(1-xc.^2)*lap(k,m,dx) - 2*diag(xc)*I*G) + 12*speye(m+2,m+2); % n = 3
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 5 =====================
% 1D Laguerre's Sturm Liouville: Dirichlet, Dirichlet BC
% x u'' + (1 - x) u' + n u = 0, 0 < x < 2, u(0) = Laguerre(4,0), u(2) = Laguerre(4,2)
% exact solution: u(x) = H_4(x) (Hermite function of order 4)
% ===================================================
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
I = interpolFacesToStaggered1D(k,m);
A = sparse(diag(xc)*lap(k,m,dx) + diag(1-xc)*I*G) + 4*speye(m+2,m+2); % n = 4
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 6 =====================
% 1D Helmholtz Sturm Liouville: Dirichlet, Dirichlet BC
% u'' + u = 0, 0 < x < 3, u(0) = 0, u(3) = sin(3)
% exact solution: u(x) = sin(x)
% ===================================================
bvp = 6; 
m = 40;
dx = 3/m;
xc = [0 dx/2: dx:3-dx/2 3]';
t = 'Helmholtz DE u" + u = 0, 0 < x < 3, u(0) = 0, u(3) = sin(3), with exact solution u(x) = sin(x)';
ue = sin(xc); % exact solution
dc = [1;1];
nc = [0;0];
v = [0;sin(3)];
A = lap(k,m,dx) + speye(m+2,m+2);
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 7 =====================
% 1D Helmholtz Sturm Liouville: Dirichlet, Robin BC
% u'' + mu^2 u = 0, 0 < x < 1, u'(0) = 0, u(1) + u'(1) = cos(mu) - mu*sin(mu)
% exact solution: u(x) = cos(mu*x)
% ===================================================
bvp = 7; 
m = 150;
dx = 1/m;
xc = [0 dx/2: dx:1-dx/2 1]';
t = 'Helmholtz DE u" + mu^2 u = 0, 0 < x < 1, u''(0) = 0, u(1) + u''(1) = cos(mu) - mu sin(mu), with exact solution u(x) = cos(mu x)';
ue = cos(0.86*xc); % exact solution
dc = [0;1];
nc = [1;1];
v = [0;cos(0.86) - 0.86*sin(0.86)];
A = lap(k,m,dx) + (0.86^2)*speye(m+2,m+2); % mu = 0.86
b = zeros(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


function addBC1Dplottests(xc,ue,ua,t,idx)
    % plot
    figure(idx)
    plot(xc,ue,'b*',xc,ua,'ro');
    title(t); %,'interpreter','latex');
    xlabel('x');
    ylabel('u');
    legend({'exact','approx'});
end
