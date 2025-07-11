function L = lapNonPeriodic(k, m, dx)
% Returns a m+2 by m+2 one-dimensional mimetic laplacian operator
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

    D = divNonPeriodic(k, m, dx);
    G = gradNonPeriodic(k, m, dx);
    
    L = D*G;
end
