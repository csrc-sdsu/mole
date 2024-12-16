% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF). 
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

function Q = weightsQ2D(m, n, d)
% Returns the (m+2)(n+2) weights of Q in 2-D
%
% Parameters:
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%                d : Step size (assuming d = dx = dy)
%
% Only works for 2nd-order 2-D Mimetic divergence operator

    Q = d*ones((m+2)*(n+2), 1);
end
