function L = lapPeriodic(k, m, dx)
% Returns a m by m one-dimensional mimetic laplacian operator
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

    D = divPeriodic(k, m, dx);
    G = gradPeriodic(k, m, dx);
    
    L = D*G;
end
