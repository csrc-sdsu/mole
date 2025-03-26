function I = interpolNodesToCenters3D(k, m, n, o)
% interpolation operator from nodal coordinates to staggered centers
% m, n, o, are the number of cells in the logical x-, y-, z- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]x[1:1:o]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]x[1,1.5:o-0.5,o]
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    I1 = interpolFacesToCentersG1D(k, m);
    I2 = interpolFacesToCentersG1D(k, n);
    I3 = interpolFacesToCentersG1D(k, o);

    I = kron(I3, kron(I2, I1));
end