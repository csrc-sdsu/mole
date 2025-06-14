function I = interpolCentersToFacesD2DPeriodic(k, m, n)
% 2D interpolation from centers to faces. 
% when the boundary condition is periodic
% logical centers are [1 1.5 2.5 ... m-1.5 m-0.5 m]x[1 1.5 2.5 ... n-1.5 n-0.5 n]
% m and n are the number of cells in the logic x-axis and y-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    I = interpolFacesToCentersG2DPeriodic(k, m, n)';
end