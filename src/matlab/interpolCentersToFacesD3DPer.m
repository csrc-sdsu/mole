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

function I = interpolCentersToFacesD3DPer(k, m, n, o)
% 3D interpolation from centers to faces
% when the boundary condition is periodic
% logical centers are [1 1.5 ... m-0.5 m]x[1 1.5 ... n-0.5 n]x[1 1.5 ... o-0.5 o]
% m, n, o, are the number of cells in the logical x-, y-, z- axes

    I = interpolFacesToCentersG3DPer(k, m, n, o)';   
end