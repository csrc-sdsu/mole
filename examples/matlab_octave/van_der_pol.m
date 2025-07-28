% Solves a second order ODE using our implementation of RK4 (src/matlab_octave/rk4.m)

addpath('../../src/matlab_octave')

% OCTAVE does not have VanDerPol equation, so here it is with Mu=1
vdpl = @(t,y) [y(2); (1 - y(1)^2) * y(2) - y(1)];

%             func   tspan  dt    y0
[t, y] = rk4(vdpl, [0 20], .1, [2 0]);

plot(t, y(1, :), '-o', t, y(2, :), '-*')
title('Solution of van der Pol''s Equation');
xlabel('t');
ylabel('y');
legend('y_1', 'y_2', 'Location', 'NorthWest')
