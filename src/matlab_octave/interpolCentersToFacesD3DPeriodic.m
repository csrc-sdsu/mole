function I = interpolCentersToFacesD3DPeriodic(k, m, n, o)
% 3D interpolation from centers to faces
% when the boundary condition is periodic
% logical centers are [1 1.5 ... m-0.5 m]x[1 1.5 ... n-0.5 n]x[1 1.5 ... o-0.5 o]
% m, n, o, are the number of cells in the logical x-, y-, z- axes
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    I = interpolFacesToCentersG3DPeriodic(k, m, n, o)';   
end