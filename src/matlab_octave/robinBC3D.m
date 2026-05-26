function BC = robinBC3D(k, m, dx, n, dy, o, dz, a, b)
% PURPOSE
% Returns a three-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                o : Number of cells along z-axis
%               dz : Step size along z-axis
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient
%             grid : Struct carrying at least grid.m, grid.n, grid.o,
%                    grid.dx, grid.dy, and grid.dz.
%
% SYNTAX
% BC = robinBC3D(grid, k, a, b)
% BC = robinBC3D(k, m, dx, n, dy, o, dz, a, b)
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
        o = grid.o;
        dz = grid.dz;
    end

    deprecatedBoundaryWrapperWarning('robinBC3D', 'addScalarBC3D');

    ensureMatlabOctaveSubdirs();
    BC = robinBC3D_impl(k, m, dx, n, dy, o, dz, a, b);
end
