function G = gradCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic gradient operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% grid.nodes arrays are (m+1)×(n+1) in ndgrid layout; jacobian2D/3D
% expects meshgrid layout, so a transpose / permute is applied before
% delegating to grad2DCurv / grad3DCurv.
%
% Parameters:
%   G    : Sparse matrix — curvilinear gradient operator
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% G = gradCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        % grid.nodes.X is (m+1)×(n+1) ndgrid; jacobian2D expects (n+1)×(m+1) meshgrid
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        G = grad2DCurv(k, X, Y);

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; jacobian3D expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        G = grad3DCurv(k, X, Y, Z);

    otherwise
        error('gradCurv_impl:InvalidDim', ...
              'Curvilinear gradient is only implemented for dim=2 and dim=3');
    end
end
