function I = interpolCentersToNodes2D(k, m, n, dc, nc)
% interpolation operator from staggered to nodes
% m, n, are the number of cells in the logical x-, y- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 3 && nargin ~= 5
        error("interpolCentersToNodes2D:InvalidNumArgs",...
              "interpolCentersToNodes2D expects 3 or 5 arguments")
    elseif nargin == 3
        dc = [1; 1; 1; 1];
        nc = [0; 0; 0; 0];
    else
        assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
        assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")
    end

    if isempty(find(dc(1:2).^2 + nc(1:2).^2,1))
        I1 = interpolCentersToFacesD1DPeriodic(k, m);
    else
        I1 = interpolCentersToFacesD1D(k, m);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2,1))
        I2 = interpolCentersToFacesD1DPeriodic(k, n);
    else
        I2 = interpolCentersToFacesD1D(k, n);
    end

    I = kron(I2, I1);
end