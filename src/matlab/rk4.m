% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

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
