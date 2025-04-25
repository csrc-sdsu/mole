function I = interpolCentersToFacesD1DPeriodic(k, m)
% 1D interpolation from centers to faces.
% when the boundary condition is periodic
% logical centers are [1 1.5 2.5 ... m-1.5 m-0.5]
% m is the number of cells in the logic x-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    I = interpolFacesToCentersG1DPeriodic(k,m)';
end