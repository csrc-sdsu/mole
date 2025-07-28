function I = interpolFacesToCentersG1DPeriodic(k, m)
% 1D interpolation from faces to centers
% when the boundary condition is periodic
% centers logical coordinates [1,1.5:m-0.5]
% m is the number of cells in the logical x-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % constructing circulant matrix
    V = sparse(1, m); % vector of values for circulant matrix
    idx = repmat(-1,m, m); % matrix of indices for circulant matrix
    idx(:,1) = 1:m;
    idx = cumsum(idx, 2);
    idx = rem(idx+m, m) + 1;

    switch k
        case 2
            V(1:2) = [1, 1];
            denom = 2;

        case 4
            V(1:3) = [72, 72, -8]; V(m) = -8;
            denom = 128;

        case 6
            V(1:4) = [600, 600, -100, 12]; V(m-1) = 12; V(m) = -100;
            denom = 1024;

        case 8
            V(1:5) = [1225, 1225, -245, 49, -5]; V(m-2) = -5; V(m-1) = 49; V(m) = -245;
            denom = 2048;   

    end
    % I constructed as a circulant matrix
    I = V(idx);
    I = (1/denom).*I;
end