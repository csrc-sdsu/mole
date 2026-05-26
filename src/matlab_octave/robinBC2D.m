function BC = robinBC2D(k, m, dx, n, dy, a, b)
% PURPOSE
% Returns a two-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient
%             grid : Struct carrying at least grid.m, grid.n, grid.dx,
%                    and grid.dy.
%
% SYNTAX
% BC = robinBC2D(grid, k, a, b)
% BC = robinBC2D(k, m, dx, n, dy, a, b)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin == 4 && isstruct(k)
        grid = k;
        k = m;
        m = grid.m;
        dx = grid.dx;
        n = grid.n;
        dy = grid.dy;
    end

    deprecatedBoundaryWrapperWarning('robinBC2D', 'addScalarBC2D');

    ensureMatlabOctaveSubdirs();
    BC = robinBC2D_impl(k, m, dx, n, dy, a, b);
end
