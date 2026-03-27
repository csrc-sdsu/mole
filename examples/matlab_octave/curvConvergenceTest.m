%% Convegence Test for Cuvilinear Operators
% 
% In 2D space, MOLE operators can only calculate the xi and eta derivatives
% On a curvilinear domain, the x and xi, and y and eta directions are
% not always the same. We can assume a transformation of x = x(xi, eta)
% and y = y(xi, eta) with Jacobian J = x_xi y_eta - x_eta y_xi.
% 
% If we have a function u(x,y), via chain rule we get:
%   u_xi  = u_x x_xi  + u_y y_xi
%   u_eta = u_x x_eta + u_y y_eta
% 
% Assuming a non-zero Jacobian, we can invert the mapping to obtain:
%   u_x = (u_xi y_eta - u_eta y_xi) / J
%   u_y = (u_eta x_xi - u_xi x_eta) / J
% 
% Everything on the right is easily calculable using MOLE's operators
% 

%% Comparison between current implementation and new implementation
% 
% Current Implementation:
%   - Nodal Jacobian derivatives
%   - MATLAB interpolation (2nd order)
%   - Hard to understand implementation (DI2 and GI2 functions: It is 
%       obvious what they are doing, but not how they are doing it.)
%   - Cannot handle periodic domains
% 
% New Implementation
%   - MOLE gradient used to calculate Jacobian derivatives
%   - MOLE interpolators
%   - Easy to understand implementation
%   - Can handle periodic domains
% 

%% Problem
% 
% ∆u = 0
% 
% 1 < R < 2
% 0 < θ < pi
% 
% x = R cos(θ)
% y = R sin(θ)
% 
% Boundary Conditions
% u(1,θ)  = 1
% u(2,θ)  = 8
% u(R,0)  = R^2
% u(R,pi) = R^2
% 
% Exact Solution:
%   u(x,y) = sin(x) sinh(y)
% 
close all; clear; clc;


%% Fixed mesh, varying k Comparison
% Parameters
k = [2 4 6 8];
m = 100;
n =  25;
numCenters = (m+2) * (n+2);
dx = pi / m;
dy = 1  / n;

ue = @(X,Y) sin(X) .* sinh(Y);

errorCur = zeros(size(k));
errorNew = zeros(size(k));

dc = [1;1;1;1]; nc = [0;0;0;0];

for i = 1:numel(k)

    fprintf("Starting k = %d\n", k(i))
    % Nodes to make current operators
    rsN = 1:dy:2; tsN = pi:-dx:0;
    [TSN,RSN] = meshgrid(tsN,rsN);
    xn = RSN .* cos(TSN);
    yn = RSN .* sin(TSN);

    % Centers to make new operators
    rsC = [1 1+dy/2:dy:2-dy/2 2];
    tsC = [pi pi-dx/2:-dx:dx/2 0];
    [TSC,RSC] = meshgrid(tsC,rsC);
    xc = RSC .* cos(TSC); xc = reshape(xc',[],1);
    yc = RSC .* sin(TSC); yc = reshape(yc',[],1);

    % Build operators
    curG = grad2DCurv(k(i),xn,yn);
    curD =  div2DCurv(k(i),xn,yn);
    curL = curD * curG;

    newG = grad2DCurv(k(i),xc,yc,m,dx,n,dy,dc,nc);
    newD =  div2DCurv(k(i),xc,yc,m,dx,n,dy,dc,nc);
    newL = newD * newG;

    % Boundary Conditions
    X = reshape(xc,m+2,n+2)'; % Reshape for plotting and easier BC
    Y = reshape(yc,m+2,n+2)';
    u = ue(X,Y);

    l = u(:,1);  r = u(:,end);
    b = u(1,:)'; t = u(end,:)';
    v = {l(2:end-1);r(2:end-1);b;t};
    B = zeros(numCenters,1);
    [curL,B] = addScalarBC2D(curL,B,k(i),m,dx,n,dy,dc,nc,v);
    [newL,B] = addScalarBC2D(newL,B,k(i),m,dx,n,dy,dc,nc,v);

    curU = curL \ B;
    newU = newL \ B;

    curU = reshape(curU,m+2,n+2)';
    newU = reshape(newU,m+2,n+2)';

    % Maximum Absolute Error
    errorCur(i) = max(max(abs(u-curU)));
    errorNew(i) = max(max(abs(u-newU)));

end

% Plot results
figure
hold on
plot(k, errorCur, 'LineWidth', 2)
plot(k, errorNew, 'LineWidth', 2)
hold off
yscale log
xlim([k(1), k(end)])
xlabel('k')
ylabel('Maximum Absolute Error')
legend('Current Implementation', 'New Implementation','Location','southwest')
grid on
title("Maximum Absolute Error vs k")
subtitle("∆u = 0, 1 < R < 2, 0 < theta < π, m = 100, n = 25")


%% Fixed k, varying mesh Comparison
k = 4;
minCells = 2*k+1;
m = [4 8 16 32 64] * minCells;
n = [1 2  4  8 16] * minCells;
numCenters = (m+2) .* (n+2);
dx = pi ./ m;
dy = 1  ./ n;

errorCur = zeros(size(numCenters));
errorNew = zeros(size(numCenters));

dc = [1;1;1;1]; nc = [0;0;0;0];

for i = 1:numel(numCenters)

    fprintf("Starting m = %d, n = %d\n", m(i),n(i))
    % Nodes for current operators
    rsN = 1:dy(i):2; tsN = pi:-dx(i):0;
    [TSN,RSN] = meshgrid(tsN,rsN);
    xn = RSN .* cos(TSN);
    yn = RSN .* sin(TSN);

    % Centers for new operators
    rsC = [1 1+dy(i)/2:dy(i):2-dy(i)/2 2];
    tsC = [pi pi-dx(i)/2:-dx(i):dx(i)/2 0];
    [TSC,RSC] = meshgrid(tsC,rsC);
    xc = RSC .* cos(TSC); xc = reshape(xc',[],1);
    yc = RSC .* sin(TSC); yc = reshape(yc',[],1);

    % Build operators
    curG = grad2DCurv(k,xn,yn);
    curD =  div2DCurv(k,xn,yn);
    curL = curD * curG;

    newG = grad2DCurv(k,xc,yc,m(i),dx(i),n(i),dy(i),dc,nc);
    newD =  div2DCurv(k,xc,yc,m(i),dx(i),n(i),dy(i),dc,nc);
    newL = newD * newG;

    % Boundary Conditions
    X = reshape(xc,m(i)+2,n(i)+2)'; % Reshape for plotting and easier BC
    Y = reshape(yc,m(i)+2,n(i)+2)';
    u = ue(X,Y);

    l = u(:,1);  r = u(:,end);
    b = u(1,:)'; t = u(end,:)';
    v = {l(2:end-1);r(2:end-1);b;t};
    B = zeros(numCenters(i),1);
    [curL,B] = addScalarBC2D(curL,B,k,m(i),dx(i),n(i),dy(i),dc,nc,v);
    [newL,B] = addScalarBC2D(newL,B,k,m(i),dx(i),n(i),dy(i),dc,nc,v);

    curU = curL \ B;
    newU = newL \ B;

    curU = reshape(curU,m(i)+2,n(i)+2)';
    newU = reshape(newU,m(i)+2,n(i)+2)';

    % Maximum Absolute Error
    errorCur(i) = max(max(abs(u-curU)));
    errorNew(i) = max(max(abs(u-newU)));

end

% Plot results
h = numCenters.^-0.5;
refCur = errorCur(1) * (h / h(1)).^k;
refNew = errorNew(1) * (h / h(1)).^k;
figure
hold on
plot(h, errorCur, 'LineWidth', 2)
plot(h, errorNew, 'LineWidth', 2)
plot(h, refCur, 'LineWidth', 1.5, 'Color', 'k', 'LineStyle', '--')
plot(h, refNew, 'LineWidth', 1.5, 'Color', 'k', 'LineStyle', '--')
hold off
xscale log
yscale log
xlim([min(h) max(h)])
xlabel('1 / sqrt(Number of Centers)')
ylabel('Maximum Absolute Error')
legend('Current Implementation', 'New Implementation',"k =  " + k + " Reference Line",'Location','southeast')
grid on
title("Maximum Absolute Error vs 1 / sqrt(Number of Centers)")
subtitle("∆u = 0, 1 < R < 2, 0 < theta < π, k = " + k)