function [t, y] = rk4(func, tspan, dt, y0)
% Explicit Runge-Kutta 4th-order method
%
% Returns: t (evaluation points) and y (solutions) of the specified ODE
%
% Parameters:
%                func : Function handler
%               tspan : [t0 tf]
%                  dt : Step size
%                  y0 : Initial conditions
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    t = tspan(1) : dt : tspan(2);
    y = zeros(length(y0), length(t));
    y(:, 1) = y0;
    
    for i = 1 : length(t) - 1
        k1 = func(t(i),        y(:, i));
        k2 = func(t(i) + dt/2, y(:, i) + dt/2*k1);
        k3 = func(t(i) + dt/2, y(:, i) + dt/2*k2);
        k4 = func(t(i) + dt,   y(:, i) + dt*k3);
        
        y(:, i + 1) = y(:, i) + dt/6*(k1 + 2*k2 + 2*k3 + k4);
    end
end
