% This file does not uses the curl2D(...) function provided by the library.
% It just tests the 2D mimetic divergence applied to an auxiliary vector 
% field to obtain the equivalent curl. The proper way to solve problems 
% that involve the curl operator is by calling the function curl2D(...)

clc
close all

addpath('../mole_MATLAB')

order =   2;
west  = -10;
east  =  10;
south = -10;
north =  10;
m = 20;
n = 20;
dx = (east-west)/m;
dy = (north-south)/n;

xaxis = west : (dx/2) : east;
yaxis = south : (dy/2) : north;
[X, Y] = meshgrid(xaxis(1:2:end), yaxis(1:2:end));

A1 = zeros(2*m*n+m+n, 1);
A2 = zeros(2*m*n+m+n, 1);

% Vector field
U = P(X, Y);
V = Q(X, Y);

k = 1;
for j = 2 : 2 : 2*n+1
    for i = 1 : 2 : 2*m+1
        A1(k) = P(xaxis(i), yaxis(j));
        A2(k) = Q(xaxis(i), yaxis(j));
        k = k + 1;
    end
end

for j = 1 : 2 : 2*n+1
    for i = 2 : 2 : 2*m+1
        A1(k) =  Q(xaxis(i), yaxis(j));
        A2(k) = -P(xaxis(i), yaxis(j));
        k = k + 1;   
    end
end

curlMOLE = div2D(order, m, dx, n, dy)*A2;
curlMOLE = reshape(curlMOLE, m+2, n+2);
curlMOLE = curlMOLE(2:end-1, 2:end-1);

quiver3(X(2:end, 2:end), Y(2:end, 2:end), zeros(m, n),...
        U(2:end, 2:end), V(2:end, 2:end), curlMOLE,... 
        'AutoScale', 'on');
title('Quiver plot');
xlabel('x')
ylabel('y')
zlabel('z')
set(gcf, 'color', 'w')
view(0, 90)
axis tight

% Modified vector field (F*)
function U = P(~, Y)
  U = -Y;
end

function V = Q(X, ~)
  V = X;
end
