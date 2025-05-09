% Solves ODE using explicit RK4 method

h = .1;                                     % Step-size
t = 0 : h : 5;                              % Calculates up to y(5)
y = zeros(1, length(t));
y(1) = 2;                                   % Initial condition
f = @(t, y) sin(t)^2*y;                     % f(t, y)

for i = 1 : length(t) - 1                   % Stages
    k1 = f(t(i),       y(i));
    k2 = f(t(i) + h/2, y(i) + h/2*k1);
    k3 = f(t(i) + h/2, y(i) + h/2*k2);
    k4 = f(t(i) + h,   y(i) + h*k3);
    
    y(i + 1) = y(i) + h/6*(k1 + 2*k2 + 2*k3 + k4);  % y(i + 1)
end

plot(t, y)
title('4th-order approximation to y(t)')
xlabel('t')
ylabel('y')
grid on
