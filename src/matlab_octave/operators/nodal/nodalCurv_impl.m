function N = nodalCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic nodal derivative operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% Transposes/permutes from ndgrid layout to meshgrid layout expected by
% nodal2DCurv / nodal3DCurv, then stacks the per-direction results into
% a single tall sparse matrix [Nx; Ny] (2D) or [Nx; Ny; Nz] (3D).
%
% Parameters:
%   N    : Stacked sparse matrix of curvilinear nodal operators
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% N = nodalCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        % grid.nodes.X is (m+1)×(n+1) ndgrid; nodal2DCurv expects (n+1)×(m+1) meshgrid
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        [Nx, Ny] = nodal2DCurv(k, X, Y);
        N = [Nx; Ny];

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; nodal3DCurv expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        [Nx, Ny, Nz] = nodal3DCurv(k, X, Y, Z);
        N = [Nx; Ny; Nz];

    otherwise
        error('nodalCurv_impl:InvalidDim', ...
              'Curvilinear nodal is only implemented for dim=2 and dim=3');
    end
end
