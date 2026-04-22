function I = interpolCentersToNodes2D(k, m, n)
% PURPOSE
% interpolation operator from staggered to nodes
%
% DESCRIPTION
% nodal logical coordinates are [1:1:m]x[1:1:n]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
%
% Parameters:
%                    m: Number of cells in the logical x-axis
%                    n: Number of cells in the logical y-axis
%
% SYNTAX
% I = interpolCentersToNodes2D(k, m, n)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    I1 = interpolCentersToFacesD1D(k, m);
    I2 = interpolCentersToFacesD1D(k, n);

    I = kron(I2, I1);
end