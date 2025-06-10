function D = divPeriodic(k, m, dx)
% Returns a m+2 by m one-dimensional mimetic divergence operator
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
    assert(m >= 2*k+1, ['m >= ' num2str(2*k+1) ' for k = ' num2str(k)]);

    D = - gradPeriodic(k,m,dx)';
end
