function I = interpolNodesToCenters3D(k, m, n, o, dc, nc)
% interpolation operator from nodal coordinates to staggered centers
% m, n, o, are the number of cells in the logical x-, y-, z- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]x[1:1:o]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]x[1,1.5:o-0.5,o]
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 6
        error("interpolNodesToCenters3D:InvalidNumArgs",...
              "interpolNodesToCenters3D expects 4 or 6 arguments")
    elseif nargin == 4
        dc = [1; 1; 1; 1; 1; 1];
        nc = [0; 0; 0; 0; 0; 0];
    else
        assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
        assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")
    end

    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        I1 = interpolFacesToCentersG1DPeriodic(k,m);
    else
        I1 = interpolFacesToCentersG1D(k,m);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        I2 = interpolFacesToCentersG1DPeriodic(k,n);
    else
        I2 = interpolFacesToCentersG1D(k,n);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        I3 = interpolFacesToCentersG1DPeriodic(k,o);
    else
        I3 = interpolFacesToCentersG1D(k,o);
    end

    I = kron(I3, kron(I2, I1));
end