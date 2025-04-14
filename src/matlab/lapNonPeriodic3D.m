function L = lapNonPeriodic3D(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional mimetic laplacian operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                o : Number of cells along z-axis
%               dz : Step size along z-axis
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    D = divNonPeriodic3D(k, m, dx, n, dy, o, dz);
    G = gradNonPeriodic3D(k, m, dx, n, dy, o, dz);
    
    L = D*G;
end
