% Solves ODE using backward Euler method

h = .01;                                    % Step-size
t = 0 : h : 5;                              % Calculates up to y(5)
y = zeros(1, length(t));
y(1) = 2;                                   % Initial condition
f = @(t, y) sin(t)^2*y;                     % f(t, y)

for i = 1 : length(t) - 1                   % Stages
    old_y = y(i);
    y(i+1) = fzero(@(y) y - h*f(t(i+1), y) - old_y, old_y); % Backward Euler
end

plot(t, y)
title('Approximation to y(t) using backward Euler')
xlabel('t')
ylabel('y')
grid on
