function BC = robinBC(k, m, dx, a, b)
% PURPOSE
% Returns a m+2 by m+2 one-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient
%             grid : Struct carrying at least grid.m and grid.dx.
%
% SYNTAX
% BC = robinBC(grid, k, a, b)
% BC = robinBC(k, m, dx, a, b)
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
    end

    deprecatedBoundaryWrapperWarning('robinBC', 'addScalarBC1D');

    ensureMatlabOctaveSubdirs();
    BC = robinBC_impl(k, m, dx, a, b);
end
