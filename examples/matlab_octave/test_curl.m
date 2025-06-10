% This file does not uses the curl2D(...) function provided by the library.
% It just tests the 2D mimetic divergence applied to an auxiliary vector 
% field to obtain the equivalent curl. The proper way to solve problems 
% that involve the curl operator is by calling the function curl2D(...)

clc
close all

addpath('../../src/matlab_octave')

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

F = zeros(2*m*n+m+n, 1);

k = 1;
for j = 2 : 2 : 2*n+1
    for i = 1 : 2 : 2*m+1
        F(k) = Q(xaxis(i), yaxis(j)); % Important!
        k = k + 1;
    end
end

for j = 1 : 2 : 2*n+1
    for i = 2 : 2 : 2*m+1
        F(k) = -P(xaxis(i), yaxis(j)); % Important!
        k = k + 1;   
    end
end

curl = div2D(order, m, dx, n, dy)*F; % F is F* in https://doi.org/10.1016/j.cam.2019.06.042
curl = reshape(curl, m+2, n+2);
curl = curl(2:end-1, 2:end-1);

% Vector field
U = P(X, Y);
V = Q(X, Y);

quiver3(X(2:end, 2:end), Y(2:end, 2:end), zeros(m, n), U(2:end, 2:end), V(2:end, 2:end), curl);
% Remember that by default, quiver will scale the length of the arrows!
title('Mimetic-curl');
xlabel('x')
ylabel('y')
zlabel('z')
set(gcf, 'color', 'w')
view(0, 90)
axis tight

% This P and Q will produce a scalar curl = 2
function U = P(~, Y)
  U = -Y;
end

function V = Q(X, ~)
  V = X;
end
