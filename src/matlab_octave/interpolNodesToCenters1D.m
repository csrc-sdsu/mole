function I = interpolNodesToCenters1D(k, m)
% PURPOSE
% interpolation operator from nodal coordinates to staggered centers
%
% DESCRIPTION
% nodal logical coordinates are [1:1:m]
% centers logical coordinates [1,1.5:m-0.5,m]
%
% Parameters:
%                 m is the number of cells in the logical x-axis
%
% SYNTAX
% I = interpolNodesToCenters1D(k, m)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    I = interpolFacesToCentersG1D(k, m);
end