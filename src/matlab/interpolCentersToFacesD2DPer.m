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

function I = interpolCentersToFacesD2DPer(k, m, n)
% 2D interpolation from centers to faces. 
% when the boundary condition is periodic
% logical centers are [1 1.5 2.5 ... m-1.5 m-0.5 m]x[1 1.5 2.5 ... n-1.5 n-0.5 n]
% m and n are the number of cells in the logic x-axis and y-axis

    I = interpolFacesToCentersG2DPer(k, m, n)';
end