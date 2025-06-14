function G = gradPeriodic(k, m, dx)
% Returns a m by m+2 one-dimensional mimetic gradient operator
% when the boundary condition is periodic
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % Assertions:
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');
    assert(m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);

    % constructing circulant matrix
    V = sparse(1, m); % vector of values for circulant matrix
    idx = repmat(-1,m, m); % matrix of indices for circulant matrix
    idx(:,1) = 1:m;
    idx = cumsum(idx, 2);
    idx = rem(idx+m, m) + 1;

    switch k
        case 2
            V(2:3) = [1, -1];

        case 4
            V(1:4) = [-1/24, 9/8, -9/8, 1/24];

        case 6
            V(1:5) = [-25/384, 75/64, -75/64, 25/384, -3/640]; V(end) = 3/640;

        case 8
            V(1:6) = [-245/3072, 1225/1024, -1225/1024, 245/3072, -49/5120, 5/7168]; V(end-1) = -5/7168; V(end) = 49/5120;
    end

    % G constructed as a circulant matrix
    G = V(idx);
    G = (1/dx).*G;
end
