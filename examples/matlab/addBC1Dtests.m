% testing 1D bc
%
% Tests 1-5 are taken from
% MA615 Numerical Methods for PDEs
% Spring 2022 Lecture Notes
% Xiangxiong Zhang
% Department of Mathematics
% Purdue University
%
close all; clc;

addpath('../../src/matlab');

k = 2;

% ====================== Test 1 =====================
% 1D Poisson BVP: Dirichlet, Dirichlet Homogeneous BC
% - u'' = 1, 0 < x < 1, u(0) = 0, u(1) = 0
% exact solution: u(x) = x(1-x)/2
% ===================================================
bvp = 1;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 1, 0 < x < 1, u(0) = 0, u(1) = 0, with exact solution u(x) = x(1-x)/2';
ue = 0.5*xc.*(1-xc); % exact solution
dc = [1;1];
nc = [0;0];
v = [0;0];
A = - lap(k,m,dx);
b = ones(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 2 =====================
% 1D Poisson BVP: Dirichlet, Dirichlet Non-Homogeneous BC
% - u'' = 1, 0 < x < 1, u(0) = 1/2, u(1) = 1/2
% exact solution: u(x) = (-x^2 + x + 1)/2
% ===================================================
bvp = 2;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 1, 0 < x < 1, u(0) = 1/2, u(1) = 1/2, with exact solution u(x) = (-x^2 + x +1)/2';
ue = 0.5*(-xc.*xc + xc + 1); % exact solution
dc = [1;1];
nc = [0;0];
v = [1/2;1/2];
A = - lap(k,m,dx);
b = ones(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 3 =====================
% 1D Poisson BVP: Dirichlet, Neumann Homogeneous BC
% - u'' = 1, 0 < x < 1, u'(0) = 0, u(1) = 0
% exact solution: u(x) = (1 - x^2)/2
% ===================================================
bvp = 3;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 1, 0 < x < 1, u''(0) = 0, u(1) = 0, with exact solution u(x) = (1-x^2)/2';
ue = 0.5*(1-xc.*xc); % exact solution
dc = [0;1];
nc = [1;0];
v = [0;0];
A = - lap(k,m,dx);
b = ones(size(A,2),1);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 4 =====================
% 1D Poisson BVP: Neumann, Neumann Homogeneous BC
% - u'' = x - 1/2, 0 < x < 1, u'(0) = 0, u'(1) = 0
% exact solution: u(x) = constant + x^2/4 - x^3/6
% Compatibility condition: 
% integ(f) = integ(-u'') = - u'(1) + u'(0) 
% ===================================================
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
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution (there are infinity solutions)
ua = ua - ua(1) + ue(1); % shifting ua to match ue(1) with ua(1)
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 5 =====================
% 1D Poisson BVP: Periodic BC
% - u'' = 4 pi^2 sin(2 pi x), 0 < x < 1, u(0) = u(1), u'(0) = u'(1)
% exact solution: u(x) = sin(2 pi x) + constant
% ===================================================
bvp = 5;
m = 20; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = 4 pi^2 sin(2 pi x), 0 < x < 1, u(0) = u(1), u''(0) = u''(1), with exact solution u(x) = sin(2 pi x) + constant';
ue = sin(2*pi*xc); % exact solution
dc = [0;0];
nc = [0;0];
v = [0;0];
A = - lap(k,m,dx);
b = 4*pi^2 * sin(2*pi*xc);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution (there are infinity solutions) 
ua = ua - ua(1) + ue(1); % shifting ua to match ue(1) with ua(1)
addBC1Dplottests(xc,ue,ua,t,bvp);


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
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


% ====================== Test 7 =====================
% 1D Poisson BVP: Dirichlet, Robin BC
% - u'' = pi^2 sin(pi x), 0 < x < 1, u(0) = c, b u(1)+ u'(1) = d
% exact solution: u(x) = sin(pi x) + Ex + F
% E = (d - bc + pi)/(b+1), F = c
% Taken from
% https://www.scirp.org/journal/paperinformation?paperid=50586
%
% b = 400, c = 10, d = 15
% So, E = (pi - 3985)/401, F = 10
% ===================================================
bvp = 7;
m = 2*k+1; 
dx = 1/m;
% centers and vertices
xc = [0 dx/2:dx:1-dx/2 1]';
t = '- u" = sin(pi x), 0 < x < 1, u(0) = 10, 400 u(1) + u''(1) = 15, with exact solution u(x) = sin(pi x) + (pi - 3985)x/401 + 10';
ue = sin(pi*xc) + (pi - 3985)*xc/401 + 10; % exact solution
dc = [1;400];
nc = [0;1];
v = [10;15];
A = - lap(k,m,dx);
b = pi^2 * sin(pi*xc);
[A0,b0] = addBC1D(A,b,k,m,dx,dc,nc,v);
ua = A0\b0; % approximate solution
addBC1Dplottests(xc,ue,ua,t,bvp);


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
